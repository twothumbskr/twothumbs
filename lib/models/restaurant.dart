class Restaurant {
  final String id;
  final String googlePlaceId;
  final String name;
  final String? address;
  final double? lat;
  final double? lng;
  final String? phone;
  final String? category;
  final bool isHalal;
  final String? halalCertType;
  final double? googleRating;
  final int? googleReviewCount;
  final List<String> photoRefs;

  const Restaurant({
    required this.id,
    required this.googlePlaceId,
    required this.name,
    this.address,
    this.lat,
    this.lng,
    this.phone,
    this.category,
    this.isHalal = false,
    this.halalCertType,
    this.googleRating,
    this.googleReviewCount,
    this.photoRefs = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'] as String,
        googlePlaceId: json['google_place_id'] as String,
        name: json['name'] as String,
        address: json['address'] as String?,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        phone: json['phone'] as String?,
        category: json['category'] as String?,
        isHalal: json['is_halal'] as bool? ?? false,
        halalCertType: json['halal_cert_type'] as String?,
        googleRating: (json['google_rating'] as num?)?.toDouble(),
        googleReviewCount: json['google_review_count'] as int?,
        photoRefs: (json['photo_refs'] as List?)?.cast<String>() ?? const [],
      );
}

class RestaurantStats {
  final String restaurantId;
  final int n;
  final int nDoubleUp;
  final int nUp;
  final int nDown;
  final int nDoubleDown;
  final double score;

  const RestaurantStats({
    required this.restaurantId,
    required this.n,
    required this.nDoubleUp,
    required this.nUp,
    required this.nDown,
    required this.nDoubleDown,
    required this.score,
  });

  const RestaurantStats.empty(this.restaurantId)
      : n = 0,
        nDoubleUp = 0,
        nUp = 0,
        nDown = 0,
        nDoubleDown = 0,
        score = 0;

  factory RestaurantStats.fromJson(Map<String, dynamic> json) => RestaurantStats(
        restaurantId: json['restaurant_id'] as String,
        n: json['n'] as int,
        nDoubleUp: json['n_double_up'] as int? ?? 0,
        nUp: json['n_up'] as int? ?? 0,
        nDown: json['n_down'] as int? ?? 0,
        nDoubleDown: json['n_double_down'] as int? ?? 0,
        score: (json['score'] as num?)?.toDouble() ?? 0,
      );

  double pct(int count) => n == 0 ? 0 : count / n;
}
