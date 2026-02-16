import 'dart:io';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redbluefx_mobile/core/utils/mirrorEffect.dart';
import '../../../core/utils/logger.dart';
import '../../providers/margin_provider.dart';
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
  final _takeProfitController = TextEditingController();
  final PageController _pageController = PageController();
  File? _selectedImage;
  int _selectedIndex = 0;
  late final FocusNode _capitalFocus;
  late final FocusNode _riskFocus;
  late final FocusNode _entryPriceFocus;
  late final FocusNode _stopFocus;
  late final FocusNode _takeFocus;
  bool _capitalFocused = false;
  bool _riskFocused = false;
  bool _entryFocused = false;
  bool _stopFocused = false;
  bool _takeFocused = false;

  @override
  void initState() {
    super.initState();

    _capitalFocus = FocusNode();
    _riskFocus = FocusNode();
    _entryPriceFocus = FocusNode();
    _stopFocus = FocusNode();
    _takeFocus = FocusNode();

    _capitalFocus.addListener(() {
      setState(() => _capitalFocused = _capitalFocus.hasFocus);
    });

    _riskFocus.addListener(() {
      setState(() => _riskFocused = _riskFocus.hasFocus);
    });

    _entryPriceFocus.addListener(() {
      setState(() => _entryFocused = _entryPriceFocus.hasFocus);
    });

    _stopFocus.addListener(() {
      setState(() => _stopFocused = _stopFocus.hasFocus);
    });

    _takeFocus.addListener(() {
      setState(() => _takeFocused = _takeFocus.hasFocus);
    });
  }

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
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 14),
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
                            'Posicion',
                            style: GoogleFonts.montserrat(
                              color: isDark ? Colors.white : _selectedIndex == 1 ? Colors.black87 : Colors.white,
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
                              color: isDark ? Colors.white : _selectedIndex == 1 ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                         Color(0xFF055994),
                         Color(0xFF0866A7),
                         Color(0xFF4D8DB9)
                      ], // azul intenso → claro
                    ),
                    boxShadow: [
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
                    if (_selectedImage != null &&
                        await _selectedImage!.exists()) {
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
          onAnuncios: () => AppLogger.info("Anuncios tapped"), onCenterTap: () { context.goNamed('home'); },
        ),
      ),
    );
  }


  Widget _buildPositionForm(bool isDark) {
    final calc = ref.watch(calculatorProvider);
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
                border: Border.all(color: const Color(0xFF005EA3).withValues(alpha: 0.4) , width: 1.5),
                borderRadius: BorderRadius.circular(25), // opcional: esquinas redondeadas
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Capital', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500),),
                        const SizedBox(height: 5),
                        Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _capitalFocused ? [
                            BoxShadow(
                              color: const Color(0xFF005EA3).withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                              : [],
                        ),
                        child: TextFormField(
                          controller: _capitalController,
                          focusNode: _capitalFocus,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            ref.read(calculatorProvider.notifier).setCapital(double.tryParse(value) ?? 0);
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _capitalFocused ? (isDark ? const Color(0xFF0D1D35) : const Color(0xFFFFFFFF)) : (isDark ? const Color(0xFF1A2E45) : const Color(0xFFFFFFFF)),
                            hintText: '\$1.0850',
                            hintStyle: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF595959).withValues(alpha: 0.7),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blue.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF0D6EFD),
                                width: 1.6,
                              ),
                            ),

                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                        const SizedBox(height: 10),
                        Text('Riesgo %', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500),),
                        const SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _riskFocused ? [
                              BoxShadow(
                                color: const Color(0xFF005EA3).withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ] : [],
                          ),
                          child: TextFormField(
                              controller: _riskController,
                              keyboardType: TextInputType.number,
                              focusNode: _riskFocus,
                              onChanged: (value) {
                                ref.read(calculatorProvider.notifier).setRiskPercent(double.tryParse(value) ?? 0);
                              },
                              decoration:  InputDecoration(
                                filled: true,
                                fillColor: _riskFocused ? (isDark ? const Color(0xFF0D1D35) : const Color(0xFFFFFFFF)) : (isDark ? const Color(0xFF1A2E45) : const Color(0xFFFFFFFF)),
                                hintText: '1%',
                                hintStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: const   Color(0xFF595959).withValues(alpha: 0.7)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(
                              color: Colors.blue.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                              ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF0D6EFD),
                              width: 1.6,
                            ),
                          ),
                              )
                          ),

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
                                  const SizedBox(height: 3),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: _entryFocused ? [
                                        BoxShadow(
                                          color: const Color(0xFF005EA3).withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ] : [],
                                    ),
                                    child: TextFormField(
                                      controller: _entryController,
                                      keyboardType: TextInputType.number,
                                      focusNode: _entryPriceFocus,
                                      onChanged: (value) {
                                            ref.read(calculatorProvider.notifier)
                                            .setEntry(double.tryParse(value) ?? 0);
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: _entryFocused ? (isDark ? const Color(0xFF0D1D35) : const Color(0xFFFFFFFF)) : (isDark ? const Color(0xFF1A2E45) : const Color(0xFFFFFFFF)),
                                        hintText: '\$1.0850',
                                        hintStyle: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF595959).withValues(alpha: 0.7),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.blue.withValues(alpha: 0.25),
                                            width: 1,
                                          ),
                                        ),

                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF0D6EFD),
                                            width: 1.6,
                                          ),
                                        ),

                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 14,
                                        ),
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
                                  const SizedBox(height: 3),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: _stopFocused ? [
                                        BoxShadow(
                                          color: const Color(0xFF005EA3).withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ] : [],
                                    ),
                                    child: TextFormField(
                                      controller: _stopController,
                                      keyboardType: TextInputType.number,
                                      focusNode: _stopFocus,
                                      onChanged: (value) {
                                        ref.read(calculatorProvider.notifier).setStop(double.tryParse(value) ?? 0);
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: _stopFocused ? (isDark ? const Color(0xFF0D1D35) : const Color(0xFFFFFFFF)) : (isDark ? const Color(0xFF1A2E45) : const Color(0xFFFFFFFF)),
                                        hintText: '\$1.0800',
                                        hintStyle: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF595959).withValues(alpha: 0.7),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.blue.withValues(alpha: 0.25),
                                            width: 1,
                                          ),
                                        ),

                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF0D6EFD),
                                            width: 1.6,
                                          ),
                                        ),

                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 14,
                                        ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF066BAF).withValues(alpha: 0.1), // 👈 white oscuro
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resultados', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
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
                                Expanded(child: Text('\$${calc.positionSize.toStringAsFixed(0)}', style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white))),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        MarginProgressBar(percent: calc.marginUsed * 100,),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                height: 80,
                                decoration:  BoxDecoration(border: Border.all(color: const Color(0xFF2E4A66)), borderRadius: const BorderRadius.all(Radius.circular(12))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Und./Lotes',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,fontSize: 16)),
                                    Text(calc.units.toStringAsFixed(2),)
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                height: 80,
                                decoration:  BoxDecoration(border: Border.all(color: const Color(0xFF2E4A66)), borderRadius: const BorderRadius.all(Radius.circular(12))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Riesgo', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,fontSize: 16),),
                                    Container(padding: const EdgeInsets.all(3),decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: const  Color(0xFFFF9496)),child:  Text('\$${calc.riskAmount.toStringAsFixed(0)}', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,fontSize: 15, color: const Color(0xFF870205))))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: 140,
                child: ElevatedButton(onPressed: (){
                    _capitalController.clear();
                    _riskController.clear();
                    _entryController.clear();
                    _stopController.clear();
                    ref.read(calculatorProvider.notifier).clear();
                },
                  style: ButtonStyle(backgroundColor: isDark ? const  WidgetStatePropertyAll(Color(0xFF0F172A)) : const  WidgetStatePropertyAll(Colors.white),
                    side: WidgetStatePropertyAll(
                      BorderSide(
                        color: isDark ? const Color(0xFF066BAF) : const Color(0xFF005EA3)  , // azul
                      ),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // opcional
                      ),
                    ),
                  ),
                  child:  Row(
                    children: [
                      Text('Limpiar', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0D1D35)),),
                      const SizedBox(width: 8,),
                      Icon(Icons.sync_outlined,color: isDark ? Colors.white : const Color(0xFF0D1D35),)
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskForm(bool isDark) {
    final calc = ref.watch(calculatorProvider);
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
                border: Border.all(color: const Color(0xFF005EA3).withValues(alpha: 0.4) , width: 1.5),
                borderRadius: BorderRadius.circular(25), // opcional: esquinas redondeadas
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 14),
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
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: _entryFocused ? [
                                        BoxShadow(
                                          color: const Color(0xFF005EA3).withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                          : [],
                                    ),
                                    child: TextFormField(
                                      controller: _entryController,
                                      keyboardType: TextInputType.number,
                                      focusNode: _entryPriceFocus,
                                      onChanged: (value) {
                                        ref.read(calculatorProvider.notifier).setEntry(double.tryParse(value) ?? 0);
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: _entryFocused ? (isDark ? const Color(0xFF0D1D35) : const Color(0xFFFFFFFF)) : (isDark ? const Color(0xFF1A2E45) : const Color(0xFFFFFFFF)),
                                        hintText: '\$1.0850',
                                        hintStyle: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF595959).withValues(alpha: 0.7),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.blue.withValues(alpha: 0.25),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF0D6EFD),
                                            width: 1.6,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 14,
                                        ),
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
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _stopController,
                                    keyboardType: TextInputType.number,
                                    focusNode: _stopFocus,
                                    onChanged: (value) {
                                      ref.read(calculatorProvider.notifier).setStop(double.tryParse(value) ?? 0);
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: _stopFocused ? (isDark ? const Color(0xFF0D1D35) : const Color(0xFFFFFFFF)) : (isDark ? const Color(0xFF1A2E45) : const Color(0xFFFFFFFF)),
                                      hintText: '\$1.0800',
                                      hintStyle: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF595959).withValues(alpha: 0.7),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.blue.withValues(alpha: 0.25),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF0D6EFD),
                                          width: 1.6,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Take Profit', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500),),
                        const SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _entryFocused ? [
                              BoxShadow(
                                color: const Color(0xFF005EA3).withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                                : [],
                          ),
                          child: TextFormField(
                              controller: _takeProfitController,
                              keyboardType: TextInputType.number,
                              focusNode: _takeFocus,
                              onChanged: (value) {
                                ref.read(calculatorProvider.notifier).setTakeProfit(double.tryParse(value) ?? 0);
                              },
                              decoration:  InputDecoration(
                                  filled: true,
                                  fillColor: _takeFocused ? (isDark ? const Color(0xFF0D1D35) : const Color(0xFFFFFFFF)) : (isDark ? const Color(0xFF1A2E45) : const Color(0xFFFFFFFF)),
                                  hintText: '\$1.095',
                                  hintStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: const   Color(0xFF595959).withValues(alpha: 0.7)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.blue.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF0D6EFD),
                                    width: 1.6,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF066BAF).withValues(alpha: 0.1), // 👈 white oscuro
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
                    ),
                    child: Column(
                      children: [
                        MirrorEffect(
                          repeat:true,
                          child: Container(
                            height: 90,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF3DD5B8),
                                /*  Color(0xFF6EDFCA),
                                  Color(0xFF86E5D3),
                                  Color(0xFF9EEADB),
                                  Color(0xFFB6EFE4),
                                  Color(0xFFCFF5ED),
                                  // 🔁 espejo
                                  Color(0xFFE5FFFA),
                                  Color(0xFFDAFBF5),
                                  Color(0xFFCFF7F0),
                                  Color(0xFFB6F3E8),
                                  Color(0xFF9EF0E0),*/
                                ],
                                stops: [
                                  0.12,
                                /*  0.21,
                                  0.26,
                                  0.31,
                                  0.38,
                                  0.43, // centro
                                  0.50,
                                  0.53,
                                  0.57,
                                  0.67,
                                  1.00,*/
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: Text('Ratio R:R', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),)),
                                  Expanded(child: Text(
                                    calc.rrRatio > 0
                                        ? '1:${calc.rrRatio.toStringAsFixed(0)}'
                                        : '--',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),)
                                ],
                              ),
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
                                Expanded(child: Text('Ganacia estimada', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        calc.profitUsd > 0
                                            ? '+\$${calc.profitUsd.toStringAsFixed(0)}'
                                            : '--',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Container(padding: const EdgeInsets.all(2) ,decoration: const BoxDecoration(color: Color(0xFFB3FFE6), borderRadius: BorderRadius.all(Radius.circular(10))),child: Center(child: Text('+${calc.profitPercent.toStringAsFixed(0)}% Sobre Capital', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),)))),

                                  ],
                                )
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
                                height: 80,
                                decoration:  BoxDecoration(border: Border.all(color: const Color(0xFF2E4A66)), borderRadius: const BorderRadius.all(Radius.circular(12))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Unidades/Lotes',style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,fontSize: 16)),
                                    Text(calc.units.toStringAsFixed(2))
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                height: 80,
                                decoration:  BoxDecoration(border: Border.all(color: const Color(0xFF2E4A66)), borderRadius: const BorderRadius.all(Radius.circular(12))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Riesgo', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,fontSize: 16),),
                                    Container(padding: const EdgeInsets.all(3),decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: const  Color(0xFFFF9496)),child:  Text('\$${calc.riskAmount.toStringAsFixed(0)}', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,fontSize: 15, color: const Color(0xFF870205))))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: 140,
                child: ElevatedButton(onPressed: (){
                  _capitalController.clear();
                  _riskController.clear();
                  _entryController.clear();
                  _stopController.clear();
                  _takeProfitController.clear();
                  ref.read(calculatorProvider.notifier).clear();
                },
                  style: ButtonStyle(backgroundColor: isDark ? const  WidgetStatePropertyAll(Color(0xFF0F172A)) : const  WidgetStatePropertyAll(Colors.white),
                    side: WidgetStatePropertyAll(
                      BorderSide(
                        color: isDark ? const Color(0xFF066BAF) : const Color(0xFF005EA3),// azul
                      ),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // opcional
                      ),
                    ),
                  ),
                  child:  Row(
                    children: [
                      Text('Limpiar', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0D1D35)),),
                      const SizedBox(width: 8,),
                      Icon(Icons.sync_outlined,color: isDark ? Colors.white : const Color(0xFF0D1D35),)
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }



}