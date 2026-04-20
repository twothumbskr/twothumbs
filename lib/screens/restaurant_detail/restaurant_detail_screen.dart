import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/restaurant.dart';
import '../../models/review.dart';
import '../../providers/providers.dart';
import '../../services/restaurant_service.dart';
import '../../services/review_service.dart';
import '../../widgets/halal_badge.dart';
import '../../widgets/thumbs_rating.dart';

final _detailProvider = FutureProvider.autoDispose.family<
    ({Restaurant restaurant, RestaurantStats stats, List<Review> reviews}),
    String>((ref, id) async {
  final r = await RestaurantService.byId(id);
  if (r == null) throw StateError('Restaurant not found');
  final results = await Future.wait([
    RestaurantService.statsFor(id),
    ReviewService.listForRestaurant(id),
  ]);
  return (
    restaurant: r,
    stats: results[0] as RestaurantStats,
    reviews: results[1] as List<Review>,
  );
});

final _myDemoStatsProvider = FutureProvider.autoDispose
    .family<({int n, double score})?, String>((ref, id) async {
  final profile = await ref.watch(profileProvider.future);
  if (profile == null) return null;
  return RestaurantService.statsForDemographic(
    restaurantId: id,
    country: profile['country_code'] as String,
    gender: profile['gender'] as String?,
    ageBucket: profile['age_bucket'] as String?,
  );
});

class RestaurantDetailScreen extends ConsumerWidget {
  final String id;
  const RestaurantDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_detailProvider(id));

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Error: $e')),
        ),
        data: (d) => _DetailView(
          restaurant: d.restaurant,
          stats: d.stats,
          reviews: d.reviews,
        ),
      ),
      floatingActionButton: async.maybeWhen(
        data: (_) => FloatingActionButton.extended(
          onPressed: () async {
            await context.push('/restaurant/$id/review');
            ref.invalidate(_detailProvider(id));
          },
          icon: const Icon(Icons.rate_review),
          label: const Text('Review'),
        ),
        orElse: () => null,
      ),
    );
  }
}

class _DetailView extends ConsumerWidget {
  final Restaurant restaurant;
  final RestaurantStats stats;
  final List<Review> reviews;

  const _DetailView({
    required this.restaurant,
    required this.stats,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoAsync = ref.watch(_myDemoStatsProvider(restaurant.id));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(restaurant.name),
            background: Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Text('🍽️', style: TextStyle(fontSize: 96)),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (restaurant.isHalal) ...[
                    HalalBadge(certType: restaurant.halalCertType),
                    const SizedBox(height: 12),
                  ],
                  if (restaurant.address != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.place, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(child: Text(restaurant.address!)),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (restaurant.phone != null)
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(restaurant.phone!),
                      ],
                    ),
                  const Divider(height: 32),
                  const Text('TwoThumbs rating',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ThumbsRatingDisplay(stats: stats),
                  const SizedBox(height: 20),
                  demoAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (d) => d == null
                        ? const SizedBox.shrink()
                        : _DemoStatsBox(n: d.n, score: d.score),
                  ),
                  if (restaurant.googleRating != null) ...[
                    const Divider(height: 32),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text(
                          '${restaurant.googleRating!.toStringAsFixed(1)} on Google',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (restaurant.googleReviewCount != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${restaurant.googleReviewCount} reviews)',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    ),
                  ],
                  const Divider(height: 32),
                  Text(
                    'Reviews (${reviews.length})',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (reviews.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Be the first to review.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  else
                    ...reviews.map((r) => _ReviewTile(review: r)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class _DemoStatsBox extends StatelessWidget {
  final int n;
  final double score;
  const _DemoStatsBox({required this.n, required this.score});

  @override
  Widget build(BuildContext context) {
    final label = score >= 1.5
        ? '🔥 Highly rated by people like you'
        : score >= 0.5
            ? '👍 Well-received by people like you'
            : score >= -0.5
                ? '🤷 Mixed reviews from people like you'
                : '👎 Not popular with people like you';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.groups, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'Based on $n reviews from your demographic',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(review.rating.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${review.snapCountry} · ${review.snapOccupation}',
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                if (review.comment != null && review.comment!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(review.comment!),
                  ),
                if (review.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 6,
                      children: review.tags
                          .map((t) => Chip(
                                label: Text(t),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
