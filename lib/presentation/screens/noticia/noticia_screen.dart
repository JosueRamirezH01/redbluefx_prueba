import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/logger.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/notice.dart';
import '../../providers/notice_provider.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/notice_list.dart';

class NoticiaScreen extends ConsumerStatefulWidget {
  const NoticiaScreen({super.key});

  @override
  ConsumerState<NoticiaScreen> createState() => _NoticiaScreenState();
}

class _NoticiaScreenState extends ConsumerState<NoticiaScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late AnimationController _animationController;
  NoticeCategory? _selectedType;
  @override
  void initState() {
    super.initState();
    _selectedType = NoticeCategory.all;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(noticeProvider.notifier).resetToAll();
    });
  }
  static final List<Map<String, NoticeCategory>> _filterMap = [
    const {'Todas': NoticeCategory.all},
    const {'Forex Factory': NoticeCategory.forex},
    const {'Tech': NoticeCategory.tech},
    const {'Crypto': NoticeCategory.crypto},
    const {'Materias': NoticeCategory.materias},
    const {'Mercados': NoticeCategory.mercados},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotice() async {
    try {
      await ref.read(noticeProvider.notifier).loadNotices();
    } catch (e, stack) {
      AppLogger.error(
          'Error cargando notices: $e', error: e, stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Error al cargar las notices. Por favor, intenta de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  void _onFilterByType(NoticeCategory? category) {
    setState(() {
      _selectedType = category ?? NoticeCategory.all;
    });

    if (category == NoticeCategory.all || category == null) {
      // Si es "Todas", carga todas las noticias
      ref.read(noticeProvider.notifier).loadNotices(refresh: true);
    } else {
      // Si es otra categoría, filtra
      ref.read(noticeProvider.notifier).filterByType(category);
    }
  }


  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        title: Text('Noticias del mercado', style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w500),),
        elevation: 8,
        leadingWidth: 70,
        leading: IconButton(
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFF19283F)), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)), side: BorderSide(color: Color(0xFF29374C))))),
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
           padding: const EdgeInsets.only(bottom: 10),
            child: _buildFilterNoticias(),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration:isDark ? null : BoxDecoration(
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
        child: RefreshIndicator(
          onRefresh: _loadNotice,
          child: const Column(
            children: [
              Expanded(
                child: NoticeList(),
              ),
            ],
          ),
        ),
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
          }, selectedTab: BottomTab.noticias, onCenterTap: () { context.goNamed('home'); },
        ),
      ),
    );
  }

  Widget _buildFilterNoticias() {
    return SizedBox(
      height:  MediaQuery.of(context).size.height * 0.045,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterMap.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final label = _filterMap[index].keys.first;
          final category = _filterMap[index].values.first;

          final bool isSelected = _selectedType == category;

          final bool isForex = category == NoticeCategory.forex;
          final bool isForexHighlighted = isForex && _selectedType != NoticeCategory.forex;

          Color backgroundColor = Colors.transparent;
          Color borderColor = const Color(0xFF2A3A52);
          Color textColor = Colors.white70;

          if (isSelected) {
            backgroundColor = isForex ? AppColors.forexColor : AppColors.selectedColor;
            borderColor = backgroundColor;
            textColor = Colors.white;

          } else if (isForexHighlighted) {
            backgroundColor = Colors.transparent;///AppColors.forexColor;
            borderColor = AppColors.forexColor;
          }
          return GestureDetector(
            onTap: () {
              AppLogger.info('Filtro seleccionado: $label');

              final NoticeCategory? filter = category == NoticeCategory.all ? null : category;
              _onFilterByType(filter);
            },

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 14 ,
                  fontWeight: isSelected ?  FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          );
        },

      ),
    );
  }



}


