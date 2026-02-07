

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

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
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
  File? _selectedImage;
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
                          'Posicion',
                          style: GoogleFonts.montserrat(
                            color: _selectedIndex == 0 ? Colors.white : Colors
                                .black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
                          'Risk/Reward',
                          style: GoogleFonts.montserrat(
                            color: _selectedIndex == 1 ? Colors.white : Colors
                                .black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
                    transform: GradientRotation(BorderSide.strokeAlignCenter),
                    begin: Alignment.topRight,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
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
                    ]
                  ],
                ),
                thumbDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _selectedIndex == 0
                        ? [
                      const Color(0xFFB9060A),
                      const Color(0xFFE5060C),
                      const Color(0xFFE77779),
                    ] // rojo intenso → claro
                        : [
                      const Color(0xFF055994),
                      const Color(0xFF0866A7),
                      const Color(0xFF4D8DB9)
                    ], // azul intenso → claro
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-3, -3),
                      blurRadius: 12,
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
                  if (_selectedImage != null &&
                      await _selectedImage!.exists()) {
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
          onAnuncios: () => AppLogger.info("Anuncios tapped"),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom,),
        child: CenterFloatingButton(onPressed: () {
          AppLogger.info("Home");
          context.goNamed('home');
        },),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }


  Widget _buildCreateAlertForm(bool isDark) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKeyAlerta,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D1D35) : Colors.white,
                borderRadius: BorderRadius.circular(
                    10), // opcional: esquinas redondeadas
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                ],
              ),
            ),

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D1D35) : Colors.white,
                borderRadius: BorderRadius.circular(
                    10), // opcional: esquinas redondeadas
              ),
              child: Column(
                children: [

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _clearAlertForm() {
    _pairController.clear();
    _entryController.clear();
    _slController.clear();
    _analysisController.clear();

  }

  void _clearAdvertForm() {
    _titleController.clear();
    _contentController.clear();
  }


}