import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redbluefx_mobile/domain/entities/alert.dart';

import 'alert_card.dart';

class TradingAlertPreviewDialog extends ConsumerStatefulWidget {
  final Alert alert;
  final Future<void> Function() onConfirm;
  const TradingAlertPreviewDialog({
    super.key,
    required this.alert,
    required this.onConfirm,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildAlertCard(context, isSmallScreen),
            _buildActionButtons(context, isSmallScreen),
          ],
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
                  'Preview de alerta',
                  style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w500)
                ),
                const SizedBox(height: 4),
                Text(
                  'Esto verán los usuarios',
                  style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade600)
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: Colors.grey[400],
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
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
  Widget _buildActionButtons(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Editar',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.18,
              height: MediaQuery.of(context).size.height * 0.05,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await widget.onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Sí, Publicar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}