import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../../domain/entities/auth_state.dart';
import '../../core/utils/logger.dart';

class SharedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;
  final bool? icons;
  const SharedAppBar({
    super.key,
    required this.title,
    this.additionalActions,
    this.icons
  });

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isAdmin = authState.currentUser?.role == 'admin';
    return AppBar(
      toolbarHeight: 75,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage('assets/images/logo.png'),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Bienvenido, ${authState.currentUser?.fullName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 9
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [

        if(icons ?? true)...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // Fondo translúcido
              borderRadius: BorderRadius.circular(10), // Bordes redondeados
              border: Border.all(
                color: Colors.white.withOpacity(0.3), // Color del borde
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Crear alerta',
              onPressed: () => context.pushNamed('createAlert'),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // Fondo translúcido
              borderRadius: BorderRadius.circular(10), // Bordes redondeados
              border: Border.all(
                color: Colors.white.withOpacity(0.3), // Color del borde
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.search),
              color: Colors.white,
              tooltip: 'Buscar',
              onPressed: () {},
            ),
          ),
        ],

        if (isAdmin && (icons ?? true)) ...[
          const SizedBox(width: 6),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // Fondo translúcido
              borderRadius: BorderRadius.circular(10), // Bordes redondeados
              border: Border.all(
                color: Colors.white.withOpacity(0.3), // Color del borde
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Crear alerta',
              onPressed: () => context.pushNamed('createAlert'),
            ),
          ),
        ],
        ...?additionalActions,
        const SizedBox(width: 6),
        _buildProfileButton(context, authState),
        /*IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: () async {
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
        ),*/
      ],
    );
  }

  Widget _buildProfileButton(BuildContext context, AuthState authState) {
    final user = authState.currentUser;
    final hasProfilePicture = user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () => context.pushNamed('profile'),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasProfilePicture
                ? CachedNetworkImage(
                    imageUrl: user.profilePictureUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user?.fullName.isNotEmpty == true
                            ? user!.fullName.split(' ').map((name) => name[0]).take(2).join().toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
} 