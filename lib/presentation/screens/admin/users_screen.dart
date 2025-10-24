import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/user.dart';
import '../../providers/user_provider.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/date_utils.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

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

  Future<void> _toggleUserStatus(User user) async {
    try {
      AppLogger.debug('🔄 Logging: Toggling user status for ${user.fullName} (${user.id}) from ${user.isActive} to ${!user.isActive}');
      await ref.read(usersProvider.notifier).updateUserStatus(user.id, !user.isActive);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.fullName} ${user.isActive ? 'deshabilitado' : 'habilitado'} correctamente'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
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
              onPressed: () => _toggleUserStatus(user),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.fullName} eliminado correctamente'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gestión de Usuarios'),
            if (userState.searchQuery != null)
              Text(
                '${userState.users.length} resultado${userState.users.length != 1 ? 's' : ''} encontrado${userState.users.length != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
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
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: _buildBody(userState),
    );
  }

  Widget _buildBody(UserState state) {
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            ),
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            columns: [
              DataColumn(
                label: const Text(
                  'Nombre',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onSort: (columnIndex, ascending) => _sort<String>((user) => user.fullName, columnIndex),
              ),
              DataColumn(
                label: const Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onSort: (columnIndex, ascending) => _sort<String>((user) => user.email, columnIndex),
              ),
              DataColumn(
                label: const Text(
                  'Estado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onSort: (columnIndex, ascending) => _sort<String>((user) => user.isActive ? 'Activo' : 'Inactivo', columnIndex),
              ),
              const DataColumn(
                label: Text(
                  'Acciones',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: const Text(
                  'Creado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onSort: (columnIndex, ascending) => _sort<String>((user) => user.createdAt ?? '', columnIndex),
              ),
            ],
          rows: state.users.map((user) {
            return DataRow(
              cells: [
                DataCell(Text(user.fullName)),
                DataCell(Text(user.email)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.isActive ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        color: user.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
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
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    user.createdAt != null 
                        ? AppDateUtils.formatIsoStringToPeruTime(user.createdAt!)
                        : 'N/A',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          }).toList(),
          ),
        ),
      ),
    );
  }
} 