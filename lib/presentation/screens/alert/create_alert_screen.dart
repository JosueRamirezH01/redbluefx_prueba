import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
  final List<TextEditingController> _tpControllers = [TextEditingController()];
  final _entradaController = TextEditingController();
  final _tpController = TextEditingController();
  final _slController = TextEditingController();
  final _contentController = TextEditingController();
  AlertType? _selectedType;
  bool _isPublic = true;
  bool _isLoading = false;
  File? _selectedImage;
  bool _isPickingImage = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    for (var c in _tpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un tipo: Comprar o Vender'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // detener
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(alertsProvider.notifier).createAlert(
        title: _titleController.text,
        content: _contentController.text,
        type: _selectedType!,
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
  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  setState(() => _isPickingImage = true);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 40,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                  setState(() => _isPickingImage = false);

                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  setState(() => _isPickingImage = true);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 40,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                  setState(() => _isPickingImage = false);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: 'RedBlue FX', icons: false),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.add, color: Color(0xFFE63330), size: 30,),Text('Crear Alerta', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
                ],),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSelectableChip(
                          label: 'Compra',
                          icon: Icons.arrow_downward,
                          value: AlertType.buy,
                          color: Colors.green
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildSelectableChip(
                          label: 'Venta',
                          icon: Icons.arrow_upward,
                          value: AlertType.sell,
                          color: Colors.red

                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Par de Divisas',
                  hintText: 'ej: GBP/JPY',
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
              const SizedBox(height: 8),
              TextFormField(
                controller: _entradaController,
                decoration: const InputDecoration(
                  labelText: 'Entrada ➡️',
                  hintText:'1.0820',
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
              const SizedBox(height: 8),
              const Text('Take Profit 🎯'),
              const SizedBox(height: 4),

              Column(
                children: [
                  for (int i = 0; i < _tpControllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tpControllers[i],
                              decoration: InputDecoration(
                                labelText: 'TP ${i + 1}',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Ingresa un TP';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_tpControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _tpControllers.removeAt(i);
                                });
                              },
                            ),
                        ],
                      ),
                    ),

                  // Botón para agregar otro TP
                  if (_tpControllers.length < 5)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _tpControllers.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Agregar TP"),
                    ),
                ],
              ),

              const SizedBox(height: 8),
              TextFormField(
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Detalles',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el detalle';
                  }
                  if (value.length < 10) {
                    return 'El contenido debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.all(8),
                      ),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red),
                                color: Colors.red.withOpacity(0.5),
                              ),
                              child: _isPickingImage
                                  ? Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              )
                                  : (_selectedImage == null
                                  ? Icon(
                                Icons.camera_alt_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              )
                                  : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: const Text(
                                  "Imagen",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                         ]
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('¿Es una alerta pública?'),
                subtitle: const Text('Las alertas públicas son visibles para todos los usuarios'),
                value: _isPublic,
                onChanged: (value) => setState(() => _isPublic = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFE63330))),
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    :  Text('Crear Alerta', style: GoogleFonts.montserrat(fontSize: 16,
                  fontWeight: FontWeight.normal, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableChip({required String label, required IconData icon, required AlertType value, required Color color}) {
    final bool isSelected = _selectedType == value;
    final colors = Theme.of(context).colorScheme;

    return ChoiceChip(
      showCheckmark: false,
      label: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 10,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? colors.onPrimary : colors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Icon(
              icon,
              size: 11,
              color: isSelected ? colors.onPrimary : colors.onSurface,
            ),
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: colors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? color : color,
          width: 1.2,
        ),
      ),
      onSelected: (_) {
        setState(() {
          _selectedType = value;
        });
      },
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