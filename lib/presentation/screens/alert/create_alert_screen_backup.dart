import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/alert.dart';
import '../../providers/alert_provider.dart';
import '../../widgets/app_bar.dart';
import '../../../core/utils/logger.dart';

class CreateAlertScreen extends ConsumerStatefulWidget {
  const CreateAlertScreen({super.key});

  @override
  ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  AlertType _selectedType = AlertType.info;
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(alertsProvider.notifier).createAlert(
        title: _titleController.text,
        content: _contentController.text,
        type: _selectedType,
        isPublic: _isPublic,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerta creada correctamente')),
        );
        Navigator.of(context).pop();
      }
    } catch (e, stack) {
      AppLogger.error('Error al crear alerta', error: e, stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear la alerta. Por favor, intenta de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: 'Crear Alerta'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un título';
                }
                if (value.length < 3) {
                  return 'El título debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Contenido',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el contenido';
                }
                if (value.length < 10) {
                  return 'El contenido debe tener al menos 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AlertType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: AlertType.values.map((type) {
                String label;
                Color color;
                switch (type) {
                  case AlertType.all:
                    label = 'Todas';
                    color = Colors.grey;
                    break;
                  case AlertType.buy:
                    label = 'Compra';
                    color = Colors.green;
                    break;
                  case AlertType.sell:
                    label = 'Venta';
                    color = Colors.red;
                    break;
                  case AlertType.info:
                    label = 'Información';
                    color = Colors.blue;
                    break;
                }
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: color, size: 12),
                      const SizedBox(width: 8),
                      Text(label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Alerta pública'),
              subtitle: const Text('Las alertas públicas son visibles para todos los usuarios'),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear Alerta'),
            ),
          ],
        ),
      ),
    );
  }
} 