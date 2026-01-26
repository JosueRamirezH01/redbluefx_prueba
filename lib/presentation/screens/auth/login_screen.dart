
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:redbluefx_mobile/core/services/loginStorage.dart';
import '../../../core/services/authLogin.dart';
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
        Future.microtask(() => context.go('/home'));
        AppLogger.info('✅ Login exitoso');
        NotificationService.showSuccessToast('¡Bienvenido!');
        if(_rememberMe){
          print('--------- ${_rememberMe}');
          await LoginStorage.saveCredentials(email: _emailController.text, password: _passwordController.text);
        }else{
          await LoginStorage.clearCredentials();
        }
      } catch (e) {
        AppLogger.error('❌ Error en login', error: e);

        if (!mounted) return;

        String errorMessage = 'Error al iniciar sesión. Por favor intenta nuevamente.';
        final errorString = e.toString();

        // Manejar diferentes tipos de errores del backend
        if (errorString.contains('ACCOUNT_INACTIVE:')) {
          final message = errorString.replaceFirst('Exception: ACCOUNT_INACTIVE:', '');
          await AuthLogin.showAccountInactiveDialog(context, message);
          return;
        } else if (errorString.contains('INVALID_CREDENTIALS:')) {
          // Intentar extraer el mensaje específico del backend
          final backendMessage = AuthLogin.extractErrorMessage(errorString);
          if (backendMessage.isNotEmpty) {
            errorMessage = backendMessage;
          } else {
            errorMessage = 'Email o contraseña incorrectos. Por favor verifica tus datos.';
          }
        } else if (errorString.contains('ACCOUNT_NOT_VERIFIED:')) {
          final backendMessage = AuthLogin.extractErrorMessage(errorString);
          errorMessage = backendMessage.isNotEmpty
              ? backendMessage
              : 'Tu cuenta no ha sido verificada. Por favor revisa tu correo electrónico.';
        } else if (errorString.contains('ACCOUNT_BLOCKED:')) {
          final backendMessage = AuthLogin.extractErrorMessage(errorString);
          errorMessage = backendMessage.isNotEmpty
              ? backendMessage
              : 'Tu cuenta ha sido bloqueada. Por favor contacta a soporte.';
        } else if (errorString.contains('TOO_MANY_ATTEMPTS:')) {
          final backendMessage = AuthLogin.extractErrorMessage(errorString);
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
    /*if (authState.isAuthenticated) {
      AppLogger.info('✅ Usuario autenticado, redirigiendo a home');
      Future.microtask(() => context.go('/home'));
    }*/

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
                  const Color(0xFFF1948A).withOpacity(0.4),
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
                    const Color(0xFFF1948A).withOpacity(0.4),
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
                                        )  ,
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


}