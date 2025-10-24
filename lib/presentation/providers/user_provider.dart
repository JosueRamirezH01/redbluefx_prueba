import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  AppLogger.debug('🔄 Creating UserRepository instance');
  return UserRepositoryImpl();
});

final usersProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  AppLogger.debug('🔄 Creating UserNotifier instance');
  return UserNotifier(ref.watch(userRepositoryProvider));
});

class UserState {
  final List<User> users;
  final List<User> allUsers; // Lista completa sin filtrar
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final String? searchQuery;

  const UserState({
    this.users = const [],
    this.allUsers = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery,
  });

  UserState copyWith({
    List<User>? users,
    List<User>? allUsers,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
  }) {
    AppLogger.debug('🔄 UserState.copyWith called with: '
        'users: ${users?.length ?? 'unchanged'}, '
        'allUsers: ${allUsers?.length ?? 'unchanged'}, '
        'isLoading: $isLoading, '
        'error: $error, '
        'hasMore: $hasMore, '
        'currentPage: $currentPage, '
        'searchQuery: $searchQuery');
    
    return UserState(
      users: users ?? this.users,
      allUsers: allUsers ?? this.allUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(this._repository) : super(const UserState()) {
    AppLogger.debug('🔄 UserNotifier constructor called');
  }
  final UserRepository _repository;
  static const _pageSize = 20;

  Future<void> initialize() async {
    AppLogger.debug('🔄 UserNotifier initialize called');
    await loadUsers();
  }

  Future<void> loadUsers({bool refresh = false}) async {
    AppLogger.debug('🔄 UserNotifier.loadUsers called with refresh: $refresh');
    
    if (refresh) {
      AppLogger.debug('🔄 Resetting state for refresh');
      state = state.copyWith(
        currentPage: 1,
        users: [],
        allUsers: [],
        hasMore: true,
      );
    }

    if (!state.hasMore || state.isLoading) {
      AppLogger.debug('🔄 Skipping loadUsers: hasMore: ${state.hasMore}, isLoading: ${state.isLoading}');
      return;
    }

    AppLogger.debug('🔄 Setting loading state');
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.debug('🔄 Fetching users from repository');
      final users = await _repository.getAllUsers(); // Sin searchQuery, obtenemos todos
      AppLogger.debug('🔄 Received ${users.length} users from repository');
      
      if (users.isNotEmpty) {
        AppLogger.debug('🔄 First user data: ${users.first.toJson()}');
      }

      final updatedAllUsers = refresh || state.currentPage == 1
          ? users
          : [...state.allUsers, ...users];

      // Aplicar filtro si hay búsqueda activa
      final filteredUsers = state.searchQuery != null && state.searchQuery!.isNotEmpty
          ? _filterUsers(updatedAllUsers, state.searchQuery!)
          : updatedAllUsers;

      state = state.copyWith(
        users: filteredUsers,
        allUsers: updatedAllUsers,
        isLoading: false,
        hasMore: users.length >= _pageSize,
        currentPage: state.currentPage + 1,
      );
      AppLogger.debug('🔄 State updated successfully with ${updatedAllUsers.length} total users, ${filteredUsers.length} filtered');
    } catch (e, stack) {
      AppLogger.error('🔄 Error in loadUsers', error: e, stackTrace: stack);
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> refreshUsers() async {
    AppLogger.debug('🔄 refreshUsers called');
    await loadUsers(refresh: true);
  }

  List<User> _filterUsers(List<User> users, String query) {
    final lowerQuery = query.toLowerCase().trim();
    return users.where((user) {
      return user.fullName.toLowerCase().contains(lowerQuery) ||
             user.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void search(String query) {
    AppLogger.debug('🔄 search called with query: "$query"');
    
    final normalizedQuery = query.trim();
    
    if (normalizedQuery == state.searchQuery) {
      AppLogger.debug('🔄 Search query unchanged, skipping');
      return;
    }
    
    // Aplicar filtro localmente
    final filteredUsers = normalizedQuery.isEmpty
        ? state.allUsers
        : _filterUsers(state.allUsers, normalizedQuery);

    state = state.copyWith(
      searchQuery: normalizedQuery.isEmpty ? null : normalizedQuery,
      users: filteredUsers,
    );
    
    AppLogger.debug('🔄 Search completed: ${filteredUsers.length} users found');
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _repository.updateUserStatus(userId, isActive);
      
      // Actualizar en allUsers
      final updatedAllUsers = state.allUsers.map((user) {
        if (user.id == userId) {
          return user.copyWith(isActive: isActive);
        }
        return user;
      }).toList();
      
      // Aplicar filtro actual si existe
      final filteredUsers = state.searchQuery != null && state.searchQuery!.isNotEmpty
          ? _filterUsers(updatedAllUsers, state.searchQuery!)
          : updatedAllUsers;
      
      state = state.copyWith(
        users: filteredUsers,
        allUsers: updatedAllUsers,
      );
      AppLogger.debug('🔄 User status updated successfully');
    } catch (e, stack) {
      AppLogger.error('🔄 Error updating user status', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    AppLogger.debug('🔄 Logging: Starting user deletion process for user ID: $userId');
    try {
      await _repository.deleteUser(userId);
      
      // Remover de allUsers
      final updatedAllUsers = state.allUsers.where((user) => user.id != userId).toList();
      
      // Aplicar filtro actual si existe
      final filteredUsers = state.searchQuery != null && state.searchQuery!.isNotEmpty
          ? _filterUsers(updatedAllUsers, state.searchQuery!)
          : updatedAllUsers;
      
      state = state.copyWith(
        users: filteredUsers,
        allUsers: updatedAllUsers,
      );
      AppLogger.debug('✅ Logging: User deletion completed successfully, updated state with ${updatedAllUsers.length} remaining users');
    } catch (e, stack) {
      AppLogger.error('❌ Logging: Failed to delete user', error: e, stackTrace: stack);
      rethrow;
    }
  }

  void sortUsers<T>(Comparable<T> Function(User user) getField, bool ascending) {
    AppLogger.debug('🔄 Sorting users with ascending: $ascending');
    
    final sortedUsers = List<User>.from(state.users);
    sortedUsers.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      
      int comparison = aValue.compareTo(bValue as T);
      return ascending ? comparison : -comparison;
    });
    
    state = state.copyWith(users: sortedUsers);
    AppLogger.debug('🔄 Users sorted successfully');
  }
}
