import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../domain/repositories/auth_repository.dart';
import '../utils/logger.dart';
import 'navigation_service.dart';
typedef NotificationCallback = void Function(RemoteMessage message);

class FirebaseMessagingService {
  NotificationCallback? onForegroundMessage;
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  static FirebaseMessagingService get instance => _instance;

  FirebaseMessaging? _messaging;
  String? _token;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize(AuthRepository authRepository) async {
    try {
      // Initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      
      _messaging = FirebaseMessaging.instance;
      
      // Configure local notifications
      await _configureLocalNotifications();
      
      // Request permission for all platforms
      await requestNotificationPermission();
      
      // Get the token only after _messaging is initialized
      await getToken();
      
      // Update token on server
      await _updateTokenOnServer(authRepository);
      
      // Update token on token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _token = newToken;
        AppLogger.debug('🔄 FCM token refreshed: ${_token?.substring(0, 10)}...');
        _updateTokenOnServer(authRepository);
      });
      
      // Register foreground handlers 
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      
      // Check if app was opened from a notification when it was terminated
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.debug('🔔 App opened from terminated state via notification');
        _handleNotificationTap(initialMessage);
      }
      
      AppLogger.info('✅ Firebase Messaging initialized successfully');
    } catch (e) {
      AppLogger.error('❌ Error initializing Firebase Messaging', error: e);
    }
  }

  Future<void> _configureLocalNotifications() async {
    // Initialize the plugin for Android and iOS
    const androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        AppLogger.debug('🔔 Local notification clicked: ${response.payload}');
        _handleLocalNotificationTap(response.payload);
      },
    );
  }
  
  Future<void> requestNotificationPermission() async {
    if (_messaging == null) return;

    try {
      // Request permission for iOS and Android
      final settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      AppLogger.debug('🔔 User notification permission status: ${settings.authorizationStatus}');
      
      // For Android, also create a notification channel
      if (!kIsWeb) {
        await _createAndroidNotificationChannel();
      }
    } catch (e) {
      AppLogger.error('❌ Error requesting notification permission', error: e);
    }
  }
  
  Future<void> _createAndroidNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );
    
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.debug('🔔 Got a message in foreground!');
    AppLogger.debug('🔔 Message data: ${message.data}');

    // 🔥 EMITIR EVENTO A LA APP
    onForegroundMessage?.call(message);
    
    if (message.notification != null) {
      AppLogger.debug(
        '🔔 Message also contained notification: ${message.notification!.title}',
      );
      
      // Show local notification
      _showLocalNotification(message);
    }
  }
  
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    
    if (notification != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            icon: android?.smallIcon ?? '@mipmap/launcher_icon',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode({
          'type': message.data['type'],
          'entityId': message.data['entityId'],
        }),
      );
    }
  }
  
  // Handle notification tap when app is in background or terminated
  void _handleNotificationTap(RemoteMessage message) {
    AppLogger.debug('🔔 Notification tapped: ${message.messageId}');
    AppLogger.debug('🔔 Message data: ${message.data}');

    final type = message.data['type'];
    final entityId = message.data['entityId'];

    if (type == null || entityId == null) {
      AppLogger.debug('⚠️ Notification without type or entityId');
      return;
    }
    switch (type) {
      case 'alert':
        _navigateToAlert(entityId);
        break;
      case 'advert':
        _navigateToAdvert(entityId);
        break;
     /* case 'news':
        _navigateToNews(entityId);
        break;
      */
      default:
        AppLogger.debug('⚠️ Unknown notification type: $type');
    }
  }
  
  // Handle local notification tap
  void _handleLocalNotificationTap(String? payload) {
    AppLogger.debug('🔔 Local notification tapped with payload: $payload');

    if (payload == null) return;

    final data = jsonDecode(payload);

    final type = data['type'];
    final entityId = data['entityId'];

    switch (type) {
      case 'alert':
        _navigateToAlert(entityId);
        break;

      case 'advert':
        _navigateToAdvert(entityId);
        break;

      case 'news':
      //_navigateToNews(entityId);
        break;

      default:
        AppLogger.debug('⚠️ Unknown notification type: $type');
    }
  }
  
  // Navigate to alert detail screen
  void _navigateToAlert(String alertId) {
    try {
      AppLogger.debug('🔔 Attempting to navigate to alert: $alertId');
      
      // Use NavigationService to get context
      final navigationService = NavigationService();
      final context = navigationService.navigatorKey.currentContext;
      
      // Check if we have a valid context
      if (context != null) {
        // Navigate to alert detail using go_router
        context.push('/alerts/$alertId');
        
        AppLogger.debug('✅ Successfully navigated to alert: $alertId');
      } else {
        AppLogger.debug('⚠️ No navigator context available, will navigate when app is ready');
        
        // Store the alert ID for delayed navigation
        _pendingNavigation = {
          'type': 'alert',
          'id': alertId
        };
      }
    } catch (e) {
      AppLogger.error('❌ Error navigating to alert', error: e);
    }
  }
  void _navigateToAdvert(String advertId) {
    try {
      AppLogger.debug('🔔 Attempting to navigate to alert: $advertId');

      // Use NavigationService to get context
      final navigationService = NavigationService();
      final context = navigationService.navigatorKey.currentContext;

      // Check if we have a valid context
      if (context != null) {
        // Navigate to alert detail using go_router
        context.push('/anuncio/$advertId');

        AppLogger.debug('✅ Successfully navigated to alert: $advertId');
      } else {
        AppLogger.debug('⚠️ No navigator context available, will navigate when app is ready');

        // Store the alert ID for delayed navigation
        _pendingNavigation = {
          'type': 'advert',
          'id': advertId
        };
      }
    } catch (e) {
      AppLogger.error('❌ Error navigating to alert', error: e);
    }
  }

  // Store pending navigation when app is not ready
  Map<String, String>? _pendingNavigation;

  // Method to handle pending navigation (to be called when app is ready)
  void handlePendingNavigation() {
    if (_pendingNavigation == null) return;

    final type = _pendingNavigation!['type'];
    final id = _pendingNavigation!['id'];

    _pendingNavigation = null;

    switch (type) {
      case 'alert':
        _navigateToAlert(id!);
        break;

      case 'advert':
        _navigateToAdvert(id!);
        break;
    }
  }
  
  Future<String?> getToken() async {
    if (_messaging == null) {
      AppLogger.error('❌ Firebase Messaging not initialized');
      return null;
    }
    
    try {
      // ✅ CORREGIDO: Siempre usar getToken() para obtener el FCM registration token
      // que funciona correctamente en todas las plataformas (iOS, Android)
      _token = await _messaging!.getToken();

      if (_token != null && _token!.isNotEmpty) {
        AppLogger.debug('📱 FCM token: ${_token!/*.substring(0, min(_token!.length, 10))*/}...');
        AppLogger.debug('📱 FCM token length: ${_token!.length}');
        AppLogger.debug('📱 Platform: ${defaultTargetPlatform.toString()}');
      } else {
        AppLogger.debug('⚠️ FCM token is null or empty');
      }
      return _token;
    } catch (e) {
      AppLogger.error('❌ Error getting FCM token', error: e);
      return null;
    }
  }
  
  Future<void> _updateTokenOnServer(AuthRepository authRepository) async {
    if (_token == null) return;
    
    try {
      await authRepository.updateDeviceToken(_token!);
      AppLogger.debug('✅ Device token updated on server');
    } catch (e) {
      AppLogger.error('❌ Error updating device token on server', error: e);
    }
  }
  
  Future<void> updateTokenOnServer(AuthRepository authRepository) async {
    await _updateTokenOnServer(authRepository);
  }
}

// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.debug('🔔 Handling a background message: ${message.messageId}');
}

// Helper function to avoid string index out of range error
int min(int a, int b) => a < b ? a : b; 