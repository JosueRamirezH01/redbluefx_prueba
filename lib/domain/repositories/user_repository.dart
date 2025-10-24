import '../entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getAllUsers({String? searchQuery});
  Future<User> getUserById(String id);
  Future<void> updateUserStatus(String id, bool isActive);
  Future<User> updateUser(String id, Map<String, dynamic> userData);
  Future<void> deleteUser(String id);
} 