import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/user.dart';
import '../utils/logger.dart';

class AuthPersistenceService {
  static const String _authStateKey = 'auth_state_key';
  static const String _lastAuthCheckKey = 'last_auth_check';
  
  static Future<void> saveAuthState(AuthState authState) async {
    try {
      AppLogger.debug('💾 Logging: Saving auth state to persistent storage');
      final prefs = await SharedPreferences.getInstance();
      
      // Solo persistir si el usuario está autenticado
      if (authState.isAuthenticated && authState.currentUser != null) {
        final authData = {
          'isAuthenticated': authState.isAuthenticated,
          'currentUser': authState.currentUser!.toJson(),
          'lastSaved': DateTime.now().millisecondsSinceEpoch,
        };
        
        await prefs.setString(_authStateKey, jsonEncode(authData));
        await prefs.setInt(_lastAuthCheckKey, DateTime.now().millisecondsSinceEpoch);
        AppLogger.debug('✅ Logging: Auth state saved successfully');
      } else {
        // Limpiar estado si no está autenticado
        await clearAuthState();
        AppLogger.debug('🗑️ Logging: Cleared auth state from storage (user not authenticated)');
      }
    } catch (e) {
      AppLogger.error('❌ Logging: Error saving auth state', error: e);
    }
  }
  
  static Future<AuthState?> loadAuthState() async {
    try {
      AppLogger.debug('📱 Logging: Loading auth state from persistent storage');
      final prefs = await SharedPreferences.getInstance();
      final authStateString = prefs.getString(_authStateKey);
      
      if (authStateString == null) {
        AppLogger.debug('❌ Logging: No saved auth state found');
        return null;
      }
      
      final authData = jsonDecode(authStateString) as Map<String, dynamic>;
      final lastSaved = authData['lastSaved'] as int?;
      
      // Verificar si el estado guardado no es muy antiguo (más de 7 días)
      if (lastSaved != null) {
        final savedDate = DateTime.fromMillisecondsSinceEpoch(lastSaved);
        final daysSinceSaved = DateTime.now().difference(savedDate).inDays;
        
        if (daysSinceSaved > 7) {
          AppLogger.debug('⏰ Logging: Saved auth state is too old (${daysSinceSaved} days), clearing');
          await clearAuthState();
          return null;
        }
      }
      
      final user = User.fromJson(authData['currentUser'] as Map<String, dynamic>);


      final authState = AuthState(
        isAuthenticated: authData['isAuthenticated'] as bool? ?? false,
        currentUser: user,
      );
      
      AppLogger.debug('✅ Logging: Auth state loaded successfully');
      return authState;
    } catch (e) {
      AppLogger.error('❌ Logging: Error loading auth state', error: e);
      // Si hay error cargando, limpiar el estado corrupto
      await clearAuthState();
      return null;
    }
  }
  
  static Future<void> clearAuthState() async {
    try {
      AppLogger.debug('🗑️ Logging: Clearing auth state from persistent storage');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authStateKey);
      await prefs.remove(_lastAuthCheckKey);
      AppLogger.debug('✅ Logging: Auth state cleared successfully');
    } catch (e) {
      AppLogger.error('❌ Logging: Error clearing auth state', error: e);
    }
  }
  
  static Future<bool> shouldPerformFullAuthCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastAuthCheckKey);
      
      if (lastCheck == null) return true;
      
      final lastCheckDate = DateTime.fromMillisecondsSinceEpoch(lastCheck);
      final hoursSinceLastCheck = DateTime.now().difference(lastCheckDate).inHours;
      
      // Realizar verificación completa cada 6 horas
      return hoursSinceLastCheck >= 6;
    } catch (e) {
      AppLogger.error('❌ Logging: Error checking last auth check time', error: e);
      return true;
    }
  }
  
  static Future<void> updateLastAuthCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastAuthCheckKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      AppLogger.error('❌ Logging: Error updating last auth check time', error: e);
    }
  }
} 