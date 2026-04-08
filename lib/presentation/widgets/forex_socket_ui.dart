import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/forex_provider.dart';

class ForexTicker extends ConsumerStatefulWidget {
  const ForexTicker({super.key});

  @override
  ConsumerState<ForexTicker> createState() => _ForexTickerState();
}

class _ForexTickerState extends ConsumerState<ForexTicker>
    with SingleTickerProviderStateMixin {
  bool _isScrolling = false;
  late ScrollController _scrollController;
  @override
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  void _startScrolling() async {
    if (_isScrolling) return; // 🔥 evita duplicados
    _isScrolling = true;

    await Future.delayed(const Duration(milliseconds: 500));

    while (mounted) {
      if (!_scrollController.hasClients) break;

      final maxScroll = _scrollController.position.maxScrollExtent;

      if (maxScroll == 0) {
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }

      const speed = 40.0;

      final duration = Duration(
        milliseconds: (maxScroll / speed * 1000).toInt(),
      );

      await _scrollController.animateTo(
        maxScroll,
        duration: duration,
        curve: Curves.linear,
      );

      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final prices = ref.watch(forexProvider);
    final notifier = ref.read(forexProvider.notifier);
    final previousPrices = notifier.previousPrices;

    if (prices.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent > 0) {
          _startScrolling();
        }
      });
    }

    if (prices.isEmpty) {
      return  SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        child: const Center(
          child: Text("Cargando mercado...",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.05,
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        children: [
          _buildTickerContent(prices, previousPrices),
          _buildTickerContent(prices, previousPrices),
        ],
      ),
    );
  }

  Widget _buildTickerContent(Map<String, double> prices, Map<String, double> previousPrices,) {
    return Row(
      children: prices.entries.map((entry) {

        final pair = entry.key;
        final price = entry.value;
        final oldPrice = previousPrices[pair] ?? price;

        final difference = price - oldPrice;
        final percent = oldPrice != 0 ? (difference / oldPrice) * 100 : 0;

        final diffText = difference >= 0 ? "+${difference.toStringAsFixed(5)}" : difference.toStringAsFixed(5);
        final percentText = percent >= 0 ? "+${percent.toStringAsFixed(2)}%" : "${percent.toStringAsFixed(2)}%";

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
              const SizedBox(width: 2),
            /*  Text(
                "$percentText ($diffText)",
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: color.withOpacity(0.8),
                ),
              ),*/
              const SizedBox(width: 6),
              Container(width: 1, height: 15, color: const Color(0xFFF0F0F0)),
            ],
          ),
        );
      }).toList(),
    );
  }
}