import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger.dart';
import '../../providers/alert_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../widgets/center_button.dart';
import '../../widgets/custom_bottom_bar.dart';

class AnuncioDetailScreen extends ConsumerWidget {
  final String alertId;

  const AnuncioDetailScreen({
    super.key,
    required this.alertId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertState = ref.watch(alertsProvider);
    final alert = alertState.alerts.firstWhere((a) => a.id == alertId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de Anuncio',
          style: GoogleFonts.montserrat(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 6,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: 350,
                  height: 110,
                  child: Stack(
                    children: [
                      // Fondo azul degradado
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/fondoCard.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Contenido centrado
                      Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  if (alert.imageUrl == null || alert.imageUrl!.isEmpty) {
                                    return _defaultImage(60);
                                  }
                                  return Image.network(
                                    alert.imageUrl!,
                                    width: 65,
                                    height: 60,
                                    fit: BoxFit.fill,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _defaultImage(60);
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
                            const SizedBox(height: 8,),

                            Text(
                              'Nueva funcionalidad',
                              style: GoogleFonts.montserrat(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.only(right: 20,left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Descubre las últimas novedades de RedBlue FX ',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),



                  const SizedBox(height: 12),

                  // Contenido de la noticia
                  Text(
                    '''
Estamos emocionados de anunciar el lanzamiento de nuestra última actualización que incluye mejoras significativas en la plataforma de trading.
¿Qué incluye esta actualización?

• Sistema de alertas mejorado con notificaciones en tiempo real
• Nueva interfaz de análisis técnico con indicadores avanzados
• Integración con más plataformas de trading
• Optimización del rendimiento y velocidad de ejecución
• Panel de estadísticas personalizable

Esta actualización está diseñada para brindarte las mejores herramientas y ayudarte a tomar decisiones más informadas en tus operaciones.

¿Cómo empezar?

Todas las funcionalidades ya están disponibles en tu cuenta. Explora el menú de configuración para personalizar tu experiencia y aprovechar al máximo estas nuevas características.
'''
                        .trim(),
                    style: GoogleFonts.inter(fontSize: 14),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onNoticias: () {
          AppLogger.info("Noticias tapped");
          context.pushNamed('notice_list');
        },
        onAnuncios: () => AppLogger.info("Anuncios tapped"), selectedTab: BottomTab.anuncios,
      ),
      floatingActionButton: CenterFloatingButton(onPressed: () { AppLogger.info("Home");
      context.goNamed('home'); },),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }


  Widget _defaultImage(double size) {
    return Container(
      width: 65,
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