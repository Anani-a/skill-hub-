import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mock_accounts.dart';
import '../models/user_model.dart';

enum AuthState { unauthenticated, authenticated, loading }

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(AsyncValue.data(UserModel.mockCustomer));

  /// Mock login - simulates API call
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 400));
    
    final account = MockAccounts.authenticate(email, password);
    final userName = account != null ? account.nameEn : (email.contains('bekele') ? 'Bekele Tadesse' : 'Abel Abreham');
    final roleEnum = account?.role == 'provider' || email.contains('bekele')
        ? UserRole.provider 
        : (account?.role == 'admin' || email.contains('admin') ? UserRole.admin : UserRole.customer);

    state = AsyncValue.data(UserModel(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: userName,
      email: email,
      role: roleEnum,
      isVerified: true,
      createdAt: DateTime.now(),
    ));
  }

  /// Mock register - simulates API call
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final newUser = UserModel(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      isVerified: false,
      createdAt: DateTime.now(),
    );
    state = AsyncValue.data(newUser);
  }

  /// Mock logout
  void logout() {
    state = const AsyncValue.data(null);
  }

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? bio,
    String? profileImageUrl,
  }) async {
    final currentUser = state.maybeWhen(
      data: (user) => user,
      orElse: () => null,
    );

    if (currentUser != null) {
      state = const AsyncValue.loading();
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedUser = currentUser.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        bio: bio,
        profileImageUrl: profileImageUrl,
      );
      state = AsyncValue.data(updatedUser);
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return state.maybeWhen(
      data: (user) => user != null,
      orElse: () => false,
    );
  }

  /// Get the authenticated user
  UserModel? getUser() {
    return state.maybeWhen(
      data: (user) => user,
      orElse: () => null,
    );
  }
}

// Global auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier();
});

// Derived provider for authentication status
final authStatusProvider = Provider<AuthState>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    loading: () => AuthState.loading,
    data: (user) => user != null ? AuthState.authenticated : AuthState.unauthenticated,
    error: (_, __) => AuthState.unauthenticated,
  );
});

// Derived provider for current user role
final userRoleProvider = Provider<UserRole?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (user) => user?.role,
    orElse: () => null,
  );
});
