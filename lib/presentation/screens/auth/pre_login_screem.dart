import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

import '../../../core/services/loginStorage.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/logger.dart';
import '../../providers/auth_provider.dart';

class PreLoginScreen extends ConsumerStatefulWidget {
  const PreLoginScreen({super.key});

  @override
  ConsumerState<PreLoginScreen> createState() => _PreLoginScreenState();
}

class _PreLoginScreenState extends ConsumerState<PreLoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkAuth() async {
    AppLogger.debug('🔍 Starting auth check');

    try {
      final initialAuthState = ref.read(authStateProvider);

      // Si ya hay un estado autenticado de la persistencia, navegar directamente
      if (initialAuthState.isAuthenticated && initialAuthState.currentUser != null) {
        if (mounted) context.go('/home');
        return;
      }

      // Solo hacer checkAuthStatus si no hay estado persistido
      if (!initialAuthState.isAuthenticated) {
        await ref.read(authStateProvider.notifier).checkAuthStatus();
      }

      if (!mounted) return;

      final authState = ref.read(authStateProvider);
      if (authState.isAuthenticated) {
        if (mounted) context.go('/home');
      } else {
        if (mounted) context.go('/login');
      }
    } catch (e) {
      AppLogger.error('🚨 Unexpected error during auth check', error: e);
      if (mounted) context.go('/login');
    }
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
    final data = await LoginStorage.getCredentials();

    if (data != null) {
      String? email = data['email'];
      String? password = data['password'];
      bool rememberMe = await LoginStorage.getRememberMe();
      try {
        AppLogger.info('🔑 Formulario válido, intentando autenticación...');

        await ref.read(authStateProvider.notifier).login(
          email!,
          password!,
          rememberMe: rememberMe,
        );
        Future.microtask(() => context.go('/home'));
        AppLogger.info('✅ Login exitoso');
        NotificationService.showSuccessToast('¡Bienvenido!');
        if(!rememberMe){
          await LoginStorage.saveCredentials(email: email, password: password);
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
      Future.microtask(() => context.go('/login'));
      AppLogger.debug('⚠️ No hay credenciales guardadas');
    }

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF005EA3),
                    Color(0xFF004170),
                    Color(0xFF003256),
                    Color(0xFF002B49),
                    Color(0xFF002743),
                    Color(0xFF00223B),
                    Color(0xFF0D1C35),
                  ],)
            ),
          ),
          Positioned(bottom: size.height * 0.09,left: size.width * 0.38,child: btn()),
          Positioned(top: size.height * 0.2, child: cabecera2(size)),
          Positioned(bottom: -size.height * 0.1,child: imageInferior(size)),
          cabecera1(size),
          Padding(padding: EdgeInsets.only(left: size.width * 0.2), child: logo(),),
          Positioned(top: size.height * 0.01, right: -size.width * 0.19,child: iconTrading()),
          Positioned(bottom: size.height * 0.32, left: size.width * 0.2,child: contenido()),
        ],

      ),
    );
  }
  Widget btn() {
    return Column(
      children: [
        RippleAnimation(
          color: const Color(0xFF7BB5D4),
          minRadius: 20,
          maxRadius: 40,
          repeat: true,
          ripplesCount: 8,
          duration: const Duration(milliseconds: 1200),
          child: GestureDetector(
            onTap: () async {
              await _login();
            },
            child: Material(
              shape: const CircleBorder(),
              color: Colors.transparent,
              elevation: 6,
              child: Ink(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFD8E9F2),
                      Color(0xFF8EC3E2),
                      Color(0xFF7BB5D4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
                child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
          ),
          ),
        const SizedBox(height: 18),
        Text('Empezar', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white70),)
      ],
    );
  }

  Widget iconTrading(){
    return Image.asset('assets/images/iconoTrading.png',fit: BoxFit.fill, width: 500,height: 420,);
  }
  Widget logo(){
    return Image.asset('assets/images/logo.png',fit: BoxFit.contain,);
  }
  Widget imageInferior(Size size){
    return Image.asset('assets/images/fondoPerfil.png',fit: BoxFit.fill, width: size.width,height: size.height * 0.3,);
  }
  Widget cabecera1(Size size) {
    return ClipPath(
      clipper: HeaderClipper1(),
      child: Container(
        height: size.height * 0.506,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E1D35),
              Color(0xFF0E1D35), // gris superior
              Color(0xFF0E1D35), // azul oscuro
            ],
          ),

        ),
      ),
    );
  }
  Widget cabecera2(Size size){
    return ClipPath(
      clipper: HeaderClipper2(),
      child: Container(
        height: size.width * 0.69,
        width: size.width * 0.6,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF003B66),
              Color(0xFF005EA3),
            ],
          ),
        ),
      ),
    );
  }
  Widget contenido(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Bienvenido a', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w400, color: Colors.white),),
        Text('RedBlue FX', style: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.w600, color: Colors.white),),
        Text('Trading profesional, ', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),),
        Text('simplificado ', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),)

      ],
    );
  }
}


class HeaderClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Esquina superior izquierda
    path.moveTo(0, 0);

    // Arriba
    path.lineTo(size.width, 0);

    // Derecha
    path.lineTo(size.width, size.height - 20);

    // Curva inferior derecha
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - 20,
      size.height,
    );
    // Línea inferior inclinada
    path.lineTo(40, size.height - 60);

    // Curva inferior izquierda
    path.quadraticBezierTo(
      0,
      size.height - 70,
      0,
      size.height - 90,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
class HeaderClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 60);

    // curva inferior izquierda
    path.quadraticBezierTo(
      size.width * 0.05,
      size.height,
      size.width * 0.25,
      size.height - 10,
    );

    // línea inclinada inferior
    path.lineTo(size.width * 0.9, size.height - 30);

    // curva inferior derecha
    path.quadraticBezierTo(
      size.width,
      size.height - 30,
      size.width,
      size.height - 60,
    );

    // cerrar forma
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}









