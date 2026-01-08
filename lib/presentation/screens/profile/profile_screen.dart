import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:redbluefx_mobile/presentation/widgets/feedbackDialog.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../../core/utils/logger.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Check for errors after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForErrors();
    });
  }

  void _checkForErrors() {
    final authState = ref.read(authStateProvider);
    final profileState = ref.read(profileProvider);

    // Show toast for auth errors
    if (authState.currentUser == null) {
      AppLogger.error('Usuario no encontrado en ProfileScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo cargar la información del usuario'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        // Redirect to login instead of breaking the screen
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) context.go('/login');
        });
      }
    }

    // Show toast for profile errors
    if (profileState.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileState.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showImagePickerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Seleccionar Origen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                ref.read(profileProvider.notifier).pickAndUploadImage(ImageSource.gallery, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                ref.read(profileProvider.notifier).pickAndUploadImage(ImageSource.camera, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final profileState = ref.watch(profileProvider);
    final user = authState.currentUser;
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    // Listen for profile errors and show toasts
    ref.listen(profileProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    });

    // Listen for auth errors (like deleteAccount) and show toasts
    ref.listen(authStateProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        AppLogger.debug('🔄 Logging: Auth error detected, showing toast to user');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

      // Redirect to sign in when account is successfully deleted
      if (previous?.isAuthenticated == true &&
          next.isAuthenticated == false &&
          next.error == null &&
          !next.isLoading &&
          previous?.currentUser != null &&
          next.currentUser == null) {
        AppLogger.debug('✅ Logging: Account deletion successful, redirecting to sign in');
        if (mounted) {
          // Show success message before redirecting
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta eliminada exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Redirect to sign in after a short delay
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              AppLogger.debug('🔄 Logging: Navigating to login screen after successful account deletion');
              context.go('/login');
            }
          });
        }
      }
    });

    return Scaffold(
        appBar: AppBar(
          title: Text('Mi Perfil', style: GoogleFonts.montserrat(fontSize: 17 , fontWeight: FontWeight.w600)),
          centerTitle: true,
          toolbarHeight: 75,
          leadingWidth: 70,
          leading: IconButton(
            style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFF19283F)), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)), side: BorderSide(color: Color(0xFF29374C))))),
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                  children: [
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/fondoPerfil.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF85C1E9),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Container(
                                width: 94,
                                height: 94,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade100,
                                      Colors.blue.shade50,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: user?.profilePictureUrl != null &&
                                      user!.profilePictureUrl!.isNotEmpty
                                      ? CachedNetworkImage(
                                    imageUrl: user.profilePictureUrl!,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    color: Colors.grey[200],
                                    child: Icon(Icons.person,
                                        size: 60, color: Colors.grey[500]),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 5,
                              child: GestureDetector(
                                onTap: profileState.isUploading
                                    ? null
                                    : () => _showImagePickerDialog(context, ref),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                            if (profileState.isUploading)
                              Container(
                                width: 132,
                                height: 132,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  color: Colors.black.withOpacity(0.4),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Nombre de usuario
                    Text(
                        user?.fullName ?? 'Usuario',
                        style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600 )

                    ),
                    // Email
                    Text(
                        user?.email ?? '',
                        style:GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.normal )

                    ),
                    const SizedBox(height: 16),
                    _buildSection(context, title: 'Cuenta', children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 9.0),
                        child: _resetPassword(),
                      ),

                      //if (user?.role == 'admin')
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Gestión de usuarios',
                        onTap: () {
                          context.pushNamed('adminUsers');
                        },
                      ),
                      _buildMenuItem(icon: isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined, title: 'Modo ${isDarkMode ? "oscuro" : "claro"}',trailing: SizedBox(
                        width: 51,
                        height: 31,
                        child: Stack(
                          children: [
                            // Border
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5E5EA),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Switch
                            CupertinoSwitch(
                              value: Theme.of(context).brightness == Brightness.dark,
                              trackColor: Colors.transparent,
                              activeColor: const Color(0xFF34C759),
                              onChanged: (value) async {
                                await Future.delayed(const Duration(milliseconds: 150));
                                ref.read(themeProvider.notifier).toggleTheme();
                              },
                            ),
                          ],
                        ),
                      ),
                      ),
                    ],
                    ),
                    const SizedBox(height: 12),
                    _buildSection(context, title: 'Soporte', children: [
                      _buildMenuItem(
                        icon: Icons.star_outline,
                        title: 'Feedback',
                        onTap: () {
                          showFeedbackDialog(context);
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: 'Ayuda y soporte',
                        onTap: () {
                          // TODO: Implementar ayuda
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.description_outlined,
                        title: 'Términos y privacidad',
                        onTap: () {
                          // TODO: Implementar términos
                        },
                      ),
                    ],
                    ),
                    const SizedBox(height: 12),

                    _buildSection(context, children: [
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Cerrar sesión',
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              insetPadding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.05,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Color(0xFFE6332F),
                                  width: 2,
                                ),
                              ),
                              title: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFEF3F2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFEE4E2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.logout,
                                            color: Color(0xFFD92D20),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      GestureDetector( onTap: (){
                                        Navigator.pop(context);
                                      },child: const Icon(Icons.close, color: Color(0xFF717680), size: 24,))
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('¿Estás seguro de cerrar sesión?'),
                                ],
                              ),
                              content: const Text(' Esta acción no se puede revertir.'),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [

                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFFFFF),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),side: const BorderSide(color: Color(0xFFD5D7DA))
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Cancelar',
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color:const Color(0xFF414651)
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1F2937),
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: () async {
                                          /* ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          backgroundColor: Colors.white,
                                          content: Stack(
                                            children: [
                                              Center(
                                                child: Column(
                                                  children: [
                                                    Container(padding: const EdgeInsets.all(10),decoration: const BoxDecoration( shape: BoxShape.circle, color: Color(0xFFECFDF3)),child: Container(padding: const EdgeInsets.all(6),decoration: const BoxDecoration( shape: BoxShape.circle, color: Color(0xFFD1FADF)),child: const Icon(Icons.check_circle_outline, color: Colors.green))),
                                                    const SizedBox(width: 12),
                                                    Text('Recibimos tu Feedback', style: GoogleFonts.inter(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),),
                                                    Text('Gracias por tu opinion', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 16),),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: -8,
                                                right: -8,
                                                child: IconButton(
                                                  icon: const Icon(Icons.close),
                                                  color: const Color(0xFF9CA3AF),
                                                  iconSize: 20,
                                                  splashRadius: 18,
                                                  onPressed: () {
                                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                  },
                                                ),
                                              ),
                                            ]
                                          ),
                                          duration: const Duration(seconds: 10),
                                        ),
                                      );*/
                                          /* ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          backgroundColor: Colors.white,
                                          content: Row(
                                            children: [
                                              Container(padding: const EdgeInsets.all(6),decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: const Color(0xFFC4F4D0)),child: const Icon(Icons.check_box, color: Colors.green)),
                                              const SizedBox(width: 12),
                                              Text('Contraseña Actualizada', style: GoogleFonts.inter(color: Colors.black87, fontSize: 16),),
                                            ],
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );*/ /// MENSAJE DE CONTRASEÑA ACTUALIZADA

                                          try {
                                            await ref.read(authStateProvider.notifier).logout();
                                            if (context.mounted) {
                                              context.go('/login');
                                            }
                                          } catch (e, stack) {
                                            AppLogger.error('Error al cerrar sesión: $e', error: e, stackTrace: stack);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Error al cerrar sesión. Por favor, intenta de nuevo.'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Text(
                                          'Si, Salir',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),

                                  ],
                                )
                              ],
                            ),
                          );

                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.delete_outline,
                        title: 'Eliminar cuenta',
                        color: const Color(0xFFE6332F),
                        onTap:user != null ? () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              insetPadding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.05,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Color(0xFF1F2937),
                                  width: 2,
                                ),
                              ),
                              title: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFEF3F2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFEE4E2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: Color(0xFFD92D20),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      GestureDetector( onTap: (){
                                        Navigator.pop(context);
                                      },child: const Icon(Icons.close, color: Color(0xFF717680), size: 24,))
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('¿Estás seguro de eliminar tu cuenta en Redblue Fx?'),
                                ],
                              ),
                              content: const Text(' Esta acción no se puede revertir.'),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [

                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFFFFF),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),side: const BorderSide(color: Color(0xFFD5D7DA))
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Cancelar',
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color:const Color(0xFF414651)
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1F2937),
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: Colors.green,
                                              content: Row(
                                                children: [
                                                  Icon(Icons.check_circle, color: Colors.white),
                                                  SizedBox(width: 12),
                                                  Text('Operación realizada con éxito'),
                                                ],
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );

                                          /*Navigator.pop(context);
                                      ref.read(authStateProvider.notifier).deleteAccount();*/
                                        },
                                        child: Text(
                                          'Si, Eliminar',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),


                                  ],
                                )
                              ],
                            ),
                          );
                        } : null,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 16),
                        child: Text(
                          'Versión 2.0',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ]
              ),
            ),
          ),
        )
    );
  }

  Widget _buildSection(BuildContext context, { String? title, required List<Widget> children,}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(title != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12,left: 16),
                    child: Text(
                        title,
                        style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)
                    ),
                  ),
                ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMenuItem({required IconData icon, Color? color ,required String title, VoidCallback? onTap, Widget? trailing,bool showChevron = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 7),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(fontSize: 15,  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else if (showChevron)
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF999999),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _resetPassword() {
    return Container(
      margin: _isExpanded ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: _isExpanded
            ? Theme.of(context).colorScheme.surface
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: _isExpanded
            ? Border.all(
          color: Theme.of(context).dividerColor,
        )
            : null,// SOLO cuando está expandido
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          iconColor: const Color(0xFF999999),
          collapsedIconColor: const Color(0xFF999999),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          visualDensity: VisualDensity.compact,
          title: Row(
            children: [
              const Icon(Icons.lock_outline, size: 20),
              const SizedBox(width: 10),
              Text(
                "Cambiar Contraseña",
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: _isExpanded ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
          leading: null,


          children: [
            _passwordField("Contraseña actual"),
            const SizedBox(height: 12),

            _passwordField("Nueva Contraseña"),
            const SizedBox(height: 12),

            _passwordField("Repetir Contraseña"),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF1B21), // rojo
                      Color(0xFFDD0E13), // naranja
                      Color(0xFFBB0004), // amarillo
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xFFED7053),
                        blurRadius: 20,      // intensidad
                        offset: Offset(2, 8) // altura
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.lock_reset, color: Colors.white),
                  label: Text(
                      "Actualizar contraseña",
                      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)
                  ),
                  onPressed: () {},
                ),
              ),
            ),


            const SizedBox(height: 10),
          ],
        ),
      ),
    );

  }

  Widget _passwordField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: "**********",
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

}



/*    const SizedBox(height: 24),
           ListTile(
            title: const Text('Nombre completo'),
            subtitle: Text(user?.fullName ?? 'No disponible'),
            leading: const Icon(Icons.person_outline),
          ),
          const Divider(),
          ListTile(
            title: const Text('Email'),
            subtitle: Text(user?.email ?? 'No disponible'),
            leading: const Icon(Icons.email_outlined),
          ),
          const Divider(),
          ListTile(
            title: const Text('Rol'),
            subtitle: Text(user?.role == 'admin' ? 'Administrador' : 'Usuario'),
            leading: const Icon(Icons.admin_panel_settings_outlined),
          ),
          if (user?.role == 'admin')
            ListTile(
              title: const Text('Panel de Administración'),
              leading: const Icon(Icons.admin_panel_settings),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.pushNamed('adminUsers');
              },
            ),
          const Divider(),
          const SizedBox(height: 16),
          const ThemeSwitchTile(),
          const Divider(),
          ListTile(
            title: const Text('Cerrar Session'),
            leading: const Icon(Icons.logout),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              try {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e, stack) {
                AppLogger.error('Error al cerrar sesión: $e', error: e, stackTrace: stack);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al cerrar sesión. Por favor, intenta de nuevo.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: user != null ? () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar cuenta'),
                  content: const Text('¿Estás seguro que deseas eliminar tu cuenta? Esta acción no se puede deshacer.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(authStateProvider.notifier).deleteAccount();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar cuenta'),
          ),
          const SizedBox(height: 16),*/
