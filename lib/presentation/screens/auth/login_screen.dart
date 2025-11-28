
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
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
      useSafeArea: true,
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.90,
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con gradiente azul
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0D1D35),
                        Color(0xFF26559B),
                        Color(0xFF1A3968),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icono principal
                      Image.asset(
                        'assets/icons/icon_pendiente.png',
                        width: 46,
                        height: 46,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cuenta pendiente',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tu cuenta está en proceso de activación',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
            
                // Contenido principal
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Step 1: Registro completado
                      _buildStepWithLine(
                        icon: Icons.email,
                        iconColor: const Color(0xFF3B82F6),
                        iconBgColor: const Color(0xFF3B82F6).withOpacity(0.1),
                        title: 'Registro completado',
                        subtitle: 'Tu solicitud ha sido enviada exitosamente',
                        isCompleted: true,
                        showLine: true,
                        lineActive: true,
                      ),
            
                      // Step 2: Revisión en proceso
                      _buildStepWithLine(
                        icon: Icons.schedule,
                        iconColor: const Color(0xFF3B82F6),
                        iconBgColor: const Color(0xFF3B82F6).withOpacity(0.1),
                        title: 'Revisión en proceso',
                        subtitle: 'Un administrador está revisando la información',
                        isCompleted: false,
                        isActive: true,
                        showLine: true,
                        lineActive: false,
                      ),
            
                      // Step 3: Activación
                      _buildStepWithLine(
                        icon: Icons.check,
                        iconColor: Colors.grey.shade400,
                        iconBgColor: Colors.grey.shade200,
                        title: 'Activación',
                        subtitle: 'Recibirás un correo cuando tu cuenta esté lista',
                        isCompleted: false,
                        showLine: false,
                      ),
            
                      const SizedBox(height: 12),
            
                      // Mensaje informativo
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                          children: const [
                            TextSpan(text: 'Normalmente aprobamos cuentas en\nmenos de '),
                            TextSpan(
                              text: '24 horas.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
            
                      const SizedBox(height: 12),
            
                      // Botón Entendido
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF1B21),
                                  Color(0xFFBB0004),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                'Entendido',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
      //final errorString = e.toString();
     // final message = errorString.replaceFirst('Exception: ACCOUNT_INACTIVE:', '');
     // await _showAccountInactiveDialog(context, message);

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
        resizeToAvoidBottomInset: false,
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration:  const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF0D1D35),
                Color(0xFF073E6C),
                Color(0xFF034E87),
                Color(0xFF0D1D35),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomLeft,
                radius: 1.0,
                colors: [
                  const Color(0xFFE6332F).withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.0,
                  colors: [
                    const Color(0xFFE6332F).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                      FadeInDown(
                      duration: const Duration(milliseconds: 1000),
                      child: Hero(
                        tag: 'logo',
                        child: SizedBox(
                          width: 180,
                          height: 200,
                          child: Center(
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/Container.png',
                                height: 200,
                                width: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                      const SizedBox(height: 10,),
                      FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 400),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white24,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.transparent,
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Título Bienvenido
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        'Bienvenido',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Subtítulo
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        'Completa tus datos para ingresar',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Campo Email
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
                                          labelStyle: GoogleFonts.inter(
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

                                    // Campo Contraseña
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
                                        style: GoogleFonts.montserrat(color: Colors.black),
                                        autocorrect: false,
                                        enableSuggestions: false,

                                        decoration: InputDecoration(
                                          labelText: 'Contraseña',
                                          labelStyle: GoogleFonts.inter(
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

                                    const SizedBox(height: 16),

                                    // Recordar y Olvidaste contraseña
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Checkbox(
                                                value: _rememberMe,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _rememberMe = value ?? false;
                                                  });
                                                },
                                                side: BorderSide(
                                                  color: Colors.white.withOpacity(0.5),
                                                ),
                                                checkColor: Colors.white,
                                                fillColor: WidgetStateProperty.resolveWith(
                                                      (states) {
                                                    if (states.contains(MaterialState.selected)) {
                                                      return const Color(0xFF3498DB);
                                                    }
                                                    return Colors.transparent;
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Recordar',
                                              style: GoogleFonts.montserrat(
                                                color: Colors.white.withOpacity(0.9),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () => context.go('/forgot-password'),
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(0, 0),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: Text(
                                            '¿Olvidaste tu contraseña?',
                                            style: GoogleFonts.montserrat(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 14,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                    // Botón Entrar
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: authState.isLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFBB0004),
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

                                    // ¿No tienes cuenta?
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '¿No tienes cuenta?',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton(
                                            onPressed: () => context.go('/register'),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              minimumSize: const Size(0, 0),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Text(
                                              'Regístrate',
                                              style: GoogleFonts.montserrat(
                                                color: const Color(0xFFAFDDFC),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  )
              ),
            ),
          ),
        )
    );
  }


  Widget _buildStepWithLine({required IconData icon, required Color iconColor, required Color iconBgColor, required String title, required String subtitle, required bool isCompleted, bool isActive = false, bool showLine = false, bool lineActive = false,}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [

                  // Ondas SIN cambiar tamaño visual
                  if (isActive)
                    Positioned(
                      width: 80,
                      height: 80,
                      child: RippleAnimation(
                        color: iconColor.withOpacity(0.6),
                        minRadius: 12,
                        maxRadius: 20,
                        ripplesCount: 3,
                        repeat: true,
                        duration: const Duration(milliseconds: 1600),
                        child: const SizedBox(),
                      ),
                    ),

                  // círculo original
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                      border: isActive
                          ? Border.all(color: iconColor.withOpacity(0.3), width: 2)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),

                ],
              ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 25,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: lineActive
                        ? [
                      const Color(0xFF3B82F6),
                      const Color(0xFF3B82F6).withOpacity(0.3),
                    ]
                        : [
                      Colors.grey.shade300,
                      Colors.grey.shade300,
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFAFDDFC)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? const Color(0xFF005EA3)
                          : (isCompleted ? Colors.black87 : Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}