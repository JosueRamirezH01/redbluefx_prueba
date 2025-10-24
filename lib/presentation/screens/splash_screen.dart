import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/logger.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.debug('🚀 SplashScreen initialized');
    Future.microtask(() => _checkAuth());
  }

  Future<void> _checkAuth() async {
    AppLogger.debug('🔍 Starting auth check');
    
    try {
      final initialAuthState = ref.read(authStateProvider);
      
      // Si ya hay un estado autenticado de la persistencia, navegar directamente
      if (initialAuthState.isAuthenticated && initialAuthState.currentUser != null) {
        if (mounted) context.go('/home');
        return;
      }
      
      // Solo hacer checkAuthStatus si no hay estado persistido
      if (!initialAuthState.isAuthenticated) {
        await ref.read(authStateProvider.notifier).checkAuthStatus();
      }
      
      if (!mounted) return;

      final authState = ref.read(authStateProvider);
      if (authState.isAuthenticated) {
        if (mounted) context.go('/home');
      } else {
        if (mounted) context.go('/login');
      }
    } catch (e) {
      AppLogger.error('🚨 Unexpected error during auth check', error: e);
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'RedBlue FX',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
} 