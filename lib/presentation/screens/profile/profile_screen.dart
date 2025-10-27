import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../../core/utils/logger.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/theme_switch.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
        title: const Text('Mi Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: user.profilePictureUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: Icon(Icons.person, size: 50, color: Colors.grey[500]),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          child: Icon(Icons.person, size: 50, color: Colors.grey[500]),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: profileState.isUploading ? null : () => _showImagePickerDialog(context, ref),
                      iconSize: 20,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ),
                ),
                if (profileState.isUploading)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
              ],
            ),
          ),
          if (profileState.isUploading && profileState.uploadProgress != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    profileState.uploadProgress!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 