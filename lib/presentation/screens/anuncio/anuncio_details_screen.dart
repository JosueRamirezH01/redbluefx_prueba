import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redbluefx_mobile/presentation/providers/adverts_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/date_utils.dart';
import '../../widgets/center_button.dart';
import '../../widgets/custom_bottom_bar.dart';
import 'package:collection/collection.dart';
class AnuncioDetailScreen extends ConsumerWidget {
  final String advertId;

  const AnuncioDetailScreen({
    super.key,
    required this.advertId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advertState = ref.watch(advertsProvider);
    final publicState = ref.watch(advertsProviderPublic);

    var advert = advertState.adverts.firstWhereOrNull((a) => a.id == advertId);
    advert ??= publicState.adverts.firstWhereOrNull((a) => a.id == advertId);

    if (advert == null) {
      return const Scaffold(
        body: Center(child: Text("Cargando anuncio o no encontrado...")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de Anuncio',
          style: GoogleFonts.montserrat(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 80,
        leadingWidth: 70,
        leading: IconButton(
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFF19283F)), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)), side: BorderSide(color: Color(0xFF29374C))))),
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        elevation: 6,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (advert?.imageUrl == null || advert!.imageUrl!.isEmpty) {
                          return _defaultImage(70);
                        }
                        return Image.network(
                          advert!.imageUrl!,
                          width: 85,
                          height: 70,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return _defaultImage(70);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 65,
                              height: 60,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    advert.title ,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 17,

                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),


            Padding(
              padding: const EdgeInsets.only(right: 20,left: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Contenido de la noticia
                  Text(
                    advert.content,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomBar(
          onNoticias: () {
            AppLogger.info("Noticias tapped");
            context.pushNamed('notice_list');
          },
          onAnuncios: () => AppLogger.info("Anuncios tapped"), selectedTab: BottomTab.anuncios,
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: CenterFloatingButton(onPressed: () { AppLogger.info("Home");
        context.goNamed('home'); },),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }


  Widget _defaultImage(double size) {
    return Container(
      width: 85,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE6F2FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Image.asset(
          'assets/icons/icon_anuncio.png',
          width: size * 0.3,
          height: size * 0.3,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return AppDateUtils.formatToPeruTime(date);
  }
}