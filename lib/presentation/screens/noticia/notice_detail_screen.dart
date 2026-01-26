import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redbluefx_mobile/presentation/providers/notice_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/date_utils.dart';
import '../../widgets/center_button.dart';
import '../../widgets/custom_bottom_bar.dart';

class NoticeDetailScreen extends ConsumerWidget {
  final String noticeId;

  const NoticeDetailScreen({
    super.key,
    required this.noticeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticeState = ref.watch(noticeProvider);
    final notice = noticeState.notices.firstWhere((a) => a.id == noticeId);

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
        centerTitle: true,
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
            top: MediaQuery.of(context).padding.top * 2.8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---- IMAGEN PRINCIPAL ----
              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: notice.image != null && notice.image!.isNotEmpty
                    ? Image.network(
                  notice.image!,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.28,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade100, Colors.blue.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF005EA3),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _placeholder(
                      MediaQuery.of(context).size.height * 0.28,
                      broken: true,
                    );
                  },
                )
                    : _placeholder(MediaQuery.of(context).size.height * 0.28),
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
                            notice.author,
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
                      notice.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                          _formatDate(notice.createdAt),
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
                      _formatTextWithLineBreaks(notice.content),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomBar(
          onNoticias: () {
            AppLogger.info("Noticias tapped");
            context.pushNamed('notice_list');
          },
          onAnuncios: () {
            AppLogger.info("Anuncios tapped");
            context.pushNamed('anuncio_list');
          }, selectedTab: BottomTab.noticias,
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

  Widget _placeholder(double size, {bool broken = false}) {
    return Container(
      width: double.infinity,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF066BAF).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        broken ? Icons.broken_image : Icons.show_chart,
        color: const Color(0xFF066BAF),
        size: size * 0.4,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return AppDateUtils.formatToPeruTime(date);
  }
}