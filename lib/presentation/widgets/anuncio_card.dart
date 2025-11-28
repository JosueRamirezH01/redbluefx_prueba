import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/alert.dart';
import '../../core/utils/date_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnuncioCard extends ConsumerWidget {
  final Alert alert;
  final VoidCallback? onTap;

  const AnuncioCard({
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final imageSize = screenWidth * 0.25;
                      final finalSize = imageSize.clamp(100.0, 120.0);
                      return _buildImage(finalSize);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text('Análisis semanal del mercado', style: GoogleFonts.montserrat(
                    fontSize: 15
                  ),
                    maxLines: 2,
                  ),
                    Text('Perspectivas y estrategías recomendadas', style: GoogleFonts.montserrat(
                        fontSize: 15
                    ),),
                    Text(
                      timeago.format(alert.createdAt, locale: 'es'),
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                      ),
                    ),
                ],),
              )
            ],
          ),
        ),
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


  String _formatDate(DateTime date) {
    return AppDateUtils.formatToPeruTime(date);
  }
}
