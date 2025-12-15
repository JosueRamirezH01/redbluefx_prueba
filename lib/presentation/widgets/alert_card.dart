import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/entities/alert.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/date_utils.dart';

class AlertCard extends ConsumerWidget {
  final Alert alert;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
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
    final auth = ref.watch(authStateProvider);
    final isAdmin = auth.currentUser?.role == 'admin';
    timeago.setLocaleMessages('es', timeago.EsMessages());

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16) , side: BorderSide(color: borde == true ? Color(0xFFFF0006) : Colors.transparent)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Text(
                timeago.format(alert.createdAt, locale: 'es'),
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                ),
              ),
              _buildPricesSection(context),
              const SizedBox(height: 8),
              // Gráfico y descripción (solo cuando presionas "Ver detalles")
              _buildDetailsSection(),
              const Divider(thickness: 0.5),
              _buildFooter(context, isAdmin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            alert.title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,

            )
          ),
        ),

        Flexible(fit: FlexFit.loose,child: _buildTypeChip()),
      ],
    );
  }

  Widget _buildPricesSection(BuildContext context) {
    final mockTPs = <double>[1.0920, 1.0950, 1.0980, 1.1000, 1.0290];
    bool isTPExpanded = expandedIndex == index;
    double currentTP = mockTPs.first;

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
                    const Text(
                      '1.0820',
                      style: TextStyle(
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
                    onExpandChange(isTPExpanded ? null : index);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: isTPExpanded ? null : const Color(0xFFEDF9FF),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: const Color(0xFF005EA3)),
                          gradient:isTPExpanded ? const LinearGradient(colors: [Color(0xFF025591),Color(0xFF066BAF)]): null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TP",
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: isTPExpanded ? Colors.white : null,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${currentTP.toStringAsFixed(4)} ",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isTPExpanded ? Colors.white : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBF8FF),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${mockTPs.length}',
                                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF066BAF)),
                                      ),
                                      Icon(
                                        isTPExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 20,
                                        color: const Color(0xFF066BAF),
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
                      '1.0780',
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.blue.shade50,
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
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mockTPs[i].toStringAsFixed(4),
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF454545),
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

  Widget _buildDetailsSection() {
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
              Container(
                width: 120,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/chart_placeholder.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.green.shade50,
                        child: Icon(
                          Icons.show_chart,
                          color: Colors.green.shade300,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Texto descripción
              Expanded(
                child: Text(
                  "Lorem ipsum suspendisse lacus urna arcu ut pretium tellus etiam sollicitudin parturient pellentesque sed id cursus quisque.",
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

  Widget _buildFooter(BuildContext context, bool isAdmin) {
    bool isDetailsExpanded = expandedDetailsIndex == index;

    return Row(
      children: [
        Text(
          AppDateUtils.formatToPeruTime(alert.createdAt),
          style: GoogleFonts.montserrat(
            fontSize: 12,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            onExpandDetailsChange(isDetailsExpanded ? null : index);
          },
          child: Text(
            isDetailsExpanded ? "Cerrar x" : "Ver detalles →",
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: const Color(0xFF036BAF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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

  Widget _buildTypeChip() {
    late Color color;
    late IconData icon;
    late String text;

    switch (alert.type) {
      case AlertType.buy:
        color = Colors.green;
        icon = Icons.arrow_upward;
        text = "Compra";
        break;
      case AlertType.sell:
        color = Colors.red;
        icon = Icons.arrow_downward;
        text = "Venta";
        break;
      case AlertType.info:
        color = Colors.blue;
        icon = Icons.info_outline;
        text = "Info";
        break;
      default:
        color = Colors.grey;
        icon = Icons.all_inclusive;
        text = "Todas";
    }

    return Container(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8
        ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 11
            )
          ),
          const SizedBox(width: 4),
          Icon(icon, color: color, size: 16),
        ],
      ),
    );
  }
}





