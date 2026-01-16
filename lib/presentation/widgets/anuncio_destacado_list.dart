import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:redbluefx_mobile/core/theme/app_theme_backup.dart';
import 'package:redbluefx_mobile/presentation/providers/adverts_provider.dart';
import '../providers/alert_provider.dart';
import '../../../core/utils/logger.dart';
import 'anuncio_destacado_card.dart';

class AnuncioDestacadoList extends ConsumerStatefulWidget {
  const AnuncioDestacadoList({super.key});

  @override
  ConsumerState<AnuncioDestacadoList> createState() => _AnuncioDestacadoListState();
}
class _AnuncioDestacadoListState extends ConsumerState<AnuncioDestacadoList> {


  @override
  Widget build(BuildContext context) {
    final advertState = ref.watch(advertsProvider);

    if (advertState.isLoading && advertState.adverts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (advertState.error != null && advertState.adverts.isEmpty) {
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
              'Error al cargar los anuncios',
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

    if (advertState.adverts.isEmpty) {
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
                  'No se encontraron anuncios',
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
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: advertState.adverts.length,
      itemBuilder: (context, index) {
        final advert = advertState.adverts[index];
        return FadeInUp(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: SlideInRight(
            duration: Duration(milliseconds: 300 + (index * 100)),
            child: Dismissible(
              key: Key(advert.id),
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
                /*try {
                  await ref.read(advertsProvider.notifier).de(advert.id);
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
                }*/
              },
              child: AnuncioDestacadoCard(
                advert: advert,
                onTap: () => context.push('/anuncio/${advert.id}'),
                //onEdit: () => context.push('/alerts/${alert.id}/edit'),
              ),
            ),
          ),
        );
      },
    );
  }
}