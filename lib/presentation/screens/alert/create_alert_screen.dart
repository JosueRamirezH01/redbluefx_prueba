

import 'dart:io';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redbluefx_mobile/core/theme/app_theme.dart';
import 'package:redbluefx_mobile/domain/entities/adverts.dart';
import 'package:redbluefx_mobile/domain/entities/uploadimage.dart';
import 'package:redbluefx_mobile/presentation/providers/adverts_provider.dart';
import '../../../core/utils/borderPainter.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/alert.dart';
import '../../providers/alert_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/center_button.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/previewAdvert.dart';
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
  final _contentController = TextEditingController();
  final _pairController = TextEditingController();
  final List<TextEditingController> _tpControllers = [TextEditingController()];
  final _entryController = TextEditingController();
  final _slController = TextEditingController();
  final _analysisController = TextEditingController();
  final PageController _pageController = PageController();
  AlertType? _selectedType;
  bool _isPublic = true;
  bool _isFeatured = false;
  bool _isLoadingAlerta = false;
  bool _isLoadingAnuncio = false;
  File? _selectedImage;
  bool _isPickingImage = false;
  int _selectedIndex = 0;

  @override
  void dispose() {
    _pairController.dispose();
    _entryController.dispose();
    _slController.dispose();
    _analysisController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    for (var c in _tpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _openPreviewAlert() async {
    if (_selectedType == null) {
      Fluttertoast.showToast(msg: 'Por favor selecciona un tipo: Comprar o Vender', backgroundColor: Colors.redAccent, gravity: ToastGravity.BOTTOM, toastLength: Toast.LENGTH_LONG);
      return;
    }
    if (!_formKeyAlerta.currentState!.validate()) return;

    final takeProfits = _tpControllers.map((c) => c.text.trim()).toList();

    if (takeProfits.any((tp) => tp.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los Take Profit deben estar completos'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    final alertDraft = Alert(
      id: '',
      pair: _pairController.text.trim(),
      entry: _entryController.text.trim(),
      stopLoss: _slController.text.trim(),
      takeProfits: _tpControllers.map((c) => c.text).toList(),
      analysis: _analysisController.text,
      type: _selectedType!,
      isPublic: _isPublic,
      createdAt: DateTime.now(),
      createdBy: '',
    );

    showDialog(
      context: context,
      builder: (_) => TradingAlertPreviewDialog(alert: alertDraft, onConfirm: _submitFormAlert, image: _selectedImage,),
    );

  }
  Future<void> _openPreviewAdverts() async {

    if (!_formKeyAnuncio.currentState!.validate()) return;

    final advertDraft = Advert(
      id: '',
      isFeatured: _isFeatured,
      createdAt: DateTime.now(),
      createdBy: '',
      content: _contentController.text,
      title: _titleController.text,
    );

    showDialog(
      context: context,
      builder: (_) => AdvertPreviewDialog(advert: advertDraft, onConfirm: _submitFormAnuncio, image: _selectedImage,),
    );

  }

  Future<void> _submitFormAlert() async {
    setState(() => _isLoadingAlerta = true);

    final List<String> takeProfits = _tpControllers.map((c) => c.text.trim()).toList();
    uploadimage? uploadedImage;

    try {

      if (_selectedImage != null) {
        uploadedImage = await ref.read(profileProvider.notifier).pickAndUploadImageGlobal(_selectedImage!.path);
        if (uploadedImage == null) {
          AppLogger.debug('❌ Error al subir la imagen');
        }
      }

       await ref.read(alertsProvider.notifier).createAlert(
        pair: _pairController.text,
        entry: _entryController.text,
        stopLoss: _slController.text,
        analysis: _analysisController.text,
        takeProfits: takeProfits,
        image: uploadedImage?.name ?? '',
        imageUrl: uploadedImage?.url,
        type: _selectedType!,
        isPublic: _isPublic,
      );
      if (mounted) {
        Fluttertoast.showToast(
            msg: "Alerta creada correctamente",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
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
        setState(() => _isLoadingAlerta = false);
      }
    }
  }
  Future<void> _submitFormAnuncio() async {

    uploadimage? uploadedImage;
    setState(() => _isLoadingAnuncio = true);

    try {


      if (_selectedImage != null) {
        uploadedImage = await ref.read(profileProvider.notifier).pickAndUploadImageGlobal(_selectedImage!.path);
        if (uploadedImage == null) {
          AppLogger.debug('❌ Error al subir la imagen');
        }
      }
      await ref.read(advertsProvider.notifier).createAdvert(
        title: _titleController.text,
        content: _contentController.text,
        image: uploadedImage?.url,
        isFeatured: _isFeatured,
      );

      if (mounted) {
        Fluttertoast.showToast(
            msg: "Anuncio creado correctamente",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.of(context).pop();
      }
    } catch (e, stack) {
      AppLogger.error('Error al crear anuncio', error: e, stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear el anuncio. Por favor, intenta de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAnuncio = false);
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
      setState(() =>  _selectedImage = file);
    }

    setState(() => _isPickingImage = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const SharedAppBar(title: 'RedBlue FX', icons: false),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomLeft,
              radius: 0.8,
              colors: [
                const Color(0xFF0D1D35).withValues(alpha: 0.3),
                const Color(0xFF0D1D35).withValues(alpha: 0.3),
                const Color(0xFFFF0006).withValues(alpha: 0.01),
              ],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              CustomSlidingSegmentedControl<int>(
                initialValue: _selectedIndex,
                innerPadding: const EdgeInsets.all(10),
                children: {
                  0: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Señal',
                          style: GoogleFonts.montserrat(
                            color: isDark ? Colors.white : _selectedIndex == 1 ? Colors.black87 : Colors.white,
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
                              : Colors.red,
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
                            color: isDark ? Colors.white : _selectedIndex == 1 ? Colors.white : Colors.black87,
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
                              : const Color(0xFF076BB0),
                        ),
                      ],
                    ),
                  ),
                },
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2433) : null,
                  gradient: isDark ? const LinearGradient(
                    colors: [Color(0xFF1E2433), Color(0xFF1E2433)],
                  ) : const LinearGradient(
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
                  boxShadow:  [
                    if(!isDark)...[
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(-3, -3),
                      blurRadius: 6,
                      spreadRadius: -1,
                    ),
                    const BoxShadow(
                      color: Color(0x33000000),
                      offset: Offset(3, 3),
                      blurRadius: 6,
                      spreadRadius: -1,
                    ),
                  ],
                    const BoxShadow(
                      color: Colors.white,
                      blurRadius: 12,
                      spreadRadius: -6,
                    ),
                  ],
                ),
                thumbDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _selectedIndex == 0
                        ? [const Color(0xFFB9060A), const Color(0xFFE5060C), const Color(0xFFE77779),] // rojo intenso → claro
                        : [const Color(0xFF055994), const Color(0xFF0866A7), const Color(0xFF4D8DB9)], // azul intenso → claro
                  ),
                  boxShadow:   [
                    if(!isDark)...[
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-3, -3),
                        blurRadius: 12,
                        spreadRadius: -1,
                      ),
                      const  BoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(3, 3),
                        blurRadius: 6,
                        spreadRadius: -1,
                      ),
                  ],
                    const BoxShadow(
                      color: Colors.white,
                      blurRadius: 3,
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
                  if (value == 0) {
                    _clearAdvertForm();
                  } else {
                    _clearAlertForm();
                  }
                  _pageController.animateToPage(
                    value,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              // === CONTENIDO CAMBIANTE ===
              const SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (value) {
                    setState(() => _selectedIndex = value);
                  },
                  children: [
                    _buildCreateAlertForm(isDark),
                    _buildCreateAdvertForm(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomBar(
          onNoticias: () {
            AppLogger.info("Noticias tapped");
            context.pushNamed('notice_list');
          },
          onAnuncios: () => AppLogger.info("Anuncios tapped"), onCenterTap: () {  context.goNamed('home');},
        ),
      ),
    );
  }

  Widget _buildSelectableChip({required String label, required IconData icon, required AlertType value, required Color color, required Color colorRelleno, required Color textColor}) {
    final bool isSelected = _selectedType == value;
    return ChoiceChip(
      showCheckmark: false,
      label: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 14, color: isSelected ?  textColor : null)),
          const SizedBox(width: 4),
          Icon(icon, size: 14, color: color),
        ],
      ),
      selected: isSelected,
      selectedColor: colorRelleno,
      backgroundColor: Theme.of(context).createChip,
      shape: StadiumBorder(
        side: BorderSide(
          color: color,
          width: 1,
        ),
      ),
      onSelected: (_) {
        setState(() {
          _selectedType = value;
        });
      },
    );
  }

  Widget _buildCreateAlertForm(bool isDark) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKeyAlerta,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D1D35):Colors.white,
                borderRadius: BorderRadius.circular(10), // opcional: esquinas redondeadas
              ),
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text('Crear Señal',
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Tipo',
                      labelStyle: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w500),
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
                          color:  isDark ? const Color(0xFF3DD5B8) : const Color(0xFF10B981),
                          textColor: isDark ? Theme.of(context).textChip : Colors.black87,
                          colorRelleno: isDark ? const Color(0xFFDCFCE7).withValues(alpha: 0.9) : const Color(0xFFDCFCE7),
                        ),
                        const SizedBox(width: 20),
                        _buildSelectableChip(
                          label: 'Venta',
                          icon: Icons.arrow_downward,
                          value: AlertType.sell,
                          color: const Color(0xFFDD2E44),
                          textColor: isDark ? Theme.of(context).textChip : Colors.black87,
                          colorRelleno:isDark ? const Color(0xFFFFE1E0).withValues(alpha: 0.9) : const Color(0xFFFFE1E0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pairController,
                    maxLength: 20,
                    decoration:  InputDecoration(
                      labelText: 'Par de Divisas',
                      floatingLabelStyle: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w500),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: GoogleFonts.poppins(fontSize: 14),
                      hintStyle: GoogleFonts.poppins(fontSize: 14,color: const Color(0xFF818181)),
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _entryController,
                    //keyboardType: TextInputType.number,
                    decoration:  InputDecoration(
                      labelText: 'Entrada ➡️',
                      floatingLabelStyle: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w500),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: GoogleFonts.poppins(fontSize: 14),
                      hintStyle: GoogleFonts.poppins(fontSize: 14,color: const Color(0xFF818181)),
                      hintText:'1.0820',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final priceRegex = RegExp(r'^\d+(\.\d+)?$');
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una entrada';
                      }
                      if (!priceRegex.hasMatch(value.trim())) {
                        return 'Formato inválido. Ej: 1.0820';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text('Take Profit 🎯',  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, )),
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
                                    labelText: 'TP ${i + 1} :1.08423 ',
                                    labelStyle: GoogleFonts.poppins(fontSize: 14,color: const Color(0xFF818181)),
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    final priceRegex = RegExp(r'^\d+(\.\d+)?$');
                                    if (value == null || value.isEmpty) return 'Ingresa un TP';
                                    if (!priceRegex.hasMatch(value.trim())) {
                                      return 'Formato inválido. Ej: 1.0820';
                                    }
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
                      if (_tpControllers.length < 5)
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _tpControllers.add(TextEditingController());
                              });
                            },
                            icon: Icon(Icons.add, color: isDark ? const Color(0xFF0881D9) : const Color(0xFF005EA3), size: 20),
                            label: Text("Agregar TP", style: GoogleFonts.poppins(fontSize: 15, color: isDark ? const Color(0xFF0881D9) : const Color(0xFF005EA3), fontWeight: FontWeight.w600),),
                          ),
                        ),
                      Text('Puedes agregar varios niveles de TP (máximo 5)', style: GoogleFonts.poppins(fontSize: 14,fontWeight: FontWeight.w400),),
                      // Botón para agregar otro TP

                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _slController,
                    decoration: InputDecoration(
                      labelText: 'SL ⛔',
                      floatingLabelStyle: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w500),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final priceRegex = RegExp(r'^\d+(\.\d+)?$');
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un SL';
                      }
                      if (!priceRegex.hasMatch(value.trim())) {
                        return 'Formato inválido. Ej: 1.0820';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _analysisController,
                    decoration: const InputDecoration(
                      labelText: 'Análisis (Opcional)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLength: 120,
                    maxLines: null,
                  ),
                  const SizedBox(height: 10),
                  imagenSwitch(isDark),
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
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  if(!isDark)
                    const BoxShadow(
                        color: Color(0xFFFF1B21),
                        blurRadius: 20,      // intensidad
                        offset: Offset(2, 8) // altura
                    ),

                  const BoxShadow(
                      color: Color(0xFF721723),
                      blurRadius: 20,      // intensidad
                      offset: Offset(0, 8) // altura
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onPressed: _isLoadingAlerta ? null : _openPreviewAlert,
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
  Widget _buildCreateAdvertForm(bool isDark) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKeyAnuncio,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D1D35):Colors.white,
                borderRadius: BorderRadius.circular(10), // opcional: esquinas redondeadas
              ),
              child: Column(
                children: [
                  Text('Crear Anuncio',
                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      floatingLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 19),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un contenido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _contentController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Contenido',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      floatingLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 19),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un contenido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  imagenSwitch(isDark),
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

                           /* Text(
                              'Las alertas públicas son visibles para todos los usuarios',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),*/
                          ],
                        ),
                      ),

                      Switch(
                        value: _isFeatured,
                        onChanged: (value) {
                          setState(() {
                            _isFeatured = value;
                          });

                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
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
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                if(!isDark)
                const BoxShadow(
                    color: Color(0xFFFF1B21),
                    blurRadius: 25,      // intensidad
                    offset: Offset(2, 8) // altura
                ),
                const BoxShadow(
                    color: Color(0xFF721723),
                    blurRadius: 20,      // intensidad
                    offset: Offset(2, 8) // altura
                ),
              ],
            ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onPressed: () {
                  _openPreviewAdverts();
                },
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
      ),
    );
  }

  Widget imagenSwitch(bool isDark){
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickImage,
                child: CustomPaint(
                  painter: DashedBorderPainter(borderColor: Theme.of(context).borderColor,),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F2D4A) : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
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
                                ? const Icon(Icons.photo_outlined, color: Color(0xFFFF0006) , size: 20)
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

  void _clearAlertForm() {
    _pairController.clear();
    _entryController.clear();
    _slController.clear();
    _analysisController.clear();

    for (final c in _tpControllers) {
      c.clear();
    }

    _tpControllers
      ..clear()
      ..add(TextEditingController());

    _selectedType = null;
  }

  void _clearAdvertForm() {
    _titleController.clear();
    _contentController.clear();
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

