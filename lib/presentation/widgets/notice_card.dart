import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/alert.dart';
import '../../core/utils/date_utils.dart';

class NoticeCard extends ConsumerWidget {
  final Alert alert;
  final VoidCallback? onTap;

  const NoticeCard({
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

                        // Limitar para que no se vea ni muy grande ni muy pequeño
                        final finalSize = imageSize.clamp(100.0, 120.0);

                        return Image.asset(
                          'assets/images/notice.png',
                          width: finalSize,
                          height: finalSize,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: finalSize,
                              height: finalSize,
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.show_chart,
                                color: Colors.green.shade300,
                                size: finalSize * 0.4,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        'EURUSD: el euro cede terreno tras la tregua comercial entre EE. UU. y China',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,

                        )
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [

                  Text(
                    _formatDate(alert.createdAt),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Ver detalles →",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: const Color(0xFF036BAF),
                      fontWeight: FontWeight.w500,
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade200,
        border: Border.all(color: const Color(0xFF004E87)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Noticias',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.arrow_upward,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return AppDateUtils.formatToPeruTime(date);
  }
}
