import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/logger.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/center_button.dart';
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlerts();
    });*/
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
    //final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 75,
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
      ),
      body: Container(
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
          }, selectedTab: BottomTab.noticias,
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: CenterFloatingButton(onPressed: () { AppLogger.info("Home");
        context.goNamed('home'); },),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }


}


