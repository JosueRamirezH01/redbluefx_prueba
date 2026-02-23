import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final bool _emailSent = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Navegar a la pantalla de verificación de código
      context.push('/verify-reset-code', extra: _emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Fondo con círculos animados
              Positioned(
                top: -100,
                right: -100,
                child: FadeIn(
                  duration: const Duration(seconds: 2),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -100,
                child: FadeIn(
                  duration: const Duration(seconds: 2),
                  delay: const Duration(milliseconds: 500),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
              
              // Contenido principal
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(flex: 1),
                          
                          // Logo con animación
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
                          
                          const SizedBox(height: 30),
                          
                          // Título con animación
                          FadeInDown(
                            duration: const Duration(milliseconds: 1000),
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              'Recuperar Contraseña',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // Subtítulo con animación
                          FadeInDown(
                            duration: const Duration(milliseconds: 1000),
                            delay: const Duration(milliseconds: 400),
                            child: Text(
                              'Ingresa tu correo electrónico y te enviaremos un email para recuperar tu contraseña.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          if (!_emailSent) ...[
                            // Formulario con animación
                            FadeInUp(
                              duration: const Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 600),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Campo de email
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: TextFormField(
                                        controller: _emailController,
                                        style: GoogleFonts.poppins(color: Colors.black),
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          labelStyle: GoogleFonts.poppins(
                                            color: AppColors.primary,
                                          ),
                                          floatingLabelBehavior: FloatingLabelBehavior.never,
                                          prefixIcon: const Icon(
                                            Icons.email_outlined,
                                            color: AppColors.primary,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor ingresa tu email';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Por favor ingresa un email válido';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 30),
                                    
                                    // Botón de enviar email
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: authState.isLoading ? null : _resetPassword,
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
                                                'Enviar Email',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // Mensaje de éxito con animación
                            FadeInUp(
                              duration: const Duration(milliseconds: 1000),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 80,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    '¡Email enviado!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Por favor revisa tu correo electrónico para continuar con el proceso de recuperación de contraseña.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 20),
                          
                          // Botón de volver
                          FadeInUp(
                            duration: const Duration(milliseconds: 1000),
                            delay: const Duration(milliseconds: 800),
                            child: TextButton(
                              onPressed: () => context.go('/login'),
                              child: Text(
                                'Volver al inicio de sesión',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          
                          const Spacer(flex: 1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 