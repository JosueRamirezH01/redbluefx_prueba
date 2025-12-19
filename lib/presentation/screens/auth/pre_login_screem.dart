import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

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
          Positioned(bottom: size.height * 0.1,left: size.width * 0.3,child: btn()),
          Positioned(top: size.height * 0.2, child: cabecera2(size)),
          Positioned(bottom: -size.height * 0.1,child: imageInferior(size)),
          cabecera1(size),
          Padding(padding: EdgeInsets.only(left: size.width * 0.2), child: logo(),),
          Positioned(top: size.height * 0.01, right: -size.width * 0.19,child: iconTrading()),
          Positioned(bottom: size.height * 0.32, left: size.width * 0.2,child: contenido()),
          Positioned(bottom: size.height * 0.1,left: size.width * 0.3,child: btn())
        ],

      ),
    );
  }
  Widget btn() {
    return const RippleAnimation(
      color: Color(0xFF3898CD),
      minRadius: 75,
      maxRadius: 140,
      ripplesCount: 6,
      duration:  Duration(milliseconds: 6 * 300),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Color(0xFF3898CD),
        child: Icon(
          Icons.trending_up,
          color: Colors.white,
          size: 50,
        ),
      ),
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
        Text('Bienvenido a', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w400),),
        Text('RedBlue FX', style: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.w600),),
        Text('Trading profesional, ', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w400),),
        Text('simplificado, ', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w400),)

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









