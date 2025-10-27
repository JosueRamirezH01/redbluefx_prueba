import 'package:dropdown_search/dropdown_search.dart';
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
  final _entradaController = TextEditingController();
  final _tpController = TextEditingController();
  final _slController = TextEditingController();
  final _contentController = TextEditingController();
  final AlertType _selectedType = AlertType.buy;
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
      appBar: const SharedAppBar(title: 'Crear Alerta', icons: false,),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                // Campo de texto para el título
                Expanded(
                  flex: 2,
                  child: TextFormField(
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
                ),
                const SizedBox(width: 12),
                // Selector de moneda con buscador
                ///ULTIMO PARA AGREGAR UN SELECT BUSCADOR DE MONEDAS...... PARA EL ULTIMO...... :)
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _entradaController,
                    decoration: const InputDecoration(
                      labelText: 'Entrada',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una entrada';
                      }
                      if (value.length < 3) {
                        return 'El título debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _tpController,
                    decoration: const InputDecoration(
                      labelText: 'TP',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un TP';
                      }
                      if (value.length < 3) {
                        return 'El título debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _slController,
                    decoration: const InputDecoration(
                      labelText: 'SL',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un SL';
                      }
                      if (value.length < 3) {
                        return 'El título debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
              ],
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
            const Row(
              children: [
                Chip(
                  avatar: Icon(Icons.arrow_downward),
                  label: Text('Comprar'),

                ),
                SizedBox(width: 8),
                Chip(
                  avatar: Icon(Icons.arrow_upward),
                  label: Text('Vender'),
                ),
              ],
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

 /* Widget _buildSelectableChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final bool isSelected = _selectedType == label;

    return ChoiceChip(
      avatar: Icon(
        icon,
        color: isSelected ? Colors.white : color,
        size: 20,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? color : Colors.grey.shade400,
          width: 1.5,
        ),
      ),
      onSelected: (selected) {
        setState(() => _selectedTy pe = label);
      },
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }*/

} 