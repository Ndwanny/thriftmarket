/// App configuration — replace placeholder values with your real credentials.
///
/// Supabase:  https://supabase.com → New project → Settings → API
/// Cloudflare R2:  Cloudflare dashboard → R2 → Manage R2 API tokens
class AppConfig {
  AppConfig._();

  // ── Supabase ──────────────────────────────────────────────────────────────
  /// Project URL  (e.g. https://xyzabc.supabase.co)
  static const String supabaseUrl = 'https://vvmrxyyhmrlgephfdiaw.supabase.co';

  /// Anon / public key from Settings → API
  static const String supabaseAnonKey = 'sb_publishable_--EqYMGmBzticx5zimqAJA_C_2hCvs6';

  // ── Cloudflare R2 ─────────────────────────────────────────────────────────
  /// Your Cloudflare account ID  (found in the right sidebar of any R2 page)
  static const String r2AccountId = 'b82ab65dfc4fa451e471416c781b562c';

  /// R2 bucket name
  static const String r2BucketName = 'marketplace-media';

  /// R2 Access Key ID  (from Manage R2 API Tokens → Create Token)
  static const String r2AccessKeyId = '587d9ad5a3186edc9b38b12a23488311';

  /// R2 Secret Access Key
  static const String r2SecretAccessKey = '9103e2de427bd4a2ce0af31b34d3e079677d01cd7b22f38075e3c80e471ea1a3';

  /// Public URL for the bucket (set after enabling "Public access" on the bucket)
  /// e.g.  https://pub-xxxx.r2.dev   or your custom domain
  static const String r2PublicBaseUrl = 'https://pub-d82f57ecaa6f4ec0b361a06c38db730e.r2.dev';

  // ── Derived ───────────────────────────────────────────────────────────────
  static String get r2Endpoint =>
      'https://$r2AccountId.r2.cloudflarestorage.com';

  static bool get isSupabaseConfigured =>
      !supabaseUrl.contains('YOUR_PROJECT') &&
      !supabaseAnonKey.contains('YOUR_SUPABASE');

  static bool get isR2Configured =>
      !r2AccountId.contains('YOUR_CLOUDFLARE') &&
      !r2AccessKeyId.contains('YOUR_R2');
}
