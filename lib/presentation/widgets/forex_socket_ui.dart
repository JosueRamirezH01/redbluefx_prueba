import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/forex_socket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/forex_provider.dart';

class ForexTicker extends ConsumerStatefulWidget {
  const ForexTicker({super.key});

  @override
  ConsumerState<ForexTicker> createState() => _ForexTickerState();
}

class _ForexTickerState extends ConsumerState<ForexTicker>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final prices = ref.watch(forexProvider);
    final notifier = ref.read(forexProvider.notifier);
    final previousPrices = notifier.previousPrices;

    if (prices.isEmpty) {
      return  SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        child: const Center(
          child: Text("Cargando mercado...",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      color: const Color(0xFF0D1D35),
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {

            final width = MediaQuery.of(context).size.width;

            return Transform.translate(
              offset: Offset(-_controller.value * width * 4, 0),
              child: OverflowBox(
                maxWidth: double.infinity,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    _buildTickerContent(prices, previousPrices),
                    _buildTickerContent(prices, previousPrices),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTickerContent(Map<String, double> prices, Map<String, double> previousPrices,) {
    return Row(
      children: prices.entries.map((entry) {

        final pair = entry.key;
        final price = entry.value;
        final oldPrice = previousPrices[pair] ?? price;

        final isUp = price > oldPrice;
        final isDown = price < oldPrice;

        final color = isUp ? const Color(0xFF10B981) : isDown ? const Color(0xFFE6332F) : const Color(0xFFAFDDFC);

        final icon = isUp ? Icons.arrow_upward : isDown ? Icons.arrow_downward : Icons.remove;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(pair, style: GoogleFonts.montserrat(color: const Color(0xFFF0F0F0))),

              const SizedBox(width: 6),

              Icon(icon, color: color, size: 14),

              const SizedBox(width: 4),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  price.toStringAsFixed(5),
                  key: ValueKey(price),
                  style: GoogleFonts.montserrat(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 10),
              Container(width: 1, height: 15, color: const Color(0xFFF0F0F0)),
            ],
          ),
        );
      }).toList(),
    );
  }
}