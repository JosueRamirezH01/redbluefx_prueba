import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/entities/alert.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/date_utils.dart';

class AlertCard extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends ConsumerState<AlertCard> {
  bool isExpanded = false; // ✅ El estado ahora es persistente

  Color _getTypeColor() {
    switch (widget.alert.type) {
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isAdmin = authState.currentUser?.role == 'admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- TÍTULO Y TIPO ---
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.alert.title,
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
              Text(widget.alert.content, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              const Divider(),
              /// --- FECHA + BOTÓN EXPANDIR ---
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    AppDateUtils.formatToPeruTime(widget.alert.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                  const Spacer(),

                  GestureDetector(
                    onTap: () => setState(() => isExpanded = !isExpanded),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: isExpanded ? "Ocultar" : "Ver detalle",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue, // Se respeta mejor en Text.rich
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),



                  const Spacer(),

                  if (isAdmin)
                    IconButton(
                      onPressed: widget.onEdit,
                      icon: Icon(Icons.edit_outlined, size: 20, color: Colors.blue.shade700),
                    ),
                ],
              ),

              /// --- CONTENIDO EXPANDIBLE ---
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.alert.title}')
                    /*if (widget.alert.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: widget.alert.imageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],*/
                  ],
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text('¿Deseas eliminar esta alerta?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onDelete?.call();
                                },
                                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getTypeText(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getTypeColor()),
          ),
        ],
      ),
    );
  }

  String _getTypeText() {
    switch (widget.alert.type) {
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
}

