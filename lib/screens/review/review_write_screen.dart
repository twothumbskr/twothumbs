import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/review.dart';
import '../../services/review_service.dart';

const _availableTags = [
  'Spicy', 'Cheap eats', 'Solo-friendly', 'Group-friendly',
  'Great view', 'Late night', 'English menu', 'Quick service',
];

class ReviewWriteScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  const ReviewWriteScreen({super.key, required this.restaurantId});

  @override
  ConsumerState<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends ConsumerState<ReviewWriteScreen> {
  ThumbsRating? _selected;
  final _commentCtrl = TextEditingController();
  final Set<String> _tags = {};
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selected == null) return;
    setState(() { _busy = true; _error = null; });
    try {
      await ReviewService.submit(
        restaurantId: widget.restaurantId,
        rating: _selected!,
        comment: _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
        tags: _tags.toList(),
      );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write a review')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('How was it?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...ThumbsRating.values.map((r) {
            final isSelected = _selected == r;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _selected = r),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _colorFor(r).withValues(alpha: 0.15)
                        : null,
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
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: _colorFor(r)),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          const Text('Tell us more (optional)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Your honest take helps fellow travelers...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tags (optional)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _availableTags.map((t) {
              final selected = _tags.contains(t);
              return FilterChip(
                label: Text(t),
                selected: selected,
                onSelected: (v) => setState(
                    () => v ? _tags.add(t) : _tags.remove(t)),
              );
            }).toList(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: (_busy || _selected == null) ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit review'),
          ),
        ],
      ),
    );
  }
}

Color _colorFor(ThumbsRating r) => switch (r) {
      ThumbsRating.doubleUp => const Color(0xFF2E7D32),
      ThumbsRating.up => const Color(0xFF81C784),
      ThumbsRating.down => const Color(0xFFFFA726),
      ThumbsRating.doubleDown => const Color(0xFFE53935),
    };
