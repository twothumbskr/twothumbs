enum ThumbsRating {
  doubleUp(2, '👍👍', 'Must visit'),
  up(1, '👍', 'Worth visiting'),
  down(-1, '👎', 'Only if hungry'),
  doubleDown(-2, '👎👎', "Don't go");

  final int value;
  final String emoji;
  final String label;
  const ThumbsRating(this.value, this.emoji, this.label);

  static ThumbsRating fromValue(int v) =>
      ThumbsRating.values.firstWhere((r) => r.value == v);
}

class Review {
  final String id;
  final String restaurantId;
  final String userId;
  final ThumbsRating rating;
  final String? comment;
  final List<String> tags;
  final List<String> photos;
  final String snapCountry;
  final String snapOccupation;
  final String snapGender;
  final String? snapAgeBucket;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.rating,
    this.comment,
    this.tags = const [],
    this.photos = const [],
    required this.snapCountry,
    required this.snapOccupation,
    required this.snapGender,
    this.snapAgeBucket,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        restaurantId: json['restaurant_id'] as String,
        userId: json['user_id'] as String,
        rating: ThumbsRating.fromValue(json['rating'] as int),
        comment: json['comment'] as String?,
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
        photos: (json['photos'] as List?)?.cast<String>() ?? const [],
        snapCountry: json['snap_country'] as String,
        snapOccupation: json['snap_occupation'] as String,
        snapGender: json['snap_gender'] as String,
        snapAgeBucket: json['snap_age_bucket'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
