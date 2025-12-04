import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:redbluefx_mobile/presentation/screens/anuncio/anuncio_details_screen.dart';
import 'package:redbluefx_mobile/presentation/screens/anuncio/anuncio_screen.dart';
import 'package:redbluefx_mobile/presentation/screens/noticia/noticia_screen.dart';
import '../../presentation/screens/admin/users_screen.dart';
import '../../presentation/screens/admin/admin_alerts_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/verify_reset_code_screen.dart';
import '../../presentation/screens/auth/reset_password_screen.dart';
import '../../presentation/screens/auth/verify_email_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/noticia/notice_detail_screen.dart';
import '../../presentation/screens/alert/create_alert_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/alert/edit_alert_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../services/navigation_service.dart';

final router = GoRouter(
  navigatorKey: NavigationService().navigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: false,
  redirect: (context, state) {
    final location = state.matchedLocation;
    final isInitialLocation = location == '/';
    final isAuthRoute = location == '/login' || 
                       location == '/register' || 
                       location == '/forgot-password' ||
                       location == '/verify-reset-code' ||
                       location == '/reset-password' ||
                       location == '/verify-email';

    if (isInitialLocation) return '/login';

    final authState = ProviderScope.containerOf(context).read(authStateProvider);
    final isAuthenticated = authState.isAuthenticated;

    if (!isAuthenticated && !isAuthRoute) return '/login';
    if (isAuthenticated && isAuthRoute) return '/home';

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/verify-reset-code',
      name: 'verifyResetCode',
      builder: (context, state) => VerifyResetCodeScreen(
        email: state.extra as String,
      ),
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return ResetPasswordScreen(
          email: data['email']!,
          code: data['code']!,
        );
      },
    ),
    GoRoute(
      path: '/verify-email',
      name: 'verify-email',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        final fullName = state.uri.queryParameters['fullName'] ?? '';
        return VerifyEmailScreen(email: email, fullName: fullName);
      },
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/alerts/create',
      name: 'createAlert',
      builder: (context, state) => const CreateAlertScreen(),
    ),
    GoRoute(
      path: '/notice/:id',
      name: 'noticeDetail',
      builder: (context, state) => NoticeDetailScreen(
        alertId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/alerts/:id/edit',
      name: 'editAlert',
      builder: (context, state) => EditAlertScreen(
        alertId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/admin/users',
      name: 'adminUsers',
      builder: (context, state) => const UsersScreen(),
    ),
    GoRoute(
      path: '/admin/alerts',
      name: 'adminAlerts',
      builder: (context, state) => const AdminAlertsScreen(),
    ),
    GoRoute(
      path: '/notice_list',
      name: 'notice_list',
      builder: (context, state) => const NoticiaScreen(),
    ),
    GoRoute(
      path: '/anuncio_list',
      name: 'anuncio_list',
      builder: (context, state) => const AnuncioScreen(),
    ),
    GoRoute(
      path: '/anuncio/:id',
      name: 'anuncioDetail',
      builder: (context, state) => AnuncioDetailScreen(
        alertId: state.pathParameters['id']!,
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Página no encontrada',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    ),
  ),
);
