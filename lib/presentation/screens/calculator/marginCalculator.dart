import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/margin_provider.dart';

class MarginProgressBar extends ConsumerWidget {
  final double percent;

  const MarginProgressBar({super.key, required this.percent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(marginStatusProvider(percent));

    final gradient = status.gradientColors.map((c) => Color(c)).toList();
    final percentText = '${(status.percent * 100).toStringAsFixed(1)}%';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Margen usado',
              style: TextStyle(color: Colors.black87),
            ),
            Text(
              status.label,
              style: TextStyle(
                color: gradient.first,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 🔹 Barra
        Row(
          children: [
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      height: 14,
                      color: Colors.blueGrey.shade800,
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: status.percent),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, __) {
                        return FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradient),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                percentText,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}