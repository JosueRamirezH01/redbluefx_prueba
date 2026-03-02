import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/alert.dart';
import '../../providers/alert_provider.dart';
import '../../../core/utils/date_utils.dart';

class AlertDetailScreen extends ConsumerWidget {
  final String alertId;

  const AlertDetailScreen({super.key, required this.alertId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsState = ref.watch(alertsProvider);

    // Intentamos encontrar el alert localmente
    Alert? alert;
    try {
      alert = alertsState.alerts.firstWhere((a) => a.id == alertId);
    } catch (_) {
      alert = null;
    }

    // Si no está en el estado, hacemos fetch desde API
    if (alert == null) {
      final repository = ref.read(alertRepositoryProvider);
      return FutureBuilder<Alert>(
        future: repository.getAlertById(alertId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error al cargar la alerta: ${snapshot.error}'),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: Text('No se encontró la alerta'),
              ),
            );
          } else {
            final fetchedAlert = snapshot.data!;
            return _buildAlertContent(context, fetchedAlert);
          }
        },
      );
    }

    // Si sí existe localmente, se muestra directamente
    return _buildAlertContent(context, alert);
  }

  Widget _buildAlertContent(BuildContext context, Alert alert) {
    return Scaffold(
      appBar: AppBar(title: Text(alert.pair)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alert.imageUrl != null)
              CachedNetworkImage(
                imageUrl: alert.imageUrl!,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.error)),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildTypeChip(alert.type),
                      const Spacer(),
                      Text(
                        _formatDate(alert.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    alert.pair,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  MarkdownBody(
                    data: 'ENTRADA: ${alert.entry}',
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: Theme.of(context).textTheme.bodyLarge,
                      h1: Theme.of(context).textTheme.headlineMedium,
                      h2: Theme.of(context).textTheme.headlineSmall,
                      h3: Theme.of(context).textTheme.titleLarge,
                      blockquote: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      code: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        fontFamily: 'monospace',
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  MarkdownBody(
                    data: 'TAKE PROFIT:\n\n${alert.takeProfits.asMap().entries.map((e) => 'TP${e.key + 1}: ${e.value}').join('\n\n')}',
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: Theme.of(context).textTheme.bodyLarge,
                      h1: Theme.of(context).textTheme.headlineMedium,
                      h2: Theme.of(context).textTheme.headlineSmall,
                      h3: Theme.of(context).textTheme.titleLarge,
                      blockquote: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      code: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        fontFamily: 'monospace',
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  MarkdownBody(
                    data: 'STOP LOSS: ${alert.stopLoss}',
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: Theme.of(context).textTheme.bodyLarge,
                      h1: Theme.of(context).textTheme.headlineMedium,
                      h2: Theme.of(context).textTheme.headlineSmall,
                      h3: Theme.of(context).textTheme.titleLarge,
                      blockquote: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(AlertType type) {
    Color color;
    String text;

    switch (type) {
      case AlertType.all:
        color = Colors.grey;
        text = 'TODAS';
        break;
      case AlertType.buy:
        color = Colors.green;
        text = 'COMPRA';
        break;
      case AlertType.sell:
        color = Colors.red;
        text = 'VENTA';
        break;
      case AlertType.info:
        color = Colors.blue;
        text = 'INFO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime date) => AppDateUtils.formatToPeruTime(date);
}