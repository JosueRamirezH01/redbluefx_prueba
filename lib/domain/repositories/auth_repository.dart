import 'package:redbluefx_mobile/domain/entities/uploadimage.dart';

import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password, {bool rememberMe = false});
  Future<User?> register(String email, String password, String fullName);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> verifyEmail(String email, String token);
  Future<void> resendEmailVerification(String email);
  Future<void> deleteAccount();
  Future<void> updateDeviceToken(String deviceToken);
  Future<void> resetPasswordInter(String currentPassword, String newPassword);

  // Nuevos métodos para la foto de perfil
  Future<String> uploadProfilePicture(String imagePath);
  Future<uploadimage?> uploadProfilePictureGlobal(String imageUrl);
  
  // Método para verificar token localmente sin validación del servidor
  Future<bool> hasTokenLocally();
} 