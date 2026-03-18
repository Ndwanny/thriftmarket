import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';

final r2ServiceProvider = Provider<R2StorageService>((ref) {
  return R2StorageService();
});

class R2StorageService {
  final Dio _dio = Dio();
  final _uuid = const Uuid();

  // ── Public API ────────────────────────────────────────────────────────────

  /// Upload a picked image file and return the public URL.
  Future<String> uploadImage(XFile file, {String folder = 'general'}) async {
    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last.toLowerCase();
    final key = '$folder/${_uuid.v4()}.$ext';
    return _upload(key: key, bytes: bytes, contentType: _mimeType(ext));
  }

  /// Upload raw bytes and return the public URL.
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String folder,
    required String filename,
    String contentType = 'application/octet-stream',
  }) async {
    final key = '$folder/$filename';
    return _upload(key: key, bytes: bytes, contentType: contentType);
  }

  /// Delete an object by its key (path inside the bucket).
  Future<void> delete(String key) async {
    final now = DateTime.now().toUtc();
    final headers = _signedHeaders(
      method: 'DELETE',
      key: key,
      contentType: '',
      payloadHash: _hexHash(Uint8List(0)),
      date: now,
    );
    final url = '${AppConfig.r2Endpoint}/${AppConfig.r2BucketName}/$key';
    await _dio.delete(url, options: Options(headers: headers));
  }

  /// Returns the public URL for a stored object.
  String publicUrl(String key) => '${AppConfig.r2PublicBaseUrl}/$key';

  // ── Internals ─────────────────────────────────────────────────────────────

  Future<String> _upload({
    required String key,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final now = DateTime.now().toUtc();
    final payloadHash = _hexHash(bytes);
    final headers = _signedHeaders(
      method: 'PUT',
      key: key,
      contentType: contentType,
      payloadHash: payloadHash,
      date: now,
    );

    final url = '${AppConfig.r2Endpoint}/${AppConfig.r2BucketName}/$key';
    await _dio.put(
      url,
      data: bytes,
      options: Options(headers: headers),
    );
    return publicUrl(key);
  }

  /// Build AWS Signature V4 authorization headers for R2.
  Map<String, String> _signedHeaders({
    required String method,
    required String key,
    required String contentType,
    required String payloadHash,
    required DateTime date,
  }) {
    final dateStamp = _dateStamp(date);
    final amzDate = _amzDate(date);
    final region = 'auto';
    final service = 's3';
    final bucket = AppConfig.r2BucketName;

    final canonicalUri = '/$bucket/$key';
    const canonicalQueryString = '';

    final signedHeaderNames = contentType.isEmpty
        ? 'host;x-amz-content-sha256;x-amz-date'
        : 'content-type;host;x-amz-content-sha256;x-amz-date';

    final host = '${AppConfig.r2AccountId}.r2.cloudflarestorage.com';

    final canonicalHeaders = contentType.isEmpty
        ? 'host:$host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n'
        : 'content-type:$contentType\nhost:$host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n';

    final canonicalRequest = [
      method,
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      signedHeaderNames,
      payloadHash,
    ].join('\n');

    final credentialScope = '$dateStamp/$region/$service/aws4_request';
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      _hexHashString(canonicalRequest),
    ].join('\n');

    final signingKey = _deriveSigningKey(
      AppConfig.r2SecretAccessKey,
      dateStamp,
      region,
      service,
    );
    final signature = _hexHmac(signingKey, stringToSign);

    final authorization =
        'AWS4-HMAC-SHA256 Credential=${AppConfig.r2AccessKeyId}/$credentialScope, '
        'SignedHeaders=$signedHeaderNames, Signature=$signature';

    return {
      if (contentType.isNotEmpty) 'Content-Type': contentType,
      'Host': host,
      'X-Amz-Content-Sha256': payloadHash,
      'X-Amz-Date': amzDate,
      'Authorization': authorization,
    };
  }

  // ── Crypto helpers ────────────────────────────────────────────────────────

  String _hexHash(Uint8List data) {
    return sha256.convert(data).toString();
  }

  String _hexHashString(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  String _hexHmac(Uint8List key, String data) {
    final hmac = Hmac(sha256, key);
    return hmac.convert(utf8.encode(data)).toString();
  }

  Uint8List _hmacBytes(Uint8List key, String data) {
    final hmac = Hmac(sha256, key);
    return Uint8List.fromList(hmac.convert(utf8.encode(data)).bytes);
  }

  Uint8List _deriveSigningKey(
      String secretKey, String date, String region, String service) {
    final kDate = _hmacBytes(
        Uint8List.fromList(utf8.encode('AWS4$secretKey')), date);
    final kRegion = _hmacBytes(kDate, region);
    final kService = _hmacBytes(kRegion, service);
    return _hmacBytes(kService, 'aws4_request');
  }

  String _dateStamp(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}'
      '${dt.month.toString().padLeft(2, '0')}'
      '${dt.day.toString().padLeft(2, '0')}';

  String _amzDate(DateTime dt) =>
      '${_dateStamp(dt)}T'
      '${dt.hour.toString().padLeft(2, '0')}'
      '${dt.minute.toString().padLeft(2, '0')}'
      '${dt.second.toString().padLeft(2, '0')}Z';

  String _mimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }
}
