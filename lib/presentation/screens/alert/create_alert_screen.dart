

import 'dart:io';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
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
  final _slController = TextEditingController();
  final _contentController = TextEditingController();
  final PageController _pageController = PageController();
  AlertType? _selectedType;
  bool _isPublic = true;
  bool _isLoading = false;
  File? _selectedImage;
  bool _isPickingImage = false;
  int _selectedIndex = 0;

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
                  await _handleImagePick(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  await _handleImagePick(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _handleImagePick(ImageSource source) async {
    setState(() => _isPickingImage = true);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 60);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // Validar extensión
      final extension = pickedFile.path.split('.').last.toLowerCase();
      if (!(extension == 'png' || extension == 'jpg' || extension == 'jpeg')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solo se permiten imágenes PNG o JPG'),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => _isPickingImage = false);
        return;
      }

      //  Validar tamaño (máximo 1MB)
      final bytes = await file.length();
      if (bytes > 1000000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La imagen no debe superar 1MB'),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => _isPickingImage = false);
        return;
      }

      // Si pasa validaciones → guardar imagen
      setState(() => _selectedImage = file);
    }

    setState(() => _isPickingImage = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: 'RedBlue FX', icons: false),
      body: Column(
        children: [
          const SizedBox(height: 10),
          CustomSlidingSegmentedControl<int>(
            initialValue: _selectedIndex,
            innerPadding: const EdgeInsets.all(6),
            children: {
              0: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Alerta',
                      style: GoogleFonts.montserrat(
                        color: _selectedIndex == 0 ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.trending_up,
                      size: 20,
                      color: _selectedIndex == 0
                          ? Colors.white
                          : Colors.red.shade300,
                    ),
                  ],
                ),
              ),
              1: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Anuncio',
                      style: GoogleFonts.montserrat(
                        color: _selectedIndex == 1 ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.campaign_rounded,
                      size: 20,
                      color: _selectedIndex == 1
                          ? Colors.white
                          : Colors.blue.shade300,
                    ),
                  ],
                ),
              ),
            },
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFCECECE),
                  Color(0xFFEFEFEF),
                  Color(0xFFEFEFEF),
                ],
                transform:GradientRotation(BorderSide.strokeAlignCenter),
                begin: Alignment.topRight,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-3, -3),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(3, 3),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
              ],
            ),
            thumbDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _selectedIndex == 0
                    ? [const Color(0xFFEC0006), const Color(0xFFFFCDD2)] // rojo intenso → claro
                    : [const Color(0xFF066BAF), const Color(0xFF90CAF9)], // azul intenso → claro
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-3, -3),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(3, 3),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
              ],
            ),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            onValueChanged: (value) async {
              setState(() => _selectedIndex = value);
              if (_selectedImage != null && await _selectedImage!.exists()) {
                await _selectedImage!.delete();
              }

              setState(() {
                _selectedImage = null;
              });
              _pageController.animateToPage(
                value,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            },
          ),
          const SizedBox(height: 12),
          // === CONTENIDO CAMBIANTE ===
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() => _selectedIndex = value);
              },
              children: [
                _buildCrearAlertaForm(),
                _buildCrearAnuncioForm(),
              ],
            ),
          ),
        ],
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

  Widget _buildCrearAlertaForm() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up, color: Color(0xFFE63330), size: 30),
                const SizedBox(width: 8),
                Text('Crear Alerta',
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
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
                    flex: 2,
                    child: _buildSelectableChip(
                        label: 'Compra',
                        icon: Icons.arrow_downward,
                        value: AlertType.buy,
                        color: Colors.green
                    ),
                  ),
                  const Spacer(flex: 3,),
                  //const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
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
              maxLength: 20,
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
                            icon: const Icon(Icons.delete, color: Colors.red),
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
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _tpControllers.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label:  const Text("Agregar TP"),
                    ),
                  ),
              ],
            ),
            Text('Puedes agregar varios niveles de TP (máximo 5)', style: GoogleFonts.montserrat(fontSize: 10),),
            const SizedBox(height: 8),
            TextFormField(
              controller: _slController,
              decoration: const InputDecoration(
                labelText: 'SL ⛔',
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
                labelText: 'Análisis (Opcional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLength: 120,
              maxLines: null,
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
            imagenSwitch(),
            const SizedBox(height: 24),
            ElevatedButton(
              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFE63330)), elevation: WidgetStatePropertyAll(8)),
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
    );
  }
  Widget _buildCrearAnuncioForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.campaign, color: Color(0xFFE63330), size: 30),
              const SizedBox(width: 8),
              Text('Crear Anuncio',
                style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Contenido',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          imagenSwitch(),
          ElevatedButton(
            style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFE63330)), elevation: WidgetStatePropertyAll(8)),
            onPressed: () {},
            child: Text('Publicar Anuncio',
                style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget imagenSwitch(){
    return Column(
      children: [
        Row(
          children: [
            Expanded(
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
                            ? Image.asset(
                          'assets/icons/iconCamara.png',
                          fit: BoxFit.contain,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: const Text(
                              "Subir Imagen (Opcional)",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Text('PNG, JPG hasta 1MB', style: TextStyle(fontSize: 8),)
                        ],
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
          subtitle: const Text('Las alertas públicas son visibles para todos los usuarios', style: TextStyle(fontSize: 12),),
          value: _isPublic,
          onChanged: (value) => setState(() => _isPublic = value),
        ),
      ],
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