import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redbluefx_mobile/core/theme/app_theme.dart';
import 'package:redbluefx_mobile/domain/entities/adverts.dart';

import 'advert_card.dart';


class AdvertPreviewDialog extends ConsumerStatefulWidget {
  final Advert advert;
  final File? image;
  final Future<void> Function() onConfirm;
  const AdvertPreviewDialog({
    super.key,
    required this.advert,
    required this.onConfirm,
    this.image
  });

  @override
  ConsumerState<AdvertPreviewDialog> createState() =>
      _AdvertPreviewDialogState();
}
class _AdvertPreviewDialogState extends ConsumerState<AdvertPreviewDialog> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 32,
        //vertical: 24,
      ),
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: 480,
              maxHeight: size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).previewColors,
              borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Theme.of(context).borderDialogPreview)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                _buildAlertCard(context, isSmallScreen),
                _buildActionButtons(context, isSmallScreen, isDark),
              ],
            ),
          ),
          Positioned(
            right: 1,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              color: Theme.of(context).textCardPreviewColors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Preview de anuncio de trading',
                    style: GoogleFonts.montserrat(fontSize: 19.5, fontWeight: FontWeight.w500)
                ),
                const SizedBox(height: 4),
                Text(
                    'Esto verán los usuarios',
                    style: GoogleFonts.montserrat(fontSize: 16)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AdvertsCard(
        advert: widget.advert,
        imagePreview: widget.image,
         toolTips: true,
         //onTap: () => context.push('/alerts/${alert.id}'),
        //onEdit: () => context.push('/alerts/${alert.id}/edit'),
        /*onDelete: () async {
          try {
            await ref.read(alertsProvider.notifier).deleteAlert(alert.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alerta eliminada correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e, stack) {
            AppLogger.error('Error al eliminar alerta: $e', error: e, stackTrace: stack);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al eliminar la alerta'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },*/
      ),
    );
  }
  Widget _buildActionButtons(BuildContext context, bool isSmallScreen, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal:isSmallScreen ? 30 : 40, vertical: isSmallScreen ? 12 : 18 ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.18,
              height: MediaQuery.of(context).size.height * 0.05,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Acción para editar
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  side: BorderSide(color: Colors.grey.shade300, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Editar',
                  style: TextStyle(
                    color: Theme.of(context).textCardPreviewColors,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.18,
              height: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [
                Color(0xFFFF1B21),
                Color(0xFFDD0E13),
                Color(0xFFBB0004)
              ]),
                boxShadow: [
                  if(!isDark)
                    const BoxShadow(
                        color: Color(0xFFFF1B21),
                        blurRadius: 10,      // intensidad
                        offset: Offset(0, 6) // altura
                    ),
                  const BoxShadow(
                      color: Color(0xFF721723),
                      blurRadius: 10,      // intensidad
                      offset: Offset(0, 6) // altura
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await widget.onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child:  const  Row(
                  children: [
                    Text(
                      'Sí, Publicar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.trending_up, size: 22,)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}