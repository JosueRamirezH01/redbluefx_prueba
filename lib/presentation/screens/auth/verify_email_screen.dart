import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:async';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  final String fullName;
  
  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.fullName,
  });

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String _code = '';
  //bool _emailSent = true; // Ya se envió el email al registrarse
  int _resendAttempts = 0;
  final int _maxResendAttempts = 5;
  Timer? _resendTimer;
  int _resendCountdown = 0;
  bool _canResend = true;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    _updateCode();
  }

  void _updateCode() {
    _code = _controllers.map((controller) => controller.text).join();
    setState(() {});
  }

  void _onKeyPressed(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _verifyEmail() async {
    if (_code.length == 6) {
      try {
        await ref.read(authStateProvider.notifier).verifyEmail(widget.email, _code);
        
        if (mounted) {
          final authState = ref.read(authStateProvider);
          if (authState.error == null) {
            // Verificación exitosa, mostrar pantalla de éxito
            _showSuccessDialog();
          } else {
            // Mostrar error de verificación
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al verificar email: ${authState.error}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        // Error handled by provider
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '¡Email Verificado!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '¡Bienvenido ${widget.fullName}!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu email ha sido verificado exitosamente. Tu cuenta está pendiente de activación serás notificado cuando sea activada.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ir a Iniciar Sesión'),
            ),
          ),
        ],
      ),
    );
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60; // 1 minuto
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCountdown--;
      });

      if (_resendCountdown <= 0) {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  Future<void> _resendCode() async {
    if (!_canResend || _resendAttempts >= _maxResendAttempts) return;

    try {
      await ref.read(authStateProvider.notifier).resendEmailVerification(widget.email);
      
      if (mounted) {
        final authState = ref.read(authStateProvider);
        if (authState.error == null) {
          // Reenvío exitoso
          setState(() {
            _resendAttempts++;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Código reenviado ($_resendAttempts/$_maxResendAttempts)'),
              backgroundColor: Colors.green,
            ),
          );
          
          _startResendTimer();
        } else {
          // Mostrar error de reenvío
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al reenviar código: ${authState.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Error handled by provider
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reenviar código: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _pasteCode() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      final pastedText = clipboardData!.text!;
      if (pastedText.length == 6 && RegExp(r'^\d{6}$').hasMatch(pastedText)) {
        final digits = pastedText.split('');
        for (int i = 0; i < 6; i++) {
          _controllers[i].text = digits[i];
        }
        _updateCode();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El código debe tener 6 dígitos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.secondary.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    // Logo
                    FadeInDown(
                      duration: const Duration(milliseconds: 1000),
                      child: Hero(
                        tag: 'logo',
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 120,
                          width: 120,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Título
                    FadeInDown(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        'Verificar Email',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subtítulo
                    FadeInDown(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        'Hemos enviado un código de 6 dígitos a\n${widget.email}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Recordatorio de revisar spam
                    FadeInDown(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 500),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white.withOpacity(0.9),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '¿No lo encuentras? Revisa tu carpeta de spam o correo no deseado',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Campos de código
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 600),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              return Container(
                                width: 45,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: RawKeyboardListener(
                                  focusNode: FocusNode(),
                                  onKey: (event) => _onKeyPressed(event, index),
                                  child: TextFormField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      counterText: '',
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (value) => _onCodeChanged(index, value),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 20),

                          // Botón pegar código
                          TextButton.icon(
                            onPressed: _pasteCode,
                            icon: const Icon(
                              Icons.content_paste,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              'Pegar código',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botón verificar
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 800),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_code.length == 6 && !authState.isLoading) ? _verifyEmail : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                          ),
                          child: authState.isLoading
                              ? const CircularProgressIndicator(
                                  color: AppColors.primary,
                                )
                              : Text(
                                  'Verificar Email',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Reenviar código
                    if (_resendAttempts < _maxResendAttempts) ...[
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 1000),
                        child: TextButton(
                          onPressed: _canResend && !authState.isLoading ? _resendCode : null,
                          child: Text(
                            _canResend
                              ? '¿No recibiste el código? Reenviar ($_resendAttempts/$_maxResendAttempts)'
                              : 'Reenviar en ${_resendCountdown}s ($_resendAttempts/$_maxResendAttempts)',
                            style: GoogleFonts.poppins(
                              color: _canResend ? Colors.white : Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                              decoration: _canResend ? TextDecoration.underline : null,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 1000),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Has alcanzado el límite de reenvíos. Por favor contacta soporte si necesitas ayuda.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Botón volver
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 1200),
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          'Volver',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 