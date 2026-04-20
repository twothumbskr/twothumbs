class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const admobAppIdAndroid = String.fromEnvironment('ADMOB_APP_ID_ANDROID');
  static const admobAppIdIos = String.fromEnvironment('ADMOB_APP_ID_IOS');
  static const admobBannerUnitIdAndroid = String.fromEnvironment('ADMOB_BANNER_UNIT_ID_ANDROID');
  static const admobBannerUnitIdIos = String.fromEnvironment('ADMOB_BANNER_UNIT_ID_IOS');

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
