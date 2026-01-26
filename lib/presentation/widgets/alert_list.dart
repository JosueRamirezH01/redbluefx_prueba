import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/alert.dart';
import '../providers/alert_provider.dart';
import '../providers/auth_provider.dart';
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
    final authState = ref.watch(authStateProvider);
    final isAdmin = authState.currentUser?.role == 'admin';
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
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.srgbToLinearGamma(),
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron señales',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                )
              ),
              const SizedBox(height: 12),
              Text(
                  'Intenta con otro término de búsqueda',
                  style:GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  )
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
          child: isAdmin ? Dismissible(
            key: Key(alert.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade700,
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar alerta'),
                  content: const Text('¿Estás seguro de que deseas eliminar esta alerta?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) async {
              try {
                  await ref.read(alertsProvider.notifier).deleteAlert(alert.id);
                  Fluttertoast.showToast(
                    msg: "Alerta eliminado correctamente",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 14,
                  );
                } catch (e, stack) {
                  AppLogger.error('Error al eliminar alerta: $e', error: e, stackTrace: stack);
                  Fluttertoast.showToast(
                    msg: "Error al eliminar el alerta",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 14,
                  );
                }
            },
            child: _buildAlertCard(alert, index),
          ) :  _buildAlertCard(alert, index),
        );
      },
    );
  }
  Widget _buildAlertCard(Alert alert, int index) {
    return AlertCard(
      alert: alert,
      index: index,
      expandedIndex: expandedIndex,
      expandedDetailsIndex: expandedDetailsIndex,
      onExpandDetailsChange: (value) {
        setState(() {
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
    );
  }

} 