import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/alert_provider.dart';
import '../providers/auth_provider.dart';
import '../../domain/entities/auth_state.dart';
import '../providers/search_provider.dart';

final isSearchingProvider = StateProvider<bool>((ref) => false);

class SharedAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
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
  ConsumerState<SharedAppBar> createState() => _SharedAppBarState();
}

class _SharedAppBarState extends ConsumerState<SharedAppBar> {
  final GlobalKey _appBarKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showSearchHistory() {
    final searchHistory = ref.read(searchHistoryProvider);
    if (searchHistory.isEmpty) return;

    final RenderBox? renderBox = _appBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height - 22,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _SearchHistoryOverlay(
            onTermSelected: (term) {
              _searchController.text = term;
              ref.read(searchQueryProvider.notifier).state = term;
              ref.read(searchHistoryProvider.notifier).addSearch(term);
              _onSearch(_searchController.text);
              _removeOverlay();
            },
            onClose: _removeOverlay,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isSearching = ref.watch(isSearchingProvider);
    final isRegister = authState.currentUser?.role == 'admin' || authState.currentUser?.role == 'publisher';
    final size = MediaQuery.of(context).size;
    return AppBar(
      key: _appBarKey,
      toolbarHeight: 90,
      automaticallyImplyLeading: false,
      title: isSearching
          ? _buildSearchBar(context, ref)
          : Row(
        children: [
          GestureDetector(
            onTap: () {
              context.go('/home');
            },
            child:  SizedBox(
              width: 80,
              height: size.height * 0.125,
              child: const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/images/Container.png',),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Bienvenido',
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w600
                  ),
                  /*style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),*/
                ),
                Text(
                  '${authState.currentUser?.fullName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (!isSearching) ...[
          if(widget.icons ?? true)...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF19283F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.search),
                color: Colors.white,
                onPressed: () {
                  ref.read(isSearchingProvider.notifier).state = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showSearchHistory();
                  });
                },
              ),
            ),
          ],
        ],
        if (!isSearching) ...[
          if (isRegister && (widget.icons ?? true)) ...[
            const SizedBox(width: 6),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF19283F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Crear alerta',
                onPressed: () => context.pushNamed('createAlert'),
              ),
            ),
          ],
          ...?widget.additionalActions,
          const SizedBox(width: 6),
          _buildProfileButton(context, authState),
          const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              // 1. Limpiamos el overlay
              _removeOverlay();
              // 2. Limpiamos el TextField
              _searchController.clear();
              // 3. Limpiamos el estado de búsqueda
              ref.read(searchQueryProvider.notifier).state = '';
              // 4. Reseteamos completamente el estado a inicial
              ref.read(alertsProvider.notifier).clearFilters();
              // 5. Salimos del modo búsqueda
              ref.read(isSearchingProvider.notifier).state = false;
              // 6. Cargamos todas las alertas
              await Future.microtask(() => ref.read(alertsProvider.notifier).loadAlerts());
            },
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 40,
          width: MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF005EA3).withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF005EA3).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.white),
              hintText: 'Filtrar señales...',
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
              fillColor: Color(0xFF0D1D35),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
            onTap: () {
              if (_overlayEntry == null) {
                _showSearchHistory();
              }
            },
            onSubmitted: (value) {
              final text = value.trim();
              if (text.length >= 3) {
                ref.read(searchHistoryProvider.notifier).addSearch(text);
              }
              ref.read(searchQueryProvider.notifier).state = text;
              _removeOverlay();
            },
            onChanged: (value) {

              ref.read(searchQueryProvider.notifier).state = value;
              if (_overlayEntry == null && value.isEmpty) {
                _showSearchHistory();
              }
              _onSearch(_searchController.text);
            },
          ),
        ),
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
              fit: BoxFit. cover,
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

  void _onSearch(String value) {
    // Cancelar el temporizador anterior si existe
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final isSearching = ref.read(isSearchingProvider);
      if (!isSearching) return;


      if (value.trim().isEmpty) {
        // Si el campo está vacío, resetear completamente el estado
        ref.read(alertsProvider.notifier).clearFilters();
        // Cargar todas las alertas
        ref.read(alertsProvider.notifier).loadAlerts();
      } else {
        // Búsqueda normal
        ref.read(alertsProvider.notifier).search(value.trim());
       // FocusScope.of(context).unfocus();
      }
    });
  }
}




class _SearchHistoryOverlay extends ConsumerWidget {
  final Function(String) onTermSelected;
  final VoidCallback onClose;

  const _SearchHistoryOverlay({
    required this.onTermSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchHistory = ref.watch(searchHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (searchHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F4479) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Búsquedas recientes',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            onClose();
                          },
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: isDark ? Colors.white38 : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...searchHistory.map((term) => InkWell(
                    onTap: () => onTermSelected(term),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 20,
                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              term,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.grey.shade800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                size: 14,
                                color: isDark ? Colors.white38 : Colors.grey.shade500),
                            onPressed: () {
                              ref.read(searchHistoryProvider.notifier).removeSearch(term);

                              // Si quieres que se cierre después de borrar el item:
                              // onClose();
                            },
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}