import 'package:flutter/material.dart';

class MirrorEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final BorderRadius borderRadius;
  final bool repeat;

  const MirrorEffect({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 5),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.repeat = true,
  });

  @override
  State<MirrorEffect> createState() => _MirrorEffectState();
}

class _MirrorEffectState extends State<MirrorEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    widget.repeat ? _controller.repeat() : _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          widget.child,

          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1.5 + (_controller.value * 3), -1),
                        end: Alignment(-0.5 + (_controller.value * 3), 1),
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.4),
                          Colors.white.withValues(alpha: 0.7),
                          Colors.white.withValues(alpha: 0.4),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                        stops: const [0.25,0.35, 0.5, 0.65,0.85],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}