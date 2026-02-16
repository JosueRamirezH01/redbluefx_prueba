import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redbluefx_mobile/core/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/entities/alert.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/date_utils.dart';

class AlertCard extends ConsumerWidget {
  final Alert alert;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final File? imagePreview;
  final int index;
  final bool? borde;
  final int? expandedIndex;
  final Function(int?) onExpandChange;
  final int? expandedDetailsIndex;
  final Function(int?) onExpandDetailsChange;

  const AlertCard({
    super.key,
    required this.alert,
    required this.index,
    this.borde = false,
    this.imagePreview,
    required this.expandedIndex,
    required this.onExpandChange,
    required this.expandedDetailsIndex,
    required this.onExpandDetailsChange,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStateProvider);
    final isAdmin = auth.currentUser?.role == 'admin';
    timeago.setLocaleMessages('es', timeago.EsMessages());
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14) , side: borde == true
          ? BorderSide(
        color: Theme.of(context).borderCardPreviewColors,
        width: 1.2,
      )
          : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              Text(
                timeago.format(alert.createdAt, locale: 'es'),
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              _buildPricesSection(context),
              const SizedBox(height: 10),
              // Gráfico y descripción (solo cuando presionas "Ver detalles")
              _buildDetailsSection(screenWidth),
              Divider(thickness: 0.5, color: Theme.of(context).dividerCardAlert),
              _buildFooter(context, isAdmin, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            alert.pair,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,

            )
          ),
        ),

        Flexible(fit: FlexFit.loose,child: _buildTypeChip(theme)),
      ],
    );
  }

  Widget _buildPricesSection(BuildContext context) {
    final mockTPs = alert.takeProfits;
    bool isTPExpanded = expandedIndex == index;
    String currentTP = mockTPs.first;
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Row(
              children: [
                // --- Entrada ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Entrada",
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w500
                        )),
                    const SizedBox(height: 2),
                    Text(
                      formatDecimals(alert.entry),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // --- TP BUTTON ---
                GestureDetector(
                  onTap: () {
                    if(mockTPs.length > 1) {
                      onExpandChange(isTPExpanded ? null : index);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isTPExpanded
                              ? null
                              : (mockTPs.length == 1
                              ? null
                              : Theme.of(context).cardTpColors),
                          borderRadius: BorderRadius.circular(4),
                          border: (!isTPExpanded && mockTPs.length > 1)
                              ? Border.all(color: const Color(0xFF005EA3))
                              : null,
                          gradient: isTPExpanded ? const LinearGradient(colors: [Color(0xFF025591),Color(0xFF066BAF)]): null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TP",
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isTPExpanded
                                    ? Colors.white
                                    : (mockTPs.length == 1
                                    ? null
                                    : Theme.of(context).textCardPreviewColors),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  formatDecimals(currentTP),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isTPExpanded
                                        ?  Colors.white
                                        : (mockTPs.length == 1
                                        ? null
                                        : Theme.of(context).textCardPreviewColors),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                if(mockTPs.length > 1)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardTpChildrenColors,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${mockTPs.length}',
                                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).cardTpTextChildrenColors),
                                      ),
                                      Icon(
                                        isTPExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 20,
                                        color: Theme.of(context).cardTpTextChildrenColors,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // --- SL ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SL",
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDecimals(alert.stopLoss),
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.bold   ,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // TPs adicionales (solo cuando presionas el botón TP)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isTPExpanded
                  ? Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.only(right: 10, left: 10, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Theme.of(context).colorBorderTpCardAlert, width: 1),
                  color: Theme.of(context).colorTpCardAlert,

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 1; i < mockTPs.length; i++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentTP = mockTPs[i];
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              "TP${i + 1}",
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),

                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatDecimals(mockTPs[i]),
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              )
                  : const SizedBox.shrink(),
            )
          ],
        );
      },
    );
  }

  Widget _buildDetailsSection(double size) {
    bool isDetailsExpanded = expandedDetailsIndex == index;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: isDetailsExpanded
          ? Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gráfico desde assets
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final imageSize = size * 0.3;
                    final finalSize = imageSize.clamp(100.0, 120.0);
                    if (imagePreview != null) {
                      return Image.file(
                        imagePreview!,
                        width: finalSize,
                        height: finalSize,
                        fit: BoxFit.cover,
                      );
                    }
                    // Si no hay URL de imagen, mostramos placeholder
                    if (alert.imageUrl == null || alert.imageUrl!.isEmpty) {
                      return _placeholder(finalSize);
                    }

                    return GestureDetector(
                      onTap: () {
                        _showImagePreview(
                          context,
                          Image.network(alert.imageUrl!, fit: BoxFit.contain),
                        );
                      },
                      child: Hero(
                        tag: 'alert-image-$index',
                        child: Image.network(
                          alert.imageUrl!,
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
                            return _placeholder(finalSize, broken: true);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Texto descripción
              Expanded(
                child: Text(
                  alert.analysis ?? '',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      )
          : const SizedBox.shrink(),
    );
  }

  void _showImagePreview(BuildContext context, Widget imageWidget) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Hero(
              tag: 'alert-image-$index',
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

  Widget _buildFooter(BuildContext context, bool isAdmin, ThemeData theme) {
    bool isDetailsExpanded = expandedDetailsIndex == index;
    return Row(
      children: [
        Text(
          AppDateUtils.formatToPeruTime(alert.createdAt),
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Theme.of(context).colorLetterCardAlert
          ),
        ),
        const Spacer(),
        if ((alert.imageUrl != null && alert.imageUrl!.isNotEmpty) || (alert.content != null && alert.content!.isNotEmpty))
        GestureDetector(
          onTap: () {
            onExpandDetailsChange(isDetailsExpanded ? null : index);
          },
          child: Icon(isDetailsExpanded ? Icons.close : Icons.arrow_forward , color: theme.linkColor ),) /*Text(
            isDetailsExpanded ? "Cerrar x" : " →",
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.linkColor,
              decoration: TextDecoration.underline,
              decorationColor: theme.linkColor,
            ),
          ),*/
        /*if (isAdmin) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit, color: Colors.blue.shade600),
            iconSize: 20,
          )
        ]*/
      ],
    );
  }

  Widget _buildTypeChip(ThemeData theme) {
    late Color colorFondo;
    late IconData icon;
    late String text;
    late Color colorBorde;
    switch (alert.type) {
      case AlertType.buy:
        colorFondo = const Color(0xFFDCFCE7);
        colorBorde = const Color(0xFF10B981);
        icon = Icons.arrow_upward;
        text = "Compra";
        break;
      case AlertType.sell:
        colorFondo = const Color(0xFFFFE1E0);
        colorBorde = const Color(0xFFDD2E44);
        icon = Icons.arrow_downward;
        text = "Venta";
        break;
      case AlertType.info:
        colorFondo = Colors.blue;
        colorBorde = const Color(0xFFDCFCE7);
        icon = Icons.info_outline;
        text = "Info";
        break;
      default:
        colorFondo = Colors.grey;
        colorBorde = Colors.grey;
        icon = Icons.all_inclusive;
        text = "Todas";
    }

    return Container(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8
        ),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorBorde)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: theme.chipsColors,
              decorationColor: theme.chipsColors
            )
          ),
          const SizedBox(width: 4),
          Icon(icon, color: colorBorde, size: 16),
        ],
      ),
    );
  }

  Widget _placeholder(double size, {bool broken = false}) {
    return Container(
      width: size,
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


  String formatDecimals(String value) {
    if (!value.contains('.')) return value;

    final parts = value.split('.');
    final decimals = parts[1];

    if (decimals.length <= 4) return value;

    return '${parts[0]}.${decimals.substring(0, 4)}';
  }
}





