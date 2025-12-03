import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/alert.dart';
import '../../core/utils/date_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnuncioDestacadoCard extends ConsumerWidget {
  final Alert alert;
  final VoidCallback? onTap;

  const AnuncioDestacadoCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Imagen de fondo estática
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/fondoCard.png',
                fit: BoxFit.cover,
              ),
            ),
          ),


          // Contenido encima
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final imageSize = screenWidth * 0.25;
                          final finalSize = imageSize.clamp(70.0, 76.0);
                          return _buildImage(finalSize);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Análisis semanal del mercado',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 2,
                        ),
                        Text(
                          'Perspectivas y estrategías recomendadas',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.95),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          timeago.format(alert.createdAt, locale: 'es'),
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: Color(0xFF5EBCFF),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(double finalSize) {
    if (alert.imageUrl == null || alert.imageUrl!.isEmpty) {
      return _defaultImage(finalSize);
    }

    return Image.network(
      alert.imageUrl!,
      width: finalSize,
      height: finalSize,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _defaultImage(finalSize);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: finalSize,
          height: finalSize,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }

  Widget _defaultImage(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE6F2FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Image.asset(
          'assets/icons/icon_anuncio.png',
          width: size * 0.3,
          height: size * 0.3,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}