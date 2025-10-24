import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/alert.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_theme.dart';

class AdminAlertsScreen extends ConsumerStatefulWidget {
  const AdminAlertsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminAlertsScreen> createState() => _AdminAlertsScreenState();
}

class _AdminAlertsScreenState extends ConsumerState<AdminAlertsScreen> {
  final TextEditingController _searchController = TextEditingController();
  AlertType? _selectedType;
  AlertStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showArchived = false;
  bool _hasSearchText = false;
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _hasSearchText = _searchController.text.isNotEmpty;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlerts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAlerts() async {
    await ref.read(alertsProvider.notifier).loadAlerts();
  }

  void _onSearchChanged(String query) {
    ref.read(alertsProvider.notifier).search(query);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(alertsProvider.notifier).search('');
  }

  void _applyFilters() {
    // Implementar lógica de filtros
    final alertsNotifier = ref.read(alertsProvider.notifier);
    
    if (_selectedType != null) {
      alertsNotifier.filterByType(_selectedType);
    }
    
    // Los filtros adicionales se pueden implementar en el provider
    AppLogger.debug('🔍 Aplicando filtros: tipo=$_selectedType, estado=$_selectedStatus, desde=$_startDate, hasta=$_endDate');
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _applyFilters();
  }

  Future<void> _toggleAlertStatus(Alert alert) async {
    try {
      final newStatus = alert.status == AlertStatus.active 
          ? AlertStatus.archived 
          : AlertStatus.active;
      
      AppLogger.debug('🔄 Cambiando estado de alerta ${alert.id} de ${alert.status} a $newStatus');
      
      await ref.read(alertsProvider.notifier).updateAlertStatus(alert.id, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alerta ${newStatus == AlertStatus.archived ? 'archivada' : 'activada'} correctamente'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error updating alert status', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar el estado de la alerta'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _softDeleteAlert(Alert alert) async {
    // Mostrar diálogo de confirmación
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Archivar Alerta'),
        content: Text('¿Estás seguro que deseas archivar "${alert.title}"?\n\nEsta acción se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            child: const Text('Archivar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        AppLogger.debug('🗂️ Archivando alerta ${alert.id}');
        
        // Implementar soft delete (cambiar estado a archived)
        await _toggleAlertStatus(alert);
        
      } catch (e) {
        AppLogger.error('Error archiving alert', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al archivar la alerta'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(alertsProvider);
    final authState = ref.watch(authStateProvider);
    
    // Verificar que el usuario sea admin
    if (authState.currentUser?.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Acceso Denegado')),
        body: const Center(
          child: Text('No tienes permisos para acceder a esta sección'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin - Gestión de Alertas'),
            Text(
              '${alertState.alerts.length} alerta${alertState.alerts.length != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(180),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar alertas por título o contenido...',
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
                
                const SizedBox(height: 12),
                
                // Filtros
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Filtro por tipo
                      _buildFilterChip(
                        label: 'Todas',
                        isSelected: _selectedType == null,
                        onTap: () {
                          setState(() {
                            _selectedType = null;
                          });
                          _applyFilters();
                        },
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Compra',
                        isSelected: _selectedType == AlertType.buy,
                        onTap: () {
                          setState(() {
                            _selectedType = AlertType.buy;
                          });
                          _applyFilters();
                        },
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Venta',
                        isSelected: _selectedType == AlertType.sell,
                        onTap: () {
                          setState(() {
                            _selectedType = AlertType.sell;
                          });
                          _applyFilters();
                        },
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Info',
                        isSelected: _selectedType == AlertType.info,
                        onTap: () {
                          setState(() {
                            _selectedType = AlertType.info;
                          });
                          _applyFilters();
                        },
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      
                      // Filtro por estado
                      _buildFilterChip(
                        label: 'Activas',
                        isSelected: _selectedStatus == AlertStatus.active,
                        onTap: () {
                          setState(() {
                            _selectedStatus = _selectedStatus == AlertStatus.active 
                                ? null 
                                : AlertStatus.active;
                          });
                          _applyFilters();
                        },
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Archivadas',
                        isSelected: _selectedStatus == AlertStatus.archived,
                        onTap: () {
                          setState(() {
                            _selectedStatus = _selectedStatus == AlertStatus.archived 
                                ? null 
                                : AlertStatus.archived;
                          });
                          _applyFilters();
                        },
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      
                      // Filtro por fecha
                      _buildDateFilterChip(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
            tooltip: 'Actualizar lista',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.pushNamed('createAlert'),
            tooltip: 'Crear alerta',
          ),
        ],
      ),
      body: _buildBody(alertState),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilterChip() {
    final hasDateFilter = _startDate != null && _endDate != null;
    
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasDateFilter ? AppColors.secondary : AppColors.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.secondary,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range,
              size: 16,
              color: hasDateFilter ? Colors.white : AppColors.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              hasDateFilter 
                  ? '${AppDateUtils.formatDateToPeruTime(_startDate!)} - ${AppDateUtils.formatDateToPeruTime(_endDate!)}'
                  : 'Fechas',
              style: TextStyle(
                color: hasDateFilter ? Colors.white : AppColors.secondary,
                fontSize: 12,
                fontWeight: hasDateFilter ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasDateFilter) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _clearDateFilter,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AlertState state) {
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
              onPressed: _loadAlerts,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.searchQuery != null ? Icons.search_off : Icons.announcement_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery != null 
                  ? 'No se encontraron alertas con "${state.searchQuery}"'
                  : 'No hay alertas disponibles',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.alerts.length,
      itemBuilder: (context, index) {
        final alert = state.alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(Alert alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTypeChip(alert.type),
                const Spacer(),
                _buildStatusChip(alert.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              alert.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  AppDateUtils.formatToPeruTime(alert.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        alert.status == AlertStatus.active ? Icons.archive : Icons.unarchive,
                        color: alert.status == AlertStatus.active ? Colors.orange : Colors.green,
                        size: 20,
                      ),
                      onPressed: () => _toggleAlertStatus(alert),
                      tooltip: alert.status == AlertStatus.active ? 'Archivar' : 'Activar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: () => context.pushNamed('editAlert', pathParameters: {'id': alert.id}),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.grey, size: 20),
                      onPressed: () => context.pushNamed('alertDetail', pathParameters: {'id': alert.id}),
                      tooltip: 'Ver detalles',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(AlertType type) {
    Color color;
    String text;

    switch (type) {
      case AlertType.all:
        color = Colors.grey;
        text = 'TODAS';
        break;
      case AlertType.buy:
        color = Colors.green;
        text = 'COMPRA';
        break;
      case AlertType.sell:
        color = Colors.red;
        text = 'VENTA';
        break;
      case AlertType.info:
        color = Colors.blue;
        text = 'INFO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(AlertStatus status) {
    Color color;
    String text;

    switch (status) {
      case AlertStatus.active:
        color = Colors.green;
        text = 'Activa';
        break;
      case AlertStatus.archived:
        color = Colors.grey;
        text = 'Archivada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}