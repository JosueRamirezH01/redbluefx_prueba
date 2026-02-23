import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/user.dart';
import '../../providers/user_provider.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/date_utils.dart';
import '../../widgets/custom_bottom_bar.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearchText = false;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _hasSearchText = _searchController.text.isNotEmpty;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeUsers() async {
    await ref.read(usersProvider.notifier).initialize();
  }

  Future<void> _loadUsers() async {
    await ref.read(usersProvider.notifier).loadUsers(refresh: true);
  }

  void _onSearchChanged(String query) {
    ref.read(usersProvider.notifier).search(query);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(usersProvider.notifier).search('');
  }

  void _sort<T>(Comparable<T> Function(User user) getField, int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });
    ref.read(usersProvider.notifier).sortUsers(getField, _sortAscending);
  }

  Future<void> _toggleUserStatusHabilitado(User user) async {
    try {
      AppLogger.debug('🔄 Logging: Toggling user status for ${user.fullName} (${user.id}) from ${user.isActive} to ${!user.isActive!}');
      await ref.read(usersProvider.notifier).updateUserStatus(user.id, true);
      if (mounted) {
        Fluttertoast.showToast(
            msg: '${user.fullName}  habilitado correctamente',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      AppLogger.error('Error updating user status', error: e);
      if (mounted) {
        String errorMessage = 'Error al actualizar el estado del usuario';

        // Extraer mensaje más específico del error si está disponible
        if (e.toString().contains('Exception:')) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _toggleUserStatusHabilitado(user),
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleUserStatusDeshabilitado(User user) async {
    try {
      AppLogger.debug('🔄 Logging: Toggling user status for ${user.fullName} (${user.id}) from ${user.isActive} to ${!user.isActive!}');
      await ref.read(usersProvider.notifier).updateUserStatus(user.id, false);
      if (mounted) {
        Fluttertoast.showToast(
          msg: '${user.fullName} deshabilitado correctamente',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      AppLogger.error('Error updating user status', error: e);
      if (mounted) {
        String errorMessage = 'Error al actualizar el estado del usuario';

        // Extraer mensaje más específico del error si está disponible
        if (e.toString().contains('Exception:')) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _toggleUserStatusDeshabilitado(user),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(User user) async {
    // Mostrar diálogo de confirmación
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Estás seguro que deseas eliminar a ${user.fullName}?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        AppLogger.debug('🔄 Logging: Deleting user ${user.fullName} (${user.id})');
        await ref.read(usersProvider.notifier).deleteUser(user.id);
        if (mounted) {
          Fluttertoast.showToast(
              msg: '${user.fullName} eliminado correctamente',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              fontSize: 16.0
          );

        }
      } catch (e) {
        AppLogger.error('Error deleting user', error: e);
        if (mounted) {
          String errorMessage = 'Error al eliminar el usuario';

          // Extraer mensaje más específico del error si está disponible
          if (e.toString().contains('Exception:')) {
            errorMessage = e.toString().replaceFirst('Exception: ', '');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: () => _deleteUser(user),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(usersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gestión de Usuarios', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 17)),
              /*if (userState.searchQuery != null)
                Text(
                  '${userState.users.length} resultado${userState.users.length != 1 ? 's' : ''} encontrado${userState.users.length != 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),*/
            ],
          ),
          toolbarHeight: 75,
          leadingWidth: 70,
          leading: IconButton(
            style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFF19283F)), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)), side: BorderSide(color: Color(0xFF29374C))))),
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
          elevation: 6,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadUsers,
              tooltip: 'Actualizar lista',
            ),
          ],
        ),
        body: Stack(
          children: [
            if(!isDark)
            Positioned(
              top: -80,
              right: 0,
              child: Image.asset(
                'assets/images/colores.png',
                width: 260,
                height: 380,
                fit: BoxFit.contain,

              ),
            ),
            if(!isDark)
            Positioned(
              bottom: -50,
              left: 0,
              child: Image.asset(
                'assets/images/colores_2.png',
                width: 201,
                height: 280,
                fit: BoxFit.contain,
              ),
            ),
            OrientationBuilder(
              builder: (context, orientation) {
                final isLandscape = orientation == Orientation.landscape;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF243D5A) :Colors.white,
                          borderRadius: const BorderRadius.all(Radius.circular(18)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? const Color(0xFF092949) : Colors.white,
                              hintText: 'Buscar por nombre o email...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _hasSearchText
                                  ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                              )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isLandscape)
                        Expanded(child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: _buildBody(userState,isLandscape, isDark),
                        ))
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: _buildBody(userState,isLandscape, isDark),
                        ),
                    ],
                  ),
                );
              },
            ),

          ]
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: CustomBottomBar(
            onNoticias: () {
              AppLogger.info("Noticias tapped");
              context.pushNamed('notice_list');
            },
            onAnuncios: () {
              AppLogger.info("Anuncios tapped");
              context.pushNamed('anuncio_list');
            }, selectedTab: null, onCenterTap: () { context.goNamed('home'); },
          ),
        ),
      ),
    );
  }
  Widget _buildBody(UserState state, bool isLandscape, bool isDark){

  if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.searchQuery != null ? Icons.search_off : Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery != null
                  ? 'No se encontraron usuarios con "${state.searchQuery}"'
                  : 'No hay usuarios registrados',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (state.searchQuery != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar búsqueda'),
              ),
            ],
          ],
        ),
      );
    }
    if (isLandscape) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _dataTable(state, isDark)
        ),
      ),
    );
  }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ClipRRect( borderRadius: BorderRadius.circular(16),child: _dataTable(state, isDark)),
      ),
    );
  }
  Widget _dataTable(UserState state, bool isDark){
    return DataTable(
      border: TableBorder(
        horizontalInside: BorderSide(
          color: isDark ? const Color(0xFF2E4A66) : const Color(0xFFF3F4F6),
        ),
      ),
      dataRowMinHeight: 72,
      dataRowMaxHeight: 88,
      headingRowHeight: 48,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: [
        DataColumn(
          label: Text(
            'Usuario',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'Estado',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          onSort: (columnIndex, ascending) => _sort<String>((user) => user.isActive! ? 'Activo' : 'Inactivo', columnIndex),
        ),
        DataColumn(
          label: Text(
            'Acciones',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
      rows: state.users.map((user) {
        Color bgColor;
        Color textColor;
        String label;

        switch (user.isActive) {
          case true:
            bgColor = const Color(0xFFDCFCE7);
            textColor = const Color(0xFF15803D);
            label = 'Activo';
            break;
          case false:
            bgColor = const Color(0xFFFECACA);
            textColor = const Color(0xFFFF0006);
            label = 'Inactivo';
            break;
          default:
            bgColor = const Color(0xFFFEF9C3);
            textColor = const Color(0xFFA16207);
            label = 'Pendiente';
        }
        return DataRow(
          cells: [
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // NOMBRE
                    Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : null)
                    ),

                    const SizedBox(height: 4),

                    // EMAIL
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w400,  decoration: TextDecoration.underline,color: isDark ? Colors.white : null),
                    ),

                    const SizedBox(height: 6),

                    // FECHA
                    Text(
                      user.createdAt != null
                          ? 'Creado: ${AppDateUtils.formatIsoStringToPeruTime(user.createdAt!)}'
                          : 'Creado: N/A',
                      style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w400, color: isDark ? Colors.white : null),
                    ),
                  ],
                ),
              ),
            ),

            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(tooltip: 'Habilitar' ,style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFDCFCE7)), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))))),color: const Color(0xFF16A34A),onPressed: (){_toggleUserStatusHabilitado(user);}, icon: const Icon(Icons.check)),
                  IconButton(tooltip: 'Deshabilitar' ,style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFE3E3E3)), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))))),color: const Color(0xFF000000),onPressed: (){_toggleUserStatusDeshabilitado(user);}, icon: const Icon(Icons.close))
                  /*IconButton(
                    icon: Icon(
                      user.isActive ? Icons.block : Icons.check_circle,
                      color: user.isActive ? Colors.red : Colors.green,
                    ),
                    onPressed: () => _toggleUserStatus(user),
                    tooltip: user.isActive ? 'Deshabilitar' : 'Habilitar',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => _deleteUser(user),
                    tooltip: 'Eliminar usuario',
                  ),*/
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}