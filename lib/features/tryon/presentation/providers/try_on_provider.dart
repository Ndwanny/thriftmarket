import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_config.dart';

enum TryOnStatus { idle, pickingImage, loading, success, error }

class TryOnState {
  final TryOnStatus status;
  final Uint8List? personImageBytes;   // the photo the user picked
  final Uint8List? resultImageBytes;   // the try-on result
  final String? errorMessage;

  const TryOnState({
    this.status = TryOnStatus.idle,
    this.personImageBytes,
    this.resultImageBytes,
    this.errorMessage,
  });

  TryOnState copyWith({
    TryOnStatus? status,
    Uint8List? personImageBytes,
    Uint8List? resultImageBytes,
    String? errorMessage,
  }) =>
      TryOnState(
        status: status ?? this.status,
        personImageBytes: personImageBytes ?? this.personImageBytes,
        resultImageBytes: resultImageBytes ?? this.resultImageBytes,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class TryOnNotifier extends StateNotifier<TryOnState> {
  TryOnNotifier() : super(const TryOnState());

  final _picker = ImagePicker();

  /// Pick a photo from camera or gallery, then call the edge function.
  Future<void> tryOn({
    required String garmentImageUrl,
    required ImageSource source,
  }) async {
    try {
      state = state.copyWith(status: TryOnStatus.pickingImage);

      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (picked == null) {
        // User cancelled
        state = state.copyWith(status: TryOnStatus.idle);
        return;
      }

      final personBytes = await picked.readAsBytes();
      state = state.copyWith(
        status: TryOnStatus.loading,
        personImageBytes: personBytes,
        resultImageBytes: null,
        errorMessage: null,
      );

      final personBase64 = base64Encode(personBytes);

      // Call the Supabase edge function
      final response = await supabase.functions.invoke(
        'try-on',
        body: {
          'personImageBase64': personBase64,
          'garmentImageUrl': garmentImageUrl,
        },
      );

      final data = response.data as Map<String, dynamic>?;

      if (data == null || data.containsKey('error')) {
        throw Exception(data?['error'] ?? 'Unknown error from try-on API');
      }

      final resultBase64 = data['imageBase64'] as String?;
      if (resultBase64 == null) throw Exception('No result image returned');

      final resultBytes = base64Decode(resultBase64);
      state = state.copyWith(
        status: TryOnStatus.success,
        resultImageBytes: resultBytes,
      );
    } on FunctionException catch (e) {
      state = state.copyWith(
        status: TryOnStatus.error,
        errorMessage: e.details?.toString() ?? 'Try-on service error',
      );
    } catch (e) {
      state = state.copyWith(
        status: TryOnStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void reset() => state = const TryOnState();
}

// One provider per product (auto-disposed when sheet closes)
final tryOnProvider =
    StateNotifierProvider.autoDispose<TryOnNotifier, TryOnState>(
  (ref) => TryOnNotifier(),
);
