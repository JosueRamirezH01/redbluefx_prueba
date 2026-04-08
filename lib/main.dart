import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:redbluefx/presentation/providers/alert_provider.dart';
import 'package:redbluefx/presentation/providers/notificacion_provider.dart';
import 'package:redbluefx/presentation/providers/theme_provider.dart';
import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'core/widgets/app_scaffold.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'firebase_options.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Inicializar configuración
  AppConfig.initialize(
    env: Environment.dev,
    baseUrl: 'http://192.168.1.163:3000', //http://192.168.101.23:3000
  );
  //https://redbluefx-develop.up.railway.app
  //http://192.168.101.6:3502
  //https://redbluefx-production.up.railway.app
  //baseUrl: 'https://redbluefx-production.up.railway.app',
  AppLogger.info('Iniciando aplicación con configuración: ${AppConfig.instance.toJson()}');

  // Inicializar Firebase Messaging
  final authRepository = AuthRepositoryImpl();
  await FirebaseMessagingService.instance.initialize(authRepository);

  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: RedBlueFXApp(),
    ),
  );
}

class RedBlueFXApp extends ConsumerStatefulWidget {
  const RedBlueFXApp({super.key});

  @override
  ConsumerState<RedBlueFXApp> createState() => _RedBlueFXAppState();
}

class _RedBlueFXAppState extends ConsumerState<RedBlueFXApp> with WidgetsBindingObserver {
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseMessagingService.instance.onForegroundMessage = (message) {
      final type = message.data['type'];
      final isFeatured = message.data['isFeatured'];
      ref.read(realtimeNotificationProvider.notifier).setNotification(message);
      if (type == 'advert' && isFeatured == 'true') {
        ref.read(newsCarouselProvider.notifier).addFromNotification(message);
        ref.read(showNewsCarouselProvider.notifier).show();
      }
      if(type == 'alert'){
        ref.read(alertsProvider.notifier).loadAlerts(refresh: true);
      }
    };
    _checkAndRequestNotificationPermissions();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When app is resumed, check for notification permissions again
      _checkAndRequestNotificationPermissions();
    }
  }
  
  Future<void> _checkAndRequestNotificationPermissions() async {
    try {
      // Request notification permissions when app starts or resumes
      await FirebaseMessagingService.instance.requestNotificationPermission();
      
      // Update FCM token on server when app starts or resumes
      await FirebaseMessagingService.instance.updateTokenOnServer(_authRepository);
      
      // Handle any pending navigation from notifications
      FirebaseMessagingService.instance.handlePendingNavigation();
    } catch (e) {
      AppLogger.error('❌ Error checking notification permissions', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'RedBlue FX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => AppScaffold(child: child ?? const SizedBox()),
    );
  }
}
