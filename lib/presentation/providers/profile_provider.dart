import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:redbluefx/domain/entities/uploadimage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/auth_repository_impl.dart'; // Importa la implementación concreta
import './auth_provider.dart'; // Importar AuthProvider para acceder a authStateProvider

// Proporciona la instancia concreta de AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(); 
});

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  // Ahora usamos el authRepositoryProvider que acabamos de definir
  return ProfileNotifier(ref.watch(authRepositoryProvider));
});

class ProfileState {
  final bool isUploading;
  final String? error;
  final String? uploadProgress; // Para mostrar mensajes como "Subiendo..."

  ProfileState({
    this.isUploading = false,
    this.error,
    this.uploadProgress,
  });

  ProfileState copyWith({
    bool? isUploading,
    String? error,
    String? uploadProgress,
  }) {
    return ProfileState(
      isUploading: isUploading ?? this.isUploading,
      error: error ?? this.error,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthRepository _repository;
  final _picker = ImagePicker();

  // Se necesita WidgetRef para acceder a otros providers como AuthNotifier
  // Hacemos el constructor privado si solo se va a llamar desde el provider
  ProfileNotifier(this._repository) : super(ProfileState());

  Future<void> pickAndUploadImage(ImageSource source, WidgetRef ref) async {
    try {
      state = state.copyWith(isUploading: true, error: null, uploadProgress: 'Seleccionando imagen...');
      
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024, // Aumentamos el tamaño máximo para mejor calidad
        maxHeight: 1024,
        imageQuality: 90, // Calidad inicial alta para procesamiento posterior
      );

      if (image == null) {
        state = state.copyWith(isUploading: false, uploadProgress: null);
        AppLogger.debug('Selección de imagen cancelada por el usuario.');
        return;
      }

      state = state.copyWith(uploadProgress: 'Optimizando imagen...');
      
      // Leer y procesar la imagen
      final File imageFile = File(image.path);
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) {
        throw Exception('No se pudo procesar la imagen');
      }

      // Calcular dimensiones óptimas manteniendo el aspect ratio
      final maxDimension = 800.0;
      double width = originalImage.width.toDouble();
      double height = originalImage.height.toDouble();
      
      if (width > maxDimension || height > maxDimension) {
        if (width > height) {
          height = (height * maxDimension / width).round().toDouble();
          width = maxDimension;
        } else {
          width = (width * maxDimension / height).round().toDouble();
          height = maxDimension;
        }
      }

      // Redimensionar la imagen
      final resizedImage = img.copyResize(
        originalImage,
        width: width.toInt(),
        height: height.toInt(),
        interpolation: img.Interpolation.linear,
      );

      // Convertir a JPG con compresión optimizada
      final optimizedBytes = img.encodeJpg(
        resizedImage,
        quality: 85, // Buen balance entre calidad y tamaño
      );

      // Guardar la imagen optimizada
      final optimizedPath = '${image.path}_optimized.jpg';
      await File(optimizedPath).writeAsBytes(optimizedBytes);

      state = state.copyWith(uploadProgress: 'Subiendo imagen...');
      
      // Subir la imagen optimizada (el backend actualiza automáticamente la profilePictureUrl)
      final imageUrl = await _repository.uploadProfilePicture(optimizedPath);
      
      // Actualizar el estado local del usuario inmediatamente con la nueva URL
      final currentUser = ref.read(authStateProvider).currentUser;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(profilePictureUrl: imageUrl);
        ref.read(authStateProvider.notifier).updateCurrentUser(updatedUser);
      }
      
      state = state.copyWith(
        isUploading: false,
        uploadProgress: null,
      );

      // Limpiar archivos temporales
      try {
        await File(optimizedPath).delete();
        await imageFile.delete();
      } catch (e) {
        AppLogger.error('Error al limpiar archivos temporales', error: e);
      }

    } catch (e) {
      AppLogger.error('Error al subir imagen de perfil', error: e);
      state = state.copyWith(
        isUploading: false,
        error: 'Error al subir la imagen. Por favor, intenta de nuevo.',
        uploadProgress: null,
      );
    }
  }
  Future<uploadimage?> pickAndUploadImageGlobal(String imagePath) async {
    try {
      state = state.copyWith(isUploading: true);

      final uploadimage? uploaded = await _repository.uploadProfilePictureGlobal(imagePath);

      state = state.copyWith(isUploading: false);
      return uploaded;
    } catch (e) {
      state = state.copyWith(isUploading: false);
      return null;
    }
  }

} 