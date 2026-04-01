import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../providers/adverts_provider.dart';
import '../../providers/alert_provider.dart';
import '../../providers/notificacion_provider.dart';
import '../../widgets/alert_list.dart';
import '../../widgets/app_bar.dart';
import '../../../domain/entities/alert.dart';
import '../../../core/utils/logger.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/card_carousel.dart';
import '../../widgets/center_button.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/forex_socket_ui.dart';

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

    _selectedType = AlertType.all;
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
      await ref.read(alertsProvider.notifier).loadAlerts(refresh: true);
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
    final isSearching = ref.watch(isSearchingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const double kBottomBarHeight = 65;
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: const SharedAppBar(title: 'RedBlue FX'),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: isDark ? null: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomLeft,
                  radius: 0.6,
                  colors: [
                    const Color(0xFF066BAF).withValues(alpha: 0.3),
                    const Color(0xFFE6332F).withValues(alpha: 0.3),
                    const Color(0xFFFF0006).withValues(alpha: 0.01),
                  ],
                ),
              ),
              child: OrientationBuilder(
                builder: (context, orientation) {
                  final isLandscape = orientation == Orientation.landscape;
                  return isLandscape
                      ? _buildLandscape(context,isSearching)
                      : _buildPortrait(context, isSearching);
                  },
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + kBottomBarHeight,
              right: MediaQuery.of(context).size.width * 0.04,
              child: CenterFloatingButton(
                onPressed: () {
                  AppLogger.info("Calculator tapped");
                  context.goNamed('calculator');
                }, icon: Icons.calculate_outlined, border: false,
              ),
            ),
          ]
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomBar(
          onNoticias:() {

            AppLogger.info("Noticias tapped");
            context.pushNamed('notice_list');
          },
          onAnuncios: () {
            AppLogger.info("Anuncios tapped");
            context.pushNamed('anuncio_list');
          },  selectedTab: BottomTab.home,
          onCenterTap: () => context.goNamed('home'),
        ),
      ),

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
        color: Theme.of(context).answerFilterHome,
        borderRadius: BorderRadius.circular(10),
      ),
        child: Row(
          children: [
            Text(
              '$count ',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF066BAF),
              ),
            ),
            Expanded(
              child: Text(
                count == 1 ? 'Señal encontrada' : 'Señales encontradas',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        )
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected, required Function(bool) onSelected, required Color color, required Color colorRelleno, IconData? icon,}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isSelected
        ? color
        : (isDark ?  const Color(0xFF0D1425) : const Color(0xFFEFEFEF));
    final textColor = isSelected
        ? (label == "Todas" ? Colors.white : Colors.black87)
        : (isDark ? Colors.white70 : Colors.black87);


    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FilterChip(
        showCheckmark: false,
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: textColor,
                fontSize: 14,
              ),
            ),
            if (icon != null) ...[
              Icon(icon, size: 13, color: color),
            ],
          ],
                ),
        ),

      selected: isSelected,
        onSelected: onSelected,
        backgroundColor: backgroundColor,
        selectedColor: colorRelleno,
        checkmarkColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildPortrait(BuildContext context, isSearching) {
    return RefreshIndicator(
      onRefresh: _loadAlerts,
      child: CustomScrollView(
        slivers: [
           SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: MediaQuery.of(context).size.height * 0.27,
            floating: false,
            pinned: true,
            snap: false,
             surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
             flexibleSpace: FlexibleSpaceBar(
               background: LayoutBuilder(
                 builder: (context, constraints) {
                   return const Column(
                     children: [
                       SizedBox(height: 10),
                       Expanded(
                         child: CardCarousel(isSmall: false),
                       ),
                     ],
                   );
                 },
               ),
             ),
          ),
          if (isSearching)
            SliverToBoxAdapter(
              child: FadeInDown(
                duration: const Duration(milliseconds: 300),
                child: _buildSearchResultCounter(),
              ),
            ),
          if (!ref.watch(isSearchingProvider))
            SliverToBoxAdapter(child: Center(child: _buildFilters())),
          const SliverPadding(
            padding:  EdgeInsets.all(10),
            sliver:  AlertList(),
          ),
        ],
      ),
    );
  }
  Widget _buildLandscape(BuildContext context, isSearching) {
    return RefreshIndicator(
      onRefresh: _loadAlerts,
      child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: MediaQuery.of(context).size.height * 0.7,
                floating: false,
                pinned: false,
                surfaceTintColor: Colors.transparent,
                backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: LayoutBuilder(
                  builder: (context, constraints) {
                    return const Column(
                      children: [
                        SizedBox(height: 10),
                        Expanded(
                          child: CardCarousel(isSmall: false),
                        ),
                      ],
                    );
                  },
                ),
              )
            ),
            if (isSearching)
              SliverToBoxAdapter(
                child: FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  child: _buildSearchResultCounter(),
                ),
              ),

            if (!ref.watch(isSearchingProvider))
              SliverToBoxAdapter(child: Center(child: _buildFilters())),
            const SliverPadding(
              padding: EdgeInsets.all(10),
              sliver: AlertList(),
            ),
          ],
        ),
    );
  }
  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Todas',
            isSelected: _selectedType == AlertType.all,
            onSelected: (selected) {
              if (selected) _onFilterByType(AlertType.all);
            },
            color: const Color(0xFF066BAF),
            colorRelleno: const Color(0xFF066BAF),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
              label: 'Compra',
              isSelected: _selectedType == AlertType.buy,
              onSelected: (selected) {
                if (selected) _onFilterByType(AlertType.buy);
              },
              color: Theme.of(context).chipBorder,
              colorRelleno: const Color(0xFFDCFCE7),
              icon: Icons.arrow_upward
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
              label: 'Venta',
              isSelected: _selectedType == AlertType.sell,
              onSelected: (selected) {
                if (selected) _onFilterByType(AlertType.sell);
              },
              color: const Color(0xFFDD2E44),
              colorRelleno: const Color(0xFFFFE1E0),
              icon: Icons.arrow_downward
          ),
        ],
      ),
    );
  }

}


