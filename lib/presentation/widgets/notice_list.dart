import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:redbluefx_mobile/core/theme/app_theme_backup.dart';
import 'package:redbluefx_mobile/presentation/widgets/notice_card.dart';
import '../providers/alert_provider.dart';
import '../../../core/utils/logger.dart';

class NoticeList extends ConsumerStatefulWidget {
  const NoticeList({super.key});

  @override
  ConsumerState<NoticeList> createState() => _NoticeListState();
}
class _NoticeListState extends ConsumerState<NoticeList> {

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
      padding: const EdgeInsets.all(16),
      itemCount: alertsState.alerts.length,
      itemBuilder: (context, index) {
        final alert = alertsState.alerts[index];
        return SlideInDown(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: NoticeCard(
            alert: alert,
            onTap: () => context.push('/notice/${alert.id}'),
          ),
        );
      },
    );
  }
}