import 'package:flutter/material.dart';

class HalalBadge extends StatelessWidget {
  final String? certType;
  final bool compact;

  const HalalBadge({super.key, required this.certType, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final info = _infoFor(certType);
    if (info == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 5,
      ),
      decoration: BoxDecoration(
        color: info.$1.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: info.$1, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🕌', style: TextStyle(fontSize: compact ? 12 : 14)),
          const SizedBox(width: 4),
          Text(
            info.$2,
            style: TextStyle(
              color: info.$1,
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static (Color, String)? _infoFor(String? type) => switch (type) {
        'certified' => (const Color(0xFF2E7D32), 'Halal Certified'),
        'self-reported' => (const Color(0xFFF9A825), 'Halal (self-reported)'),
        'muslim-friendly' => (const Color(0xFFEF6C00), 'Muslim-friendly'),
        _ => null,
      };
}
