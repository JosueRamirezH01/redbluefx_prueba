import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/logger.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

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
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showAccountInactiveDialog(BuildContext context, String message) async {
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
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.access_time_outlined,
                color: Colors.orange.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Cuenta Pendiente',
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
            const Text(
              'Tu cuenta está pendiente de activación.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Un administrador debe aprobar tu cuenta antes de que puedas acceder.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Recibirás una notificación cuando tu cuenta sea activada.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                  child: const Text('¿No tienes cuenta?'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _extractErrorMessage(String errorString) {
    try {
      // Extraer el mensaje del JSON si existe
      final RegExp jsonRegex = RegExp(r'\{"message":"([^"]+)"\}');
      final match = jsonRegex.firstMatch(errorString);
      if (match != null) {
        return match.group(1) ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

    Future<void> _login() async {
      AppLogger.info('🔑 Iniciando proceso de login para: ${_emailController.text}');

      if (_formKey.currentState?.validate() ?? false) {
        try {
          AppLogger.info('🔑 Formulario válido, intentando autenticación...');

          await ref.read(authStateProvider.notifier).login(
                _emailController.text,
                _passwordController.text,
                rememberMe: _rememberMe,
              );

          AppLogger.info('✅ Login exitoso');
          NotificationService.showSuccessToast('¡Bienvenido!');

        } catch (e) {
          AppLogger.error('❌ Error en login', error: e);

          if (!mounted) return;

          String errorMessage = 'Error al iniciar sesión. Por favor intenta nuevamente.';
          final errorString = e.toString();

          // Manejar diferentes tipos de errores del backend
          if (errorString.contains('ACCOUNT_INACTIVE:')) {
            final message = errorString.replaceFirst('Exception: ACCOUNT_INACTIVE:', '');
            await _showAccountInactiveDialog(context, message);
            return;
          } else if (errorString.contains('INVALID_CREDENTIALS:')) {
            // Intentar extraer el mensaje específico del backend
            final backendMessage = _extractErrorMessage(errorString);
            if (backendMessage.isNotEmpty) {
              errorMessage = backendMessage;
            } else {
              errorMessage = 'Email o contraseña incorrectos. Por favor verifica tus datos.';
            }
          } else if (errorString.contains('ACCOUNT_NOT_VERIFIED:')) {
            final backendMessage = _extractErrorMessage(errorString);
            errorMessage = backendMessage.isNotEmpty
                ? backendMessage
                : 'Tu cuenta no ha sido verificada. Por favor revisa tu correo electrónico.';
          } else if (errorString.contains('ACCOUNT_BLOCKED:')) {
            final backendMessage = _extractErrorMessage(errorString);
            errorMessage = backendMessage.isNotEmpty
                ? backendMessage
                : 'Tu cuenta ha sido bloqueada. Por favor contacta a soporte.';
          } else if (errorString.contains('TOO_MANY_ATTEMPTS:')) {
            final backendMessage = _extractErrorMessage(errorString);
            errorMessage = backendMessage.isNotEmpty
                ? backendMessage
                : 'Demasiados intentos de inicio de sesión. Por favor, espera unos minutos antes de intentar nuevamente.';
          } else if (errorString.contains('NETWORK_ERROR:') || errorString.contains('conexión')) {
            errorMessage = 'Error de conexión. Por favor verifica tu conexión a internet.';
          } else if (errorString.contains('SERVER_ERROR:')) {
            errorMessage = 'Error del servidor. Por favor intenta nuevamente en unos momentos.';
          }

          // Mostrar toast con el error
          NotificationService.showErrorToast(errorMessage);

          // Log para debugging
          AppLogger.error('Error específico mostrado al usuario: $errorMessage');
        }
      } else {
        AppLogger.warning('⚠️ Formulario no válido');
        NotificationService.showWarningToast('Por favor completa todos los campos correctamente');
      }
    }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final size = MediaQuery.of(context).size;

    // Redireccionar si está autenticado
    if (authState.isAuthenticated) {
      AppLogger.info('✅ Usuario autenticado, redirigiendo a home');
      Future.microtask(() => context.go('/home'));
    }

    return Scaffold(
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
                      color: Colors.white.withOpacity(0.1),
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
                      color: Colors.white.withOpacity(0.1),
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
                                height: 150,
                                width: 150,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Título con animación
                          FadeInDown(
                            duration: const Duration(milliseconds: 1000),
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              'Bienvenido',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
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
                              'Inicia sesión para continuar',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
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
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _emailController,
                                      style: GoogleFonts.poppins(color: Colors.black),
                                      textInputAction: TextInputAction.done,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        labelStyle: GoogleFonts.poppins(
                                          color: Colors.grey[600],
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
                                      autocorrect: false,
                                      enableSuggestions: false,
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
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Campo de contraseña
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      style: GoogleFonts.poppins(color: Colors.black),
                                      autocorrect: false,
                                      enableSuggestions: false,

                                      decoration: InputDecoration(
                                        labelText: 'Contraseña',
                                        labelStyle: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                        ),
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          color: AppColors.primary,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: AppColors.primary,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible = !_isPasswordVisible;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      obscureText: !_isPasswordVisible,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor ingresa tu contraseña';
                                        }
                                        if (value.length < 6) {
                                          return 'La contraseña debe tener al menos 6 caracteres';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  
                                  // Olvidé mi contraseña
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => context.go('/forgot-password'),
                                      child: Text(
                                        '¿Olvidaste tu contraseña?',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Checkbox recordar sesión
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                        fillColor: WidgetStateProperty.resolveWith<Color>(
                                          (Set<WidgetState> states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return Colors.white;
                                            }
                                            return Colors.white.withOpacity(0.3);
                                          },
                                        ),
                                        checkColor: AppColors.primary,
                                        side: const BorderSide(color: Colors.white, width: 2),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Recordar sesión',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Botón de inicio de sesión
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: authState.isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: authState.isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : Text(
                                              'Iniciar Sesión',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Registro
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '¿No tienes cuenta?',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.go('/register'),
                                        child: Text(
                                          'Regístrate',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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