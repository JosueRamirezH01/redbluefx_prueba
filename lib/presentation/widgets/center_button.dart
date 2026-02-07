import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CenterFloatingButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const CenterFloatingButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = MediaQuery.of(context).size.height;
    return Transform.translate(
      offset: Offset(0, height * 0.035),
      child: Material(
        elevation: 10,
        shape: const CircleBorder(),
        shadowColor: Colors.black54,
        color: Colors.transparent,
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFF61CDFF),
                Color(0xFF005089),
              ],
            ),
            border: isDark
                ? Border.all(
              color: Colors.white,
              width: 1.5,
            )
                : null,
          ),
          child: IconButton(
            icon: const Icon(Icons.trending_up, color: Colors.white, size: 25),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
