import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/logger.dart';
import '../providers/notificacion_provider.dart';

class CardCarousel extends ConsumerStatefulWidget {
  final bool isSmall;

  const CardCarousel({super.key, this.isSmall = false});

  @override
  ConsumerState<CardCarousel> createState() => _CardCarouselState();
}

class _CardCarouselState extends ConsumerState<CardCarousel> {
  late PageController _carouselPageController;
  int _currentCarouselIndex = 0;
  @override
  void initState() {
    _carouselPageController = PageController();
    super.initState();
  }
  @override
  void dispose() {
    _carouselPageController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    final showCarousel = ref.watch(showNewsCarouselProvider);
    final newsItems = ref.watch(newsCarouselProvider);

    if (!showCarousel || newsItems.isEmpty) {
      return const SizedBox();
    } // Si está oculto, no se muestra


    return LayoutBuilder(
      builder: (context, constraints) {
        double cardHeight = constraints.maxWidth < 350 ? 135 : constraints.maxWidth < 500 ? 150 : 160;

        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: cardHeight,
                  child: PageView.builder(
                    controller: _carouselPageController,
                    itemCount: newsItems.length,
                    onPageChanged: (index) => setState(() => _currentCarouselIndex = index),
                    itemBuilder: (context, index) {
                      final item = newsItems[index];
                      AppLogger.debug("Imagen anuncio: ${item.image}");
                      AppLogger.debug("Imagen anuncio: ${item.imageUrl}");
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/fondoCard.png',
                                fit: BoxFit.fill,
                              ),

                              /// BOTÓN X PARA OCULTAR
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    ref.read(showNewsCarouselProvider.notifier).hide();
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),

                              // Contenido principal
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20,top: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildNewsImage(imageUrl: item.image, isSmall: widget.isSmall,),
                                    const SizedBox(width: 20),
                                    // Texto y botón
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: widget.isSmall ? 15 : 17,
                                              height: 1.2,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withValues(alpha: 0.5),
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 3,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            item.content,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.95),
                                              fontSize: widget.isSmall ? 14 : 14,
                                              height: 1.3,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withValues(alpha: 0.5),
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Flexible(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF005EA3),
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      side: BorderSide(
                                                        color: Colors.white.withValues(alpha: 0.4),
                                                        width: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    AppLogger.debug("Abrir anuncio ID: ${item.id}");
                                                    context.push(
                                                      '/anuncio/${item.id}',
                                                      extra: item,
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        'Ver detalles',
                                                        style: TextStyle(
                                                          fontSize: widget.isSmall ? 10 : 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 3),
                                                      const Icon(
                                                        Icons.arrow_forward,
                                                        size: 12,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                DateFormat('dd/MM').format(item.createdAt),
                                                style: TextStyle(
                                                  color: Colors.white.withValues(alpha: 0.85),
                                                  fontSize: widget.isSmall ? 10 : 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                /// Indicadores
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(newsItems.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentCarouselIndex == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentCarouselIndex == index
                            ? const Color(0xFF2E7EC2)
                            : const Color(0xFFB0BEC5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNewsImage({required String? imageUrl, required bool isSmall,}) {
    final size = isSmall ? 60.0 : 70.0;

    if (imageUrl == null || imageUrl.isEmpty) {
      return _placeholderImage(size);
    }

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspectiva
        ..rotateY(-0.4), // leve inclinación
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(4, 6),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: size,
                    height: size,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _placeholderImage(size);
                },
              ),
              /// brillo tipo vidrio
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _placeholderImage(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorCardPreview,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Image.asset(
          'assets/icons/icon_anuncio.png',
          width: size * 0.4,
          height: size * 0.4,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

}