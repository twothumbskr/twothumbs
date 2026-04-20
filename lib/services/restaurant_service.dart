import '../models/restaurant.dart';
import 'supabase_service.dart';

class RestaurantService {
  static final _client = SupabaseService.client;

  static Future<List<Restaurant>> list({
    bool halalOnly = false,
    String? category,
    int limit = 50,
  }) async {
    var q = _client.from('restaurants').select();
    if (halalOnly) q = q.eq('is_halal', true);
    if (category != null) q = q.eq('category', category);
    final rows = await q.limit(limit);
    return (rows as List)
        .map((r) => Restaurant.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  static Future<Restaurant?> byId(String id) async {
    final row = await _client
        .from('restaurants')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Restaurant.fromJson(row);
  }

  static Future<RestaurantStats> statsFor(String id) async {
    final row = await _client
        .from('restaurant_stats')
        .select()
        .eq('restaurant_id', id)
        .maybeSingle();
    return row == null
        ? RestaurantStats.empty(id)
        : RestaurantStats.fromJson(row);
  }

  /// Demographic-scoped stats. Returns null when sample is below threshold.
  static Future<({int n, double score})?> statsForDemographic({
    required String restaurantId,
    required String country,
    String? gender,
    String? ageBucket,
    int minN = 5,
  }) async {
    var q = _client
        .from('restaurant_stats_demo')
        .select('n, score')
        .eq('restaurant_id', restaurantId)
        .eq('snap_country', country);
    if (gender != null) q = q.eq('snap_gender', gender);
    if (ageBucket != null) q = q.eq('snap_age_bucket', ageBucket);

    final rows = await q;
    if ((rows as List).isEmpty) return null;
    // Aggregate across matching demographic slices
    int n = 0;
    double sum = 0;
    for (final r in rows) {
      final nn = r['n'] as int;
      n += nn;
      sum += (r['score'] as num).toDouble() * nn;
    }
    if (n < minN) return null;
    return (n: n, score: sum / n);
  }
}
