import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redbluefx/core/theme/app_theme.dart';

import '../../domain/entities/alert.dart';
import 'alert_card.dart';

class TradingAlertPreviewDialog extends ConsumerStatefulWidget {
  final Alert alert;
  final File? image;
  final Future<void> Function() onConfirm;
  const TradingAlertPreviewDialog({
    super.key,
    required this.alert,
    required this.onConfirm,
    this.image
  });

  @override
  ConsumerState<TradingAlertPreviewDialog> createState() =>
      _TradingAlertPreviewDialogState();
}
class _TradingAlertPreviewDialogState extends ConsumerState<TradingAlertPreviewDialog> {
  int? expandedIndex;
  int? expandedDetailsIndex;


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
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).previewColors,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).borderDialogPreview)
        ),
        child: Stack(
          children: [
            Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              _buildAlertCard(context, isSmallScreen),
              _buildActionButtons(context, isSmallScreen, isDark),
              const SizedBox(height: 12)

            ],
          ),
            Positioned(
              right: 1,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                color: Theme.of(context).textCardPreviewColors,
              ),
            ),
        ]
        ),
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
                  'Preview de Señal de trading',
                  style: GoogleFonts.montserrat(fontSize: 19.5, fontWeight: FontWeight.w600)
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
      child: AlertCard(
        alert: widget.alert,
        index: 1,
        imagePreview: widget.image,
        expandedIndex: expandedIndex,
        expandedDetailsIndex: expandedDetailsIndex,
        borde: true,
        onExpandDetailsChange: (value) {
          setState(() {
            // Si se está abriendo un nuevo card diferente, cierra el TP del anterior
            if (value != null && value != expandedDetailsIndex && expandedIndex != null && expandedIndex != value) {
              expandedIndex = null;
            }
            expandedDetailsIndex = value;
          });
        },
        onExpandChange: (value) {
          setState(() {
            if (value != null && value != expandedIndex && expandedDetailsIndex != null && expandedDetailsIndex != value) {
              expandedDetailsIndex = null;
            }
            expandedIndex = value;
          });
        },
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
      padding: EdgeInsets.symmetric(horizontal:isSmallScreen ? 30 : 40),
      child: Row(
        children: [
          Expanded(
            flex: 2,
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
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [
                Color(0xFFFF1B21),
                Color(0xFFDD0E13),
                Color(0xFFBB0004)
              ]),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).colorBtnProfile,
                      blurRadius: 16,      // intensidad
                      offset: const Offset(0, 6) // altura
                  ),
                ],borderRadius: BorderRadius.circular(8),),
              child: ElevatedButton(
                onPressed: () async {
                  // ✅ 1. Quitar foco de cualquier TextField activo
                  FocusScope.of(context).unfocus();

                  // ✅ 2. Ejecutar la acción de guardar
                  await widget.onConfirm();

                  // ✅ 3. Cerrar el diálogo
                  if (mounted) Navigator.of(context).pop();
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
                        fontSize: 15,
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