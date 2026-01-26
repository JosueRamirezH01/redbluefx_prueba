import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redbluefx_mobile/domain/entities/adverts.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdvertsCard extends ConsumerWidget {
  final Advert advert;
  final VoidCallback? onTap;
  final File? imagePreview;
  final bool? toolTips;
  const AdvertsCard({
    super.key,
    required this.advert,
    this.toolTips = false,
    this.onTap,
    this.imagePreview,

  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 2,
      color: advert.isFeatured ?  Colors.transparent : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Imagen de fondo estática
          if(advert.isFeatured)
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
          SizedBox(
            height: screenWidth * 0.28,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 6),

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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            advert.title,
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              color: advert.isFeatured ? Colors.white : Colors.black87,
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
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: toolTips == true
                                  ? () => _showContentDialog(context)
                                  : null,
                              onLongPress: toolTips == true
                                  ? () => _showContentDialog(context)
                                  : null,
                              child: Text(
                                advert.content,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: advert.isFeatured ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),


                          Row(
                            children: [
                              Text(
                                timeago.format(advert.createdAt, locale: 'es'),
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: advert.isFeatured ? Colors.white : Colors.black87,

                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.8),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if(advert.isFeatured)
                                const Icon(Icons.star, color: Colors.yellow)

                            ],
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
          ),
        ],
      ),
    );
  }
  void _showContentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          advert.title,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Text(
            advert.content,
            style: GoogleFonts.montserrat(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }


  Widget _buildImage(double finalSize) {
    if (advert.image == null || advert.image!.isEmpty) {
      return _defaultImage(finalSize);
    }

    return Image.network(
      advert.image!,
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