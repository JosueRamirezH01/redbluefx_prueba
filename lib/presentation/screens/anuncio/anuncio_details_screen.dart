import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/adverts.dart';
import '../../providers/adverts_provider.dart';
import '../../widgets/custom_bottom_bar.dart';
import 'package:collection/collection.dart';
class AnuncioDetailScreen extends ConsumerWidget {
  final String advertId;
  final Advert? advert;
  const AnuncioDetailScreen({
    super.key,
    required this.advertId,
    this.advert
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advertState = ref.watch(advertsProvider);
    final publicState = ref.watch(advertsProviderPublic);
    final screenWidth = MediaQuery.of(context).size.width;
    Advert? advertData = advert;

    advertData ??= advertState.adverts.firstWhereOrNull((a) => a.id == advertId);
    advertData ??= publicState.adverts.firstWhereOrNull((a) => a.id == advertId);

    if (advertData == null) {
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
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final imageSize = screenWidth * 0.3;
                          final finalSize = imageSize.clamp(100.0, 120.0);
                          if (advertData?.image == null || advertData!.image!.isEmpty) {
                            return _defaultImage(70);
                          }
                          return GestureDetector(
                            onTap: () {
                              _showImagePreview(
                                context,
                                Image.network(advertData!.image!, fit: BoxFit.contain),
                              );
                            },
                            child: Hero(
                              tag: 'alert-image-$advertId',
                              child: Image.network(
                                advertData.image!,
                                width: finalSize,
                                height: finalSize,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    width: finalSize,
                                    height: finalSize,
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return _defaultImage(70);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    flex: 2,
                    child: Text(
                      advertData.title ,
                      style: GoogleFonts.montserrat(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
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
                    advertData.content,
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
          onAnuncios: () => AppLogger.info("Anuncios tapped"), selectedTab: BottomTab.anuncios, onCenterTap: () { context.goNamed('home'); },
        ),
      ),
    );
  }
  void _showImagePreview(BuildContext context, Widget imageWidget) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Hero(
              tag: 'alert-image',
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: imageWidget,
              ),
            ),
          ),
        );
      },
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