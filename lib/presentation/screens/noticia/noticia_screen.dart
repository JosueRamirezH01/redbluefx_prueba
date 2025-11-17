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
import '../../widgets/center_button.dart';
import '../../widgets/custom_bottom_bar.dart';

class NoticiaScreen extends ConsumerStatefulWidget {
  const NoticiaScreen({super.key});

  @override
  ConsumerState<NoticiaScreen> createState() => _NoticiaScreenState();
}

class _NoticiaScreenState extends ConsumerState<NoticiaScreen> with SingleTickerProviderStateMixin {
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
     // _loadAlerts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAlerts() async {
    /*try {
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
    }*/
  }



 /* void _onFilterByType(AlertType? type) {
    AppLogger.debug('🔄 HomeScreen _onFilterByType - before: $_selectedType, after: $type');
    setState(() {
      _selectedType = type;
    });
    AppLogger.debug('🔄 HomeScreen _onFilterByType - after setState: $_selectedType');
    AppLogger.debug('🔄 HomeScreen _onFilterByType - sending to provider: $type');
    ref.read(alertsProvider.notifier).filterByType(type);
  }*/

  @override
  Widget build(BuildContext context) {
    final isSearching = ref.watch(isSearchingProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              if (isSearching)
                FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  child: _buildSearchResultCounter(),
                ),

              const Expanded(
                child: AlertList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onNoticias: () => AppLogger.info("Noticias tapped"),
        onAnuncios: () => AppLogger.info("Anuncios tapped"),
      ),
      floatingActionButton: CenterFloatingButton(onPressed: () {  },),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  Widget _buildSearchResultCounter() {
    final alertsState = ref.watch(alertsProvider);
    final count = alertsState.alerts.length;

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 8),
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7FC), // Fondo suave azul
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count ',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF066BAF), // Azul del número
            ),
          ),
          Text(
            count == 1 ? 'Señal encontrada' : 'Señales encontradas',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected, required Function(bool) onSelected, required Color color,}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isSelected
        ? color
        : (isDark ?  const Color(0xFF0D1D35) : Colors.white);

    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white70 : Colors.black87);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: backgroundColor,
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


