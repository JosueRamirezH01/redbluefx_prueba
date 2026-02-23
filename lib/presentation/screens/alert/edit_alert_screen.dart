import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/alert.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/logger.dart';

class EditAlertScreen extends ConsumerStatefulWidget {
  final String alertId;

  const EditAlertScreen({
    super.key,
    required this.alertId,
  });

  @override
  ConsumerState<EditAlertScreen> createState() => _EditAlertScreenState();
}


class _EditAlertScreenState extends ConsumerState<EditAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late AlertType _selectedType;
  late bool _isPublic;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final alert = ref.read(alertsProvider).alerts.firstWhere((a) => a.id == widget.alertId);
    _titleController = TextEditingController(text: alert.title);
    _contentController = TextEditingController(text: alert.content);
    _selectedType = alert.type;
    _isPublic = alert.isPublic;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        await ref.read(alertsProvider.notifier).updateAlert(
          widget.alertId,
          title: _titleController.text,
          content: _contentController.text,
          type: _selectedType,
          isPublic: _isPublic,
        );

        // Refresh alerts data
        await ref.read(alertsProvider.notifier).refreshAlerts();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alerta actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (e) {
        AppLogger.error('Error al actualizar alerta', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar alerta: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isAdmin = authState.currentUser?.role == 'admin';

    if (!isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text('No tienes permisos para editar alertas'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Alerta'),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _submitForm,
                  child: const Text('Guardar'),
                ),
        ],
      ),
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
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AlertType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: AlertType.values.map((type) {
                String text;
                Color color;
                switch (type) {
                  case AlertType.all:
                    text = 'TODAS';
                    color = Colors.grey;
                    break;
                  case AlertType.buy:
                    text = 'COMPRA';
                    color = Colors.green;
                    break;
                  case AlertType.sell:
                    text = 'VENTA';
                    color = Colors.red;
                    break;
                  case AlertType.info:
                    text = 'INFO';
                    color = Colors.blue;
                    break;
                }
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    text,
                    style: TextStyle(color: color),
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
              title: const Text('Público'),
              subtitle: const Text('La alerta será visible para todos los usuarios'),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
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
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
} 