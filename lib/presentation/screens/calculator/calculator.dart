import 'dart:io';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/logger.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/center_button.dart';
import '../../widgets/custom_bottom_bar.dart';
import 'marginCalculator.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _formKeyAlerta = GlobalKey<FormState>();
  final _formKeyAnuncio = GlobalKey<FormState>();
  final _capitalController = TextEditingController();
  final _riskController = TextEditingController();
  final _entryController = TextEditingController();
  final _stopController = TextEditingController();
  final _analysisController = TextEditingController();
  final PageController _pageController = PageController();
  File? _selectedImage;
  int _selectedIndex = 0;

  @override
  void dispose() {
    _entryController.dispose();
    _stopController.dispose();
    _capitalController.dispose();
    _riskController.dispose();

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
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
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
                const SizedBox(height: 14),
                Text('Calculadora', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600 , fontSize: 22)),
                Text('Gestión de posiciones', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500 , fontSize: 16)),
                const SizedBox(height: 14),
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
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                         Color(0xFF055994),
                         Color(0xFF0866A7),
                         Color(0xFF4D8DB9)
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
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (value) {
                      setState(() => _selectedIndex = value);
                    },
                    children: [
                      _buildPositionForm(isDark),
                      _buildRiskForm(isDark),
                    ],
                  ),
                ),
              ],
            ),
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
        },
          icon: Icons.trending_up, border: true,

        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }


  Widget _buildPositionForm(bool isDark) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKeyAlerta,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D1D35) : Colors.white,
                borderRadius: BorderRadius.circular(25), // opcional: esquinas redondeadas
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Capital', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500),),
                        const SizedBox(height: 5),
                        TextFormField(
                            controller: _capitalController,
                            keyboardType: TextInputType.number,
                            decoration:  InputDecoration(
                                hintText: '\$10,000',
                                hintStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: const   Color(0xFF595959))
                            )
                        ),
                        const SizedBox(height: 10),
                        Text('Riesgo %', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500),),
                        const SizedBox(height: 5),
                        TextFormField(
                            controller: _capitalController,
                            keyboardType: TextInputType.number,
                            decoration:  InputDecoration(
                                hintText: '1%',
                                hintStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: const   Color(0xFF595959))
                            )
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Entrada',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  TextFormField(
                                    controller: _entryController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: '\$1.0850',
                                      hintStyle: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF595959),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stop Loss',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  TextFormField(
                                    controller: _entryController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: '\$1.0800',
                                      hintStyle: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF595959),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F2), // 👈 white oscuro
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 90,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              gradient: LinearGradient(colors: [
                                Color(0xFF066BAF),
                                Color(0xFF023961)
                              ])
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text('Tamaño de Posición', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),)),
                                Expanded(child: Text('\$21,700', style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white),))
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const MarginProgressBar(percent: 0.0217),
                        const MarginProgressBar(percent: 0.302),
                        const MarginProgressBar(percent: 0.95),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                height: 70,
                                decoration:  BoxDecoration(border: Border.all(color: const Color(0xFF2E4A66)), borderRadius: const BorderRadius.all(Radius.circular(12))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Unidades/Lotes',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,fontSize: 16)),
                                    const Text('0.2')
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                height: 70,
                                decoration:  BoxDecoration(border: Border.all(color: const Color(0xFF2E4A66)), borderRadius: const BorderRadius.all(Radius.circular(12))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Riesgo', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,fontSize: 16),),
                                    Container(padding: const EdgeInsets.all(3),decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: const  Color(0xFFFF9496)),child:  Text('\$100', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,fontSize: 15, color: const Color(0xFF870205))))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox(
                      width: 140,
                      child: ElevatedButton(onPressed: (){},
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(const Color(0xFF0D1D35).withValues(alpha: 0.50))), child: const Row(
                          children: [
                            Text('Limpiar'),
                            SizedBox(width: 4,),
                            Icon(Icons.sync_outlined)
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskForm(bool isDark) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKeyAnuncio,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D1D35) : Colors.white,
                borderRadius: BorderRadius.circular(25), // opcional: esquinas redondeadas
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Entrada',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  TextFormField(
                                    controller: _entryController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: '\$1.0850',
                                      hintStyle: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF595959),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stop Loss',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  TextFormField(
                                    controller: _entryController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: '\$1.0800',
                                      hintStyle: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF595959),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Capital', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500),),
                        const SizedBox(height: 5),
                        TextFormField(
                            controller: _capitalController,
                            keyboardType: TextInputType.number,
                            decoration:  InputDecoration(
                                hintText: '\$1.095',
                                hintStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: const   Color(0xFF595959))
                            )
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F2), // 👈 white oscuro
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 90,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              gradient: LinearGradient(colors: [
                                Color(0xFF3DD5B8),
                                Color(0xFF6EDFCA),
                                Color(0xFF86E5D3),
                                Color(0xFF9EEADB),
                                Color(0xFFB6EFE4),
                                Color(0xFFCFF5ED),
                                Color(0xFF6CF7DD)
                              ])
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text('Ratio R:R', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600),)),
                                Expanded(child: Text('1:2', style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w600),))
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 90,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              gradient: LinearGradient(colors: [
                                Color(0xFF3DD5B8),
                                Color(0xFF066BAF),
                              ])
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text('Ganacia estimada', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600),)),
                                Expanded(child: Text('+\$900', style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w600),))
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                height: 70,
                                decoration:  BoxDecoration(border: Border.all(color: const Color(0xFF2E4A66)), borderRadius: const BorderRadius.all(Radius.circular(12))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Unidades/Lotes',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,fontSize: 16)),
                                    const Text('0.2')
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                height: 70,
                                decoration:  BoxDecoration(border: Border.all(color: const Color(0xFF2E4A66)), borderRadius: const BorderRadius.all(Radius.circular(12))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Riesgo', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,fontSize: 16),),
                                    Container(padding: const EdgeInsets.all(3),decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: const  Color(0xFFFF9496)),child:  Text('\$300.000', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,fontSize: 15, color: const Color(0xFF870205))))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox(
                      width: 140,
                      child: ElevatedButton(onPressed: (){},
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(const Color(0xFF0D1D35).withValues(alpha: 0.50))), child: const Row(
                          children: [
                            Text('Limpiar'),
                            SizedBox(width: 4,),
                            Icon(Icons.sync_outlined)
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _clearAlertForm() {
    _capitalController.clear();
    _entryController.clear();
    _riskController.clear();
    _analysisController.clear();

  }

  void _clearAdvertForm() {
  }


}