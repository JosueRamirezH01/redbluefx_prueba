import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CenterFloatingButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const CenterFloatingButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {  // 👈 ConsumerWidget usa WidgetRef
    return Transform.translate(
      offset: const Offset(0, 16),
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF00A5FF),
              Color(0xFF004C8F),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF00A5FF).withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 6,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.trending_up, color: Colors.white, size: 25),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
