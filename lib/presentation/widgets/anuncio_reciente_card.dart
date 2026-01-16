import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redbluefx_mobile/core/theme/app_theme.dart';
import 'package:redbluefx_mobile/domain/entities/adverts.dart';
import '../../core/utils/date_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdvertRecentCard extends ConsumerWidget {
  final Advert advert;
  final VoidCallback? onTap;
  final File? imagePreview;
  const AdvertRecentCard({
    super.key,
    required this.advert,
    this.onTap,
    this.imagePreview,

  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenWidth * 0.34,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).borderCardPreviewColors)
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final imageSize = screenWidth * 0.2;
                        final finalSize = imageSize.clamp(100.0, 120.0);
                        if (imagePreview != null) {
                          return Image.file(
                            imagePreview!,
                            width: finalSize,
                            height: finalSize,
                            fit: BoxFit.cover,
                          );
                        }
                        // Si no hay URL de imagen, mostramos placeholder
                        if (advert.imageUrl == null || advert.imageUrl!.isEmpty) {
                          return _placeholder(finalSize);
                        }

                        return Image.network(
                          advert.imageUrl!,
                          width: finalSize,
                          height: finalSize,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              width: finalSize,
                              height: finalSize,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _placeholder(finalSize, broken: true);
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text( advert.title, style: GoogleFonts.montserrat(
                      fontSize: 15, fontWeight: FontWeight.w500
                    ),
                      maxLines: 2,
                    ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            advert.content,
                            style: GoogleFonts.montserrat(fontSize: 14),
                          ),
                        ),
                      ),

                      Text(
                        timeago.format(advert.createdAt, locale: 'es'),
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                        ),
                      ),
                  ],),
                ),
                const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFF066BAF))
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _placeholder(double size, {bool broken = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF066BAF).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
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


  String truncateText(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  String _formatDate(DateTime date) {
    return AppDateUtils.formatToPeruTime(date);
  }
}
