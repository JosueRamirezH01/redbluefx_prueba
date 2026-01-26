import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:redbluefx_mobile/core/theme/app_theme_backup.dart';
import 'package:redbluefx_mobile/presentation/providers/adverts_provider.dart';
import '../../core/utils/logger.dart';
import 'advert_card.dart';

class AdvertRecentList extends ConsumerStatefulWidget {
  const AdvertRecentList({super.key});

  @override
  ConsumerState<AdvertRecentList> createState() => _AdvertRecentListState();
}
class _AdvertRecentListState extends ConsumerState<AdvertRecentList> {

  @override
  Widget build(BuildContext context) {
    final advertsState = ref.watch(advertsProviderPublic);

    if (advertsState.isLoading && advertsState.adverts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (advertsState.error != null && advertsState.adverts.isEmpty) {
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
              onPressed: () => ref.read(advertsProviderPublic.notifier).loadAdvertsPublic(refresh: true),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (advertsState.adverts.isEmpty) {
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: advertsState.adverts.length,
      itemBuilder: (context, index) {
        final advert = advertsState.adverts[index];
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
                    title: const Text('Eliminar anuncio'),
                    content: const Text('¿Estás seguro de que deseas eliminar esta anuncio?'),
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
                  await ref.read(advertsProviderPublic.notifier).deleteAdvertPublic(advert.id);
                  Fluttertoast.showToast(
                    msg: "Anuncio eliminado correctamente",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 14,
                  );
                } catch (e, stack) {
                  AppLogger.error('Error al eliminar anuncio: $e', error: e, stackTrace: stack);
                  Fluttertoast.showToast(
                    msg: "Error al eliminar el anuncio",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 14,
                  );
                }
              },
              child: AdvertsCard(
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