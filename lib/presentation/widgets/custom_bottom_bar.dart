import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

class CustomBottomBar extends ConsumerWidget {
  final VoidCallback onNoticias;
  final VoidCallback onAnuncios;
  final BottomTab? selectedTab;
  const CustomBottomBar({
    super.key,
    required this.onNoticias,
    required this.onAnuncios,
    this.selectedTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curvaColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.basicBack
        : AppColors.basic;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SizedBox(
      height: 65 + bottomPadding,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 65 + bottomPadding),
            painter: _BottomBarPainter(curvaColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(
                Icons.article_outlined,
                "Noticias",
                selectedTab == BottomTab.noticias,
                onNoticias,
                context,
              ),
              const SizedBox(width: 80),
              _item(
                Icons.campaign_outlined,
                "Anuncios",
                selectedTab == BottomTab.anuncios,
                onAnuncios,
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, bool isSelected, VoidCallback onTap, BuildContext context,) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final color = isSelected ? const Color(0xFF066BAF) : Colors.white70;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding * 0.5),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarPainter extends CustomPainter {
  final Color color;

  _BottomBarPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double radius = 20; // <-- Radio de esquinas superiores
    const double curveHeight = -48; // <-- Ajusta la altura de la curva

    Path path = Path();

    // Esquina superior izquierda redondeada
    path.moveTo(0, size.height);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // Hasta el inicio de la curva
    path.lineTo(size.width * 0.35, 0);

    // Curva hacia arriba
    path.quadraticBezierTo(
      size.width * 0.5,
      curveHeight,
      size.width * 0.65,
      0,
    );

    // Esquina superior derecha redondeada
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Bajar hasta abajo y cerrar
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

