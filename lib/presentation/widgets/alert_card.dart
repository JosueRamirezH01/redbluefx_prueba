import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/entities/alert.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/date_utils.dart';

class AlertCard extends ConsumerWidget {
  final Alert alert;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color _getTypeColor() {
    switch (alert.type) {
      case AlertType.all:
        return Colors.grey;
      case AlertType.buy:
        return Colors.green;
      case AlertType.sell:
        return Colors.red;
      case AlertType.info:
        return Colors.blue;
    }
  }

   String _getTypeText() {
    switch (alert.type) {
      case AlertType.all:
        return 'TODAS';
      case AlertType.buy:
        return 'COMPRA';
      case AlertType.sell:
        return 'VENTA';
      case AlertType.info:
        return 'INFO';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isAdmin = authState.currentUser?.role == 'admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      alert.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildTypeChip(),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                alert.content,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(alert.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const Spacer(),
                  if (isAdmin)
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Colors.blue.shade700,
                      ),
                    ),
                ],
              ),
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar'),
                              content: const Text('¿Estás seguro de eliminar esta alerta?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onDelete?.call();
                                  },
                                  child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    Color color;
    IconData icon;
    String label;

    switch (alert.type) {
      case AlertType.all:
        color = Colors.grey;
        icon = Icons.all_inclusive;
        label = 'Todas';
        break;
      case AlertType.buy:
        color = Colors.green;
        icon = Icons.arrow_upward;
        label = 'Compra';
        break;
      case AlertType.sell:
        color = Colors.red;
        icon = Icons.arrow_downward;
        label = 'Venta';
        break;
      case AlertType.info:
        color = Colors.blue;
        icon = Icons.info_outline;
        label = 'Info';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Usar las utilidades de fecha para zona horaria de Perú (GMT-5)
    return AppDateUtils.formatToPeruTime(date);
  }
}