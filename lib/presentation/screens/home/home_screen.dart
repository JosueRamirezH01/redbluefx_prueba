import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/alert_provider.dart';
import '../../widgets/alert_list.dart';
import '../../widgets/app_bar.dart';
import '../../../domain/entities/alert.dart';
import '../../../core/utils/logger.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/center_button.dart';
import '../../widgets/custom_bottom_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  AlertType? _selectedType;
  late AnimationController _animationController;
  late PageController _carouselPageController;
  int _currentCarouselIndex = 0;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _carouselPageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlerts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _carouselPageController.dispose();
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
    //final size = MediaQuery.of(context).size;
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: const SharedAppBar(title: 'RedBlue FX'),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomLeft,
              radius: 0.8,
              colors: [
                Colors.transparent,
                const Color(0xFF0D1D35).withOpacity(0.3),
                const Color(0xFF0D1D35).withOpacity(0.3),
                const Color(0xFFFF0006).withOpacity(0.01),
              ],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _loadAlerts,
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildNewsCarousel(isSmall,context, ref),
                const SizedBox(height: 10),

                if (isSearching)
                  FadeInDown(
                    duration: const Duration(milliseconds: 300),
                    child: _buildSearchResultCounter(),
                  ),
                if (!isSearching)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:Row(
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
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: 'Compra',
                        isSelected: _selectedType == AlertType.buy,
                        onSelected: (selected) {
                          if (selected) _onFilterByType(AlertType.buy);
                        },
                        color: const Color(0xFF10B981),
                        colorRelleno: const Color(0xFFDCFCE7),
                        icon: Icons.arrow_upward
                      ),
                      const SizedBox(width: 6),
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
                ),
                // Lista de alertas
                const Expanded(
                  child: AlertList(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onNoticias:() {
          AppLogger.info("Noticias tapped");
          context.pushNamed('notice_list');
        },
        onAnuncios: () {
          AppLogger.info("Anuncios tapped");
          context.pushNamed('anuncio_list');
        },  selectedTab: BottomTab.home,
      ),
      floatingActionButton: CenterFloatingButton(
        onPressed: () {
          AppLogger.info("Home");
          context.goNamed('home');
        },
      ),
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
        : (isDark ?  const Color(0xFF0D1D35) : Colors.white);

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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


/// POR MIENTRAS, MOVER ESO EN EN UN WIDGET APARTE
  Widget _buildNewsCarousel(bool isSmall, BuildContext context, WidgetRef ref) {
    final showCarousel = ref.watch(showNewsCarouselProvider);

    if (!showCarousel) return const SizedBox(); // 👈 Si está oculto, no se muestra

    final List<Map<String, String>> newsItems = [
      {
        'title': 'Nueva funcionalidad',
        'desc': 'Descubre las últimas novedades de RedBlue FX',
        'emoji': '฿',
        'date': '29/12'
      },
      {
        'title': 'Tendencias',
        'desc': 'El mercado continúa mostrando señales positivas esta semana.',
        'emoji': '📈',
        'date': '28/12'
      },
      {
        'title': 'Análisis',
        'desc': 'Los expertos predicen una corrección en los próximos días.',
        'emoji': '💹',
        'date': '27/12'
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        double cardHeight = constraints.maxWidth < 350 ? 135 : constraints.maxWidth < 500 ? 150 : 160;

        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: cardHeight,
                  child: PageView.builder(
                    controller: _carouselPageController,
                    itemCount: newsItems.length,
                    onPageChanged: (index) => setState(() => _currentCarouselIndex = index),
                    itemBuilder: (context, index) {
                      final item = newsItems[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/fondoCard.png',
                                fit: BoxFit.fill,
                              ),

                              /// BOTÓN X PARA OCULTAR
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    ref.read(showNewsCarouselProvider.notifier).state = false;
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),

                              // Contenido principal
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: isSmall ? 60 : 70,
                                      height: isSmall ? 60 : 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const RadialGradient(
                                          colors: [
                                            Color(0xFFFFD54F),
                                            Color(0xFFFFB300),
                                          ],
                                          center: Alignment(-0.3, -0.3),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          item['emoji']!,
                                          style: TextStyle(
                                            fontSize: isSmall ? 28 : 34,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    // Texto y botón
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title']!,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: isSmall ? 15 : 17,
                                              height: 1.2,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withOpacity(0.5),
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 3,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['desc']!,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.95),
                                              fontSize: isSmall ? 14 : 14,
                                              height: 1.3,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withOpacity(0.5),
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                         // const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Flexible(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white.withOpacity(0.25),
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      side: BorderSide(
                                                        color: Colors.white.withOpacity(0.4),
                                                        width: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () {},
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        'Ver detalles',
                                                        style: TextStyle(
                                                          fontSize: isSmall ? 10 : 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 3),
                                                      const Icon(
                                                        Icons.arrow_forward,
                                                        size: 12,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                item['date']!,
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.85),
                                                  fontSize: isSmall ? 10 : 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),

                /// Indicadores
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(newsItems.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentCarouselIndex == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentCarouselIndex == index
                            ? const Color(0xFF2E7EC2)
                            : const Color(0xFFB0BEC5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }

}


