import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class AuthLogin {

 static Future<void> showAccountInactiveDialog(BuildContext context, String message) async {
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
 static String extractErrorMessage(String errorString) {
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
 static Widget _buildStepWithLine({required IconData icon, required Color iconColor, required Color iconBgColor, required String title, required String subtitle, required bool isCompleted, bool isActive = false, bool showLine = false, bool lineActive = false,}) {
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