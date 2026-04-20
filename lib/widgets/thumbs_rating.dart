import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../models/review.dart';

/// Big picker for writing a review. Calls [onChanged] when selection changes.
class ThumbsRatingInput extends StatelessWidget {
  final ThumbsRating? selected;
  final ValueChanged<ThumbsRating> onChanged;

  const ThumbsRatingInput({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ThumbsRating.values.map((r) {
        final isSelected = selected == r;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChanged(r),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? _colorFor(r).withValues(alpha: 0.15) : null,
                border: Border.all(
                  color: isSelected ? _colorFor(r) : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(r.emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      r.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected) Icon(Icons.check_circle, color: _colorFor(r)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Horizontal breakdown bar showing % distribution of ratings.
class ThumbsRatingDisplay extends StatelessWidget {
  final RestaurantStats stats;
  final bool compact;

  const ThumbsRatingDisplay({
    super.key,
    required this.stats,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.n == 0) {
      return Text(
        'No reviews yet',
        style: TextStyle(color: Colors.grey.shade600, fontSize: compact ? 12 : 14),
      );
    }

    final bars = [
      (ThumbsRating.doubleUp, stats.nDoubleUp),
      (ThumbsRating.up, stats.nUp),
      (ThumbsRating.down, stats.nDown),
      (ThumbsRating.doubleDown, stats.nDoubleDown),
    ];

    if (compact) {
      final topPct = (stats.pct(stats.nDoubleUp) * 100).round();
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👍👍', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text('$topPct%',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(width: 6),
          Text('· ${stats.n} reviews',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 16,
            child: Row(
              children: bars.map((b) {
                final pct = stats.pct(b.$2);
                if (pct == 0) return const SizedBox.shrink();
                return Expanded(
                  flex: (pct * 1000).round(),
                  child: Container(color: _colorFor(b.$1)),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: bars.map((b) {
            final pct = (stats.pct(b.$2) * 100).round();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: _colorFor(b.$1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text('${b.$1.emoji} $pct%',
                    style: const TextStyle(fontSize: 13)),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Text('Based on ${stats.n} review${stats.n == 1 ? '' : 's'}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}

Color _colorFor(ThumbsRating r) => switch (r) {
      ThumbsRating.doubleUp => const Color(0xFF2E7D32),
      ThumbsRating.up => const Color(0xFF81C784),
      ThumbsRating.down => const Color(0xFFFFA726),
      ThumbsRating.doubleDown => const Color(0xFFE53935),
    };
