import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final int? expandedIndex;
  final Function(int?) onExpandChange;
  final int? expandedDetailsIndex;
  final Function(int?) onExpandDetailsChange;

  const AlertCard({
    super.key,
    required this.alert,
    required this.index,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 10),
              _buildPricesSection(context),
              const SizedBox(height: 14),
              // Gráfico y descripción (solo cuando presionas "Ver detalles")
              _buildDetailsSection(),
              const Divider(),
              _buildFooter(context, isAdmin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            alert.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,

            )
          ),
        ),
        Expanded(child: _buildTypeChip()),
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
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        )),
                    const SizedBox(height: 2),
                    Text(
                      '1.0820',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "TP",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isTPExpanded ? Colors.blue.shade100 : null,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${currentTP.toStringAsFixed(4)} (${mockTPs.length})",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isTPExpanded ? Colors.blue.shade800 : null,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isTPExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 20,
                              color: isTPExpanded ? Colors.blue.shade800 : null,
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
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '1.0780',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
                padding: const EdgeInsets.all(12),
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mockTPs[i].toStringAsFixed(4),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            onExpandDetailsChange(isDetailsExpanded ? null : index);
          },
          child: Text(
            isDetailsExpanded ? "Cerrar +" : "Ver detalles →",
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue.shade700,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}





