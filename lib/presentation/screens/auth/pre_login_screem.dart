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
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
  }


  Future<void> _login() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final data = await LoginStorage.getCredentials();

      if (data != null) {
        final email = data['email']!;
        final password = data['password']!;
        final rememberMe = await LoginStorage.getRememberMe();

        AppLogger.info('🔑 Formulario válido, intentando autenticación...');

        await ref.read(authStateProvider.notifier).login(
          email,
          password,
          rememberMe: rememberMe,
        );

        if (!mounted) return;

        AppLogger.info('✅ Login exitoso');
        NotificationService.showSuccessToast('¡Bienvenido!');

        if (!rememberMe) {
          await LoginStorage.saveCredentials(email: email, password: password);
        } else {
          await LoginStorage.clearCredentials();
        }

        context.go('/home');
      } else {
        if (!mounted) return;
        AppLogger.debug('⚠️ No hay credenciales guardadas');
        context.go('/login');
      }
    } catch (e) {
      NotificationService.showErrorToast('Error al iniciar sesión');
      AppLogger.error('❌ Error en login', error: e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
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
            Positioned(bottom: size.height * 0.03, left: 0, right: 0, child: Center(child: btn()),),
            Align(alignment: Alignment.topLeft, child: cabecera2(size)),
            Positioned(bottom: -size.height * 0.05 , child: imageInferior()),
            Align(alignment: Alignment.topCenter, child: cabecera1(size)),
            Align(alignment: Alignment.topCenter, child: logo(),),
            iconTrading(size),
            Positioned(top: size.height * 0.57, left: 0, right: 0, child: contenido(),),
          ],
        ),
      ),
    );
  }
  Widget btn() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isLoading
          ? const Column(
        key: ValueKey('loading'),
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor:
              AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Cargando...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          )
        ],
      )
          : Column(
        key: const ValueKey('button'),
        children: [
          RippleAnimation(
            color: const Color(0xFF7BB5D4),
            minRadius: 20,
            maxRadius: 40,
            repeat: true,
            ripplesCount: 8,
            duration: const Duration(milliseconds: 1200),
            child: GestureDetector(
              onTap: _login,
              child: Material(
                shape: const CircleBorder(),
                color: Colors.transparent,
                elevation: 6,
                child: Ink(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFD8E9F2),
                        Color(0xFF8EC3E2),
                        Color(0xFF7BB5D4),
                      ],
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
          Text(
            'Empezar',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }


  Widget iconTrading(Size size) {
    return Positioned(
      bottom: size.height * 0.33, right: -size.width * 0.2,
      child: Image.asset(
        'assets/images/iconoTrading.png',
        width: size.width * 1.4,
        fit: BoxFit.fitHeight,
      ),
    );
  }



  Widget logo(){
    return Image.asset('assets/images/logo.png',fit: BoxFit.contain,);
  }
  Widget imageInferior(){
    return Image.asset('assets/images/fondoPerfil.png',fit: BoxFit.fill);
  }
  Widget cabecera1(Size size) {
    return ClipPath(
      clipper: HeaderClipper1(),
      child: Container(
        height: size.height * 0.55,
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
        height: size.height * 0.58,
        width: size.width * 0.7,
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
  Widget contenido() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Bienvenido a',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        Text(
          'RedBlue FX',
          style: GoogleFonts.montserrat(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          'Trading profesional,',
          style: GoogleFonts.montserrat(
            fontSize: 15,
            color: Colors.white70,
          ),
        ),
        Text(
          'simplificado',
          style: GoogleFonts.montserrat(
            fontSize: 15,
            color: Colors.white70,
          ),
        ),
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









