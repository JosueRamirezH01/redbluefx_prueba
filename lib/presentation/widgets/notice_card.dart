import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redbluefx_mobile/core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/notice.dart';

class NoticeCard extends ConsumerWidget {
  final Notice notice;
  final VoidCallback? onTap;

  const NoticeCard({
    super.key,
    required this.notice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final imageSize = screenWidth * 0.25;
                        final finalSize = imageSize.clamp(100.0, 120.0);

                        // Si no hay URL de imagen, mostramos placeholder
                        if (notice.image == null || notice.image!.isEmpty) {
                          return _placeholder(finalSize);
                        }

                        return Image.network(
                          notice.image!,
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

                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTypeChip(),
                        const SizedBox(height: 6),
                        Text(
                            notice.title,
                            style: GoogleFonts.montserrat(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w500,

                            )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Text(
                    _formatDate(notice.createdAt),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward,
                    color: theme.linkColor,
                    size: 16,
                  ),
                ],
              ),
            ],

          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
        border: Border.all(color: const Color(0xFF004E87)),
      ),
      child:  Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            notice.category.name,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),

        ],
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
      child: Icon(
        broken ? Icons.broken_image : Icons.show_chart,
        color: const Color(0xFF066BAF),
        size: size * 0.4,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return AppDateUtils.formatToPeruTime(date);
  }
}
