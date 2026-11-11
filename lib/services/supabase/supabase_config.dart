/// Project connection details. The publishable key is designed to ship inside
/// apps: what it can do is limited by the database's security rules.
/// Never put the service-role key or any LiveKit secret here.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vctdkitastvopatlwkhc.supabase.co',
  );
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_RktzXaKLDMuHxNY2jGwpGw_wcOwlIqC',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
