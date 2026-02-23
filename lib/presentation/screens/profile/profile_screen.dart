import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:redbluefx/domain/entities/auth_state.dart';
import 'package:redbluefx/presentation/widgets/feedbackDialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
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
  Key _expansionKey = UniqueKey();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newRepeatPasswordController = TextEditingController();
  bool _isPasswordVisible = true;
  bool _isNewPasswordVisible = true;
  bool _isRepeatPasswordVisible = true;

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    // Check for errors after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForErrors();
    });
  }
  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _newRepeatPasswordController.dispose();
    super.dispose();
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

  Future<void> _resetPasswordInter() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Llamar al método y esperar la respuesta
        await ref.read(authStateProvider.notifier).resetPasswordInter(
          _passwordController.text,
          _newPasswordController.text
        );

        // Obtener el estado actualizado después de la operación
        final authState = ref.read(authStateProvider);

        if (mounted) {
          // Verificar si hay error
          if (authState.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${authState.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            // Solo mostrar éxito si no hay error
            ScaffoldMessenger.of(context).showSnackBar(
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
            );
            _passwordController.clear();
            _newPasswordController.clear();
            _newRepeatPasswordController.clear();
            setState(() {
              _isExpanded = false;
              _expansionKey = UniqueKey();
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> openWhatsApp({required String phone, String message = ''}) async {
    final encodedMessage = Uri.encodeComponent(message);

    final uri = Uri.parse(
      'https://wa.me/$phone?text=$encodedMessage',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir WhatsApp';
    }
  }
  Future<void> openTerm() async {
    final uri = Uri.parse(
      'https://sfa4aemecf.ufs.sh/f/BcYoET8mgpGHXWsTqHRAgMJzIfK427SUG1T0O5oPHric9pym',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
            child: LayoutBuilder(
                builder: (context, constraints) {

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight, // Fuerza al contenido a medir al menos toda la pantalla
                      ),
                      child: IntrinsicHeight(
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
                                          borderRadius: BorderRadius.circular(20),
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
                                            borderRadius: BorderRadius.circular(20),
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
                                              color: const Color(0xFFE6332F),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 3),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.15),
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
                                            color: Colors.black.withValues(alpha: 0.4),
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
                                  style:GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.normal, color: isDarkMode ?  const Color(0xFFFFFFFF).withValues(alpha: 0.4): const Color(0xFF000000).withValues(alpha: 0.4) )
                              ),
                              const SizedBox(height: 16),
                              _buildSection(context, title: 'Cuenta', children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 9.0, top: 10),
                                  child: _resetPassword(isDarkMode, authState),
                                ),
                                if (user?.role == 'admin')
                                  _buildMenuItem(
                                    icon: Icons.person_outline,
                                    color: Theme.of(context).colorIconProfile,
                                    title: 'Gestión de usuarios',
                                    onTap: () {
                                      context.pushNamed('adminUsers');
                                    },
                                  ),
                                _buildMenuItem(icon: isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,color: Theme.of(context).colorIconProfile,title: 'Modo ${isDarkMode ? "oscuro" : "claro"}',trailing: SizedBox(
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
                                        inactiveTrackColor: Colors.transparent,
                                        activeTrackColor: const Color(0xFF005EA3),
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
                                  color:Theme.of(context).colorIconProfile,
                                  title: 'Feedback',
                                  onTap: () {
                                    showFeedbackDialog(context);
                                  },
                                ),
                                _buildMenuItem(
                                  icon: Icons.help_outline,
                                  color: Theme.of(context).colorIconProfile,
                                  title: 'Ayuda y soporte',
                                  onTap: () async{
                                    await openWhatsApp(
                                      phone: '51966755809',
                                      message: 'Hola 👋 soy usuario de RedBlue FX y necesito ayuda con:',
                                    );
                                  },
                                ),
                                _buildMenuItem(
                                  icon: Icons.description_outlined,
                                  color: Theme.of(context).colorIconProfile,
                                  title: 'Términos y privacidad',
                                  onTap: () async{
                                    await openTerm();
                                  },
                                ),
                              ],
                              ),
                              const SizedBox(height: 12),
                              _buildSection(context, children: [
                                _buildMenuItem(
                                  icon: Icons.logout,
                                  color: Theme.of(context).colorIconProfile,
                                  title: 'Cerrar sesión',
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: Theme.of(context).meesDialogProfile,
                                        insetPadding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context).size.width * 0.05,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: const BorderSide(
                                            color: Color(0xFF535862),
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
                                            const Text('¿Cerrar sesión?'),
                                          ],
                                        ),
                                        content: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Luego tendrás que volver a ingresar tus datos. ¿Estás seguro?'),
                                          Text('datos. ¿Estás seguro?'),
                                        ],
                                      ),
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
                        
                                                    /* */ /// MENSAJE DE CONTRASEÑA ACTUALIZADA
                        
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
                                Divider(color: const Color(0xFFcccccc).withValues(alpha: 0.2),thickness: 0.5, endIndent: 20, indent: 20),
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
                                        backgroundColor: Theme.of(context).meesDialogProfile,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: BorderSide(
                                            color: Theme.of(context).colorDividerCardNotice,
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
                                        content:  Text('Todos los datos de tu cuenta serán eliminados. Esta acción no se puede revertir.', style: GoogleFonts.montserrat(fontSize: 14),),
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
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(left: 16, bottom: 16, top: 20),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
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
                  );
                }
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
            elevation: 1,
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
        padding: const EdgeInsets.only(left: 24,right: 24, top: 12, bottom: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(fontSize: 15,  fontWeight: FontWeight.w400,color: Theme.of(context).colorIconProfile
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

  Widget _resetPassword(bool isDark, AuthState authState) {
    return Container(
      margin: _isExpanded ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: _isExpanded ? Theme.of(context).colorScheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          key: _expansionKey,
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          iconColor: Theme.of(context).colorIconProfile,
          collapsedIconColor: Theme.of(context).colorIconProfile,
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
                  color: Theme.of(context).colorIconProfile,
                  fontWeight: _isExpanded ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
          leading: null,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _passwordField(
                    "Contraseña actual",
                    _passwordController,
                    _requiredValidator,
                    _isPasswordVisible,
                        () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  _passwordField(
                    "Nueva Contraseña",
                    _newPasswordController,
                    _newPasswordValidator,
                    _isNewPasswordVisible,
                      (){
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                      }
                  ),
                  const SizedBox(height: 12),

                  _passwordField(
                    "Repetir Contraseña",
                    _newRepeatPasswordController,
                    _repeatPasswordValidator,
                    _isRepeatPasswordVisible,
                      (){
                      setState(() {
                        _isRepeatPasswordVisible = !_isRepeatPasswordVisible;
                      });
                      }
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF1B21),
                            Color(0xFFDD0E13),
                            Color(0xFFBB0004),
                          ],
                        ),
                        boxShadow: [
                            BoxShadow(
                                color: Theme.of(context).colorBtnProfile,
                                blurRadius: 16,      // intensidad
                                offset: const Offset(0, 6) // altura
                            ),
                        ],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _resetPasswordInter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          "Actualizar contraseña",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _passwordField(String label, TextEditingController controller, String? Function(String?)? validator, bool obscureText,  VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorChangeProfile
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: "**********",
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            filled: true,
            fillColor: Theme.of(context).colorChangeTxtFormProfile,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
         validator: validator,
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? _newPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una nueva contraseña';
    }
    if (value.length < 8) {
      return 'Debe tener al menos 8 caracteres';
    }
    return null;
  }

  String? _repeatPasswordValidator(String? value) {
    if (value != _newPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}
