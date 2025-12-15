

import 'dart:io';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/borderPainter.dart';
import '../../../domain/entities/alert.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/previewAlert.dart';

class CreateAlertScreen extends ConsumerStatefulWidget {
  const CreateAlertScreen({super.key});

  @override
  ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
  final _formKeyAlerta = GlobalKey<FormState>();
  final _formKeyAnuncio = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final List<TextEditingController> _tpControllers = [TextEditingController()];
  final _entradaController = TextEditingController();
  final _slController = TextEditingController();
  final _contentController = TextEditingController();
  final PageController _pageController = PageController();
  AlertType? _selectedType;
  bool _isPublic = true;
  final bool _isLoadingAlerta = false;
  final bool _isLoadingAnuncio = false;
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
    showDialog(
      context: context,
      builder: (_) => const TradingAlertPreviewDialog(),
    );
   /* if (_selectedType == null) {
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
    }*/
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
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomLeft,
              radius: 0.8,
              colors: [
                const Color(0xFF0D1D35).withOpacity(0.3),
                const Color(0xFF0D1D35).withOpacity(0.3),
                const Color(0xFFFF0006).withOpacity(0.01),
              ],
            ),
          ),
          child: Column(
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
                          'Señal',
                          style: GoogleFonts.montserrat(
                            color: _selectedIndex == 0 ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
                            fontWeight: FontWeight.w600,
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
                        ? [const Color(0xFFEC0006), const Color(0xFFFFCDD2),] // rojo intenso → claro
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
        ),
      ),
    );
  }

  Widget _buildSelectableChip({required String label, required IconData icon, required AlertType value, required Color color, required Color colorRelleno,}) {
    final bool isSelected = _selectedType == value;
    final colors = Theme.of(context).colorScheme;

    return ChoiceChip(
      showCheckmark: false,
      label: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: isSelected ? colors.onSurface : colors.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            icon,
            size: 14,
            color: isSelected ? colors.onSurface : colors.onSurface,
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: colorRelleno,
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
        key: _formKeyAlerta,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), // opcional: esquinas redondeadas
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Crear Señal',
                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Tipo',
                      labelStyle: GoogleFonts.poppins(fontSize: 19, color: const Color(0xFF515151), fontWeight: FontWeight.w500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildSelectableChip(
                          label: 'Compra',
                          icon: Icons.arrow_upward,
                          value: AlertType.buy,
                          color: const Color(0xFF10B981),
                          colorRelleno: const Color(0xFFDCFCE7),
                        ),
                        const SizedBox(width: 20),
                        _buildSelectableChip(
                          label: 'Venta',
                          icon: Icons.arrow_downward,
                          value: AlertType.sell,
                          color: const Color(0xFFDD2E44),
                          colorRelleno: const Color(0xFFFFE1E0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    maxLength: 20,
                    decoration:  InputDecoration(
                      labelText: 'Par de Divisas',
                      floatingLabelStyle: GoogleFonts.poppins(fontSize: 19, color: const Color(0xFF515151), fontWeight: FontWeight.w500),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF555555)),
                      hintText: 'ej: GBP/JPY',
                      border: const OutlineInputBorder(),
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
                    decoration:  InputDecoration(
                      labelText: 'Entrada ➡️',
                      floatingLabelStyle: GoogleFonts.poppins(fontSize: 19, color: const Color(0xFF515151), fontWeight: FontWeight.w500),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF555555)),
                      hintText:'1.0820',
                      border: const OutlineInputBorder(),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text('Take Profit 🎯',  style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF515151), fontWeight: FontWeight.w500)),
                  ),
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
                      Text('Puedes agregar varios niveles de TP (máximo 5)', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF606060), fontWeight: FontWeight.w400),),
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
                            icon: const Icon(Icons.add, color: Color(0xFF005EA3), size: 20),
                            label: Text("Agregar TP", style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF005EA3), fontWeight: FontWeight.w600),),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _slController,
                    decoration: InputDecoration(
                      labelText: 'SL ⛔',
                      floatingLabelStyle: GoogleFonts.poppins(fontSize: 19, color: const Color(0xFF515151), fontWeight: FontWeight.w500),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: const OutlineInputBorder(),
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Es una Señal pública?',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Text(
                              'Las señales públicas son visibles para todos los usuarios',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      Switch(
                        value: _isPublic,
                        onChanged: (value) {
                          setState(() {
                            _isPublic = value;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF1B21),
                    Color(0xFFDD0E13),
                    Color(0xFFBB0004),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xFFED7053),
                      blurRadius: 16,
                      offset: Offset(2, 8)

                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoadingAlerta ? null : _submitForm,
                child: _isLoadingAlerta
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Crear Señal',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.trending_up, size: 25, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
  Widget _buildCrearAnuncioForm() {
    return Form(
      key: _formKeyAnuncio,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12), // opcional: esquinas redondeadas
            ),
            child: Column(
              children: [
                Text('Crear Anuncio',
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Título',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    floatingLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, color:const Color(0xFF515151), fontSize: 15),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Contenido',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    floatingLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, color:const Color(0xFF515151), fontSize: 15),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                imagenSwitch(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Destacar?',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          const SizedBox(height: 6),

                          Text(
                            '(Carrusel home)',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    Switch(
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF1B21),
                Color(0xFFDD0E13),
                Color(0xFFBB0004),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Color(0xFFED7053),
                  blurRadius: 16,      // intensidad
                  offset: Offset(2, 8) // altura
              ),
            ],
          ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child:  _isLoadingAnuncio
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  :   Row(
                mainAxisAlignment:  MainAxisAlignment.center,
                children: [
                  Text('Crear Anuncio',
                      style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 10),
                  const Icon(Icons.campaign,size: 25),

                ],
              ),
            ),
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
              child: GestureDetector(
                onTap: _pickImage,
                child: CustomPaint(
                  painter: DashedBorderPainter(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFF0006)),
                              color: const Color(0xFFFEE2E2),
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
                                ? const Icon(Icons.photo_outlined, color: Color(0xFFFF0006) , size: 30)
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
                              Text(
                                "Subir Imagen (Opcional)",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'PNG, JPG hasta 1MB',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF555555),
                                ),
                              )
                            ],
                          ),
                        ]
                    ),
                  ),
                ),
              ),
            ),
          ],
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

