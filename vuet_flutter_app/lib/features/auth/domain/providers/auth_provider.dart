import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vuet_flutter/features/auth/data/models/user_model.dart';
import 'package:vuet_flutter/features/auth/data/repositories/auth_repository.dart';

/// Re-export of the authStateProvider from the repository layer
/// This serves as a clean domain layer interface for the auth functionality
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(authRepository);
});

/// Provider for the current user
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

/// Provider to check if the user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isAuthenticated;
});

/// Provider for authentication loading state
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoading;
});

/// Provider for authentication error message
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.errorMessage;
});

/// Provider for user's family memberships
final userFamiliesProvider = Provider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.familyIds ?? [];
});

/// Provider to check if user has completed onboarding
final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.onboardingCompleted ?? false;
});
