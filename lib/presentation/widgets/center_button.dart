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
    return Transform.translate(
      offset: const Offset(0, 16),
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Color(0xFF61CDFF),
              Color(0xFF005089),
            ],

          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.trending_up, color: Colors.white, size: 25),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
