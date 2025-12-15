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

class NoticeDetailScreen extends ConsumerWidget {
  final String alertId;

  const NoticeDetailScreen({
    super.key,
    required this.alertId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertState = ref.watch(alertsProvider);
    final alert = alertState.alerts.firstWhere((a) => a.id == alertId);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Detalles de la noticia',
          style: GoogleFonts.montserrat(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        toolbarHeight: 75,
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
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top * 2.55,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---- IMAGEN PRINCIPAL ----
              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.asset(
                  'assets/images/cabecera.png',
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.28,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.28,
                      color: Colors.green.shade50,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.green.shade300,
                      ),
                    );
                  },
                ),
              ),
          
              /// ---- CONTENIDO ----
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Autor y Tipo
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF005EA3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Por: Sergio Ávila",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF005EA3),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                       /* const Spacer(),
                        _buildTypeChip(),*/
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'EURUSD: el euro cede terreno tras la tregua comercial entre EE. UU. y China',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
          
                    const SizedBox(height: 12),
          
                    // Fecha
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(alert.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
          
                    const SizedBox(height: 10),
          
                    // Divider decorativo
                    Container(
                      height: 3,
                      width: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF005EA3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
          
                    const SizedBox(height: 12),
          
                    // Contenido de la noticia
                    Text(
                      _formatTextWithLineBreaks(  'Lorem ipsum dolor sit amet consectetur. Bibendum ut massa congue a in. Rhoncus risus vel risus ac amet fermentum. Amet consequat non lorem mattis integer nunc cursus ut lobortis.'
                        'Mauris id commodo porttitor rutrum. Sodales dui amet integer odio donec arcu id felis. Mauris molestie nibh risus et metus vestibulum semper dapibus. Posuere elit sem convallis ullamcorper nisl. Faucibus risus nunc quam vel risus volutpat consectetur. '
                        'Mauris id commodo porttitor rutrum. Sodales dui amet integer odio donec arcu id felis. Mauris molestie nibh risus et metus vestibulum semper dapibus. Posuere elit sem convallis ullamcorper nisl. Faucibus risus nunc quam vel risus volutpat consectetur. '
                        'Mauris id commodo porttitor rutrum. Sodales dui amet integer odio donec arcu id felis. Mauris molestie nibh risus et metus vestibulum semper dapibus. Posuere elit sem convallis ullamcorper nisl. Faucibus risus nunc quam vel risus volutpat consectetur. ',),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onNoticias: () {
          AppLogger.info("Noticias tapped");
          context.pushNamed('notice_list');
        },
        onAnuncios: () {
          AppLogger.info("Anuncios tapped");
          context.pushNamed('anuncio_list');
        }, selectedTab: BottomTab.noticias,
      ),
      floatingActionButton: CenterFloatingButton(onPressed: () { AppLogger.info("Home");
      context.goNamed('home'); },),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  String _formatTextWithLineBreaks(String text) {
    final sentences = text.split('. ');
    final buffer = StringBuffer();

    for (int i = 0; i < sentences.length; i++) {
      buffer.write(sentences[i]);

      // Agregar punto si no es la última oración
      if (i < sentences.length - 1) {
        buffer.write('. ');

        // Agregar salto de línea cada 3 oraciones
        if ((i + 1) % 4 == 0) {
          buffer.write('\n\n');
        }
      }
    }

    return buffer.toString();
  }
  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF005EA3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Noticias',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF005EA3),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.article_outlined,
            size: 14,
            color: Color(0xFF005EA3),
          ),
        ],
      ),
    );
  }


  String _formatDate(DateTime date) {
    return AppDateUtils.formatToPeruTime(date);
  }
}