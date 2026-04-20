import '../models/review.dart';
import 'supabase_service.dart';

class ReviewService {
  static final _client = SupabaseService.client;

  static Future<List<Review>> listForRestaurant(String restaurantId) async {
    final rows = await _client
        .from('reviews')
        .select()
        .eq('restaurant_id', restaurantId)
        .order('created_at', ascending: false)
        .limit(100);
    return (rows as List)
        .map((r) => Review.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  static Future<Review?> myReviewFor(String restaurantId) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('reviews')
        .select()
        .eq('restaurant_id', restaurantId)
        .eq('user_id', user.id)
        .maybeSingle();
    return row == null ? null : Review.fromJson(row);
  }

  static Future<void> submit({
    required String restaurantId,
    required ThumbsRating rating,
    String? comment,
    List<String> tags = const [],
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Not authenticated');
    await _client.from('reviews').upsert({
      'restaurant_id': restaurantId,
      'user_id': user.id,
      'rating': rating.value,
      'comment': comment,
      'tags': tags,
      // snap_country / snap_occupation / snap_gender / snap_age_bucket
      // are filled by DB trigger from profiles table
    }, onConflict: 'restaurant_id,user_id');
  }

  static Future<void> delete(String reviewId) async {
    await _client.from('reviews').delete().eq('id', reviewId);
  }
}
