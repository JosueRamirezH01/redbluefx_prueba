import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redbluefx_mobile/presentation/widgets/anuncio_destacado_list.dart';
import 'package:redbluefx_mobile/presentation/widgets/anuncio_reciente_list.dart';
import '../../../core/utils/logger.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/center_button.dart';
import '../../widgets/custom_bottom_bar.dart';

class AnuncioScreen extends ConsumerStatefulWidget {
  const AnuncioScreen({super.key});

  @override
  ConsumerState<AnuncioScreen> createState() => _AnuncioScreenState();
}

class _AnuncioScreenState extends ConsumerState<AnuncioScreen> with SingleTickerProviderStateMixin {
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
    //final isSearching = ref.watch(isSearchingProvider);
   // final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
         title: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text('Anuncio', style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w500),),
             Text('Ultimas novedades', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w200),),

           ],
         ),
        elevation: 8,
      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0) ,
                  child: Text('Destacados',style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 18
                  ),),
                ),
                const Expanded(
                  child: AnuncioDestacadoList(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0) ,
                  child: Text('Recientes',style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 18
                  ),),
                ),
                const Expanded(
                  child: AnuncioRecienteList(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onNoticias: () {
          AppLogger.info("Noticias tapped");
          context.pushNamed('notice_list');
        },
        onAnuncios: () => AppLogger.info("Anuncios tapped"), selectedTab: BottomTab.anuncios,
      ),
      floatingActionButton: CenterFloatingButton(onPressed: () { AppLogger.info("Home");
      context.goNamed('home'); },),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }


}


