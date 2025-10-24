import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';
import '../../widgets/alert_list.dart';
import '../../widgets/app_bar.dart';
import '../../../domain/entities/alert.dart';
import '../../../core/utils/logger.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  AlertType? _selectedType;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlerts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAlerts() async {
    try {
      await ref.read(alertsProvider.notifier).loadAlerts();
    } catch (e, stack) {
      AppLogger.error('Error cargando alertas: $e', error: e, stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar las alertas. Por favor, intenta de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearch(String value) {
    ref.read(alertsProvider.notifier).search(value);
  }

  void _onFilterByType(AlertType? type) {
    AppLogger.debug('🔄 HomeScreen _onFilterByType - before: $_selectedType, after: $type');
    setState(() {
      _selectedType = type;
    });
    AppLogger.debug('🔄 HomeScreen _onFilterByType - after setState: $_selectedType');
    AppLogger.debug('🔄 HomeScreen _onFilterByType - sending to provider: $type');
    ref.read(alertsProvider.notifier).filterByType(type);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const SharedAppBar(title: 'RedBlue FX'),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadAlerts,
          child: Column(
            children: [
              // Sección de búsqueda y filtros con animación
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Campo de búsqueda mejorado
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar alertas...',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: _onSearch,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Filtros mejorados
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              label: 'Todas',
                              isSelected: _selectedType == AlertType.all,
                              onSelected: (selected) {
                                if (selected) {
                                  _onFilterByType(AlertType.all);
                                }
                              },
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Compra',
                              isSelected: _selectedType == AlertType.buy,
                              onSelected: (selected) {
                                if (selected) {
                                  _onFilterByType(AlertType.buy);
                                }
                              },
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Venta',
                              isSelected: _selectedType == AlertType.sell,
                              onSelected: (selected) {
                                if (selected) {
                                  _onFilterByType(AlertType.sell);
                                }
                              },
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Info',
                              isSelected: _selectedType == AlertType.info,
                              onSelected: (selected) {
                                if (selected) {
                                  _onFilterByType(AlertType.info);
                                }
                              },
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Lista de alertas
              const Expanded(
                child: AlertList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : color,
          ),
        ),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: color.withOpacity(0.1),
        selectedColor: color,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
} 