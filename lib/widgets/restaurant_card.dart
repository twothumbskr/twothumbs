import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import 'halal_badge.dart';
import 'thumbs_rating.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final RestaurantStats stats;
  final VoidCallback? onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.stats,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text('🍽️', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (restaurant.isHalal) ...[
                          const SizedBox(width: 6),
                          HalalBadge(certType: restaurant.halalCertType, compact: true),
                        ],
                      ],
                    ),
                    if (restaurant.category != null)
                      Text(
                        restaurant.category!,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                    const SizedBox(height: 6),
                    ThumbsRatingDisplay(stats: stats, compact: true),
                    if (restaurant.googleRating != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            '${restaurant.googleRating!.toStringAsFixed(1)} · Google',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
