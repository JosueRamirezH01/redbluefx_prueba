import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/svg.dart';
import 'package:redbluefx_mobile/core/theme/app_theme_backup.dart';
import '../providers/alert_provider.dart';
import 'alert_card.dart';

class AlertList extends ConsumerStatefulWidget {
  const AlertList({super.key});

  @override
  ConsumerState<AlertList> createState() => _AlertListState();
}
class _AlertListState extends ConsumerState<AlertList> {
  int? expandedIndex;
  int? expandedDetailsIndex;

  @override
  Widget build(BuildContext context) {
    final alertsState = ref.watch(alertsProvider);

    if (alertsState.isLoading && alertsState.alerts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (alertsState.error != null && alertsState.alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar las alertas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(alertsProvider.notifier).loadAlerts(refresh: true),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (alertsState.alerts.isEmpty) {
      return FadeIn(
        duration: const Duration(milliseconds: 500),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/lupa.svg',
                width: 90,
                height: 90,

              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron señales',
                style: AppTextStyles.titleLarge
              ),
              const SizedBox(height: 12),
              Text(
                  'Intenta con otro término de búsqueda',
                  style: AppTextStyles.bodyMedium
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: alertsState.alerts.length,
      itemBuilder: (context, index) {
        final alert = alertsState.alerts[index];
        return SlideInDown(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: AlertCard(
            alert: alert,
            index: index,
            expandedIndex: expandedIndex,
            expandedDetailsIndex: expandedDetailsIndex,
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
      },
    );
  }
} 