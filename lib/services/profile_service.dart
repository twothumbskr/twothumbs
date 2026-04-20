import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class ProfileService {
  static SupabaseClient get _client => SupabaseService.client;

  static Future<Map<String, dynamic>?> fetchCurrent() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }

  static Future<void> upsert({
    required String countryCode,
    required String occupation,
    required String gender,
    String? ageBucket,
    bool needsHalal = false,
    String preferredLang = 'en',
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Not authenticated');
    await _client.from('profiles').upsert({
      'id': user.id,
      'country_code': countryCode,
      'occupation': occupation,
      'gender': gender,
      'age_bucket': ageBucket,
      'needs_halal': needsHalal,
      'preferred_lang': preferredLang,
    });
  }
}
