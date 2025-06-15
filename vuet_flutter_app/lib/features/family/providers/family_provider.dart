// lib/features/family/providers/family_provider.dart
// Riverpod provider for managing family state, including CRUD operations, invites, and member management.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/data/models/family_model.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';
import 'package:vuet_flutter/features/family/data/repositories/family_repository.dart';

/// Represents the state for family-related data.
class FamilyState {
  final List<Family> userFamilies;
  final Family? selectedFamily;
  final List<FamilyMember> currentFamilyMembers;
  final List<FamilyInvite> pendingInvites;
  final bool isLoading;
  final String? error;

  const FamilyState({
    this.userFamilies = const [],
    this.selectedFamily,
    this.currentFamilyMembers = const [],
    this.pendingInvites = const [],
    this.isLoading = false,
    this.error,
  });

  FamilyState copyWith({
    List<Family>? userFamilies,
    Family? selectedFamily,
    bool clearSelectedFamily = false, // Add this to explicitly clear
    List<FamilyMember>? currentFamilyMembers,
    List<FamilyInvite>? pendingInvites,
    bool? isLoading,
    String? error,
    bool clearError = false, // Add this to explicitly clear
  }) {
    return FamilyState(
      userFamilies: userFamilies ?? this.userFamilies,
      selectedFamily: clearSelectedFamily ? null : (selectedFamily ?? this.selectedFamily),
      currentFamilyMembers: currentFamilyMembers ?? this.currentFamilyMembers,
      pendingInvites: pendingInvites ?? this.pendingInvites,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier for managing family state.
class FamilyNotifier extends StateNotifier<FamilyState> {
  final BaseFamilyRepository _repository;
  final String? _currentUserId;

  FamilyNotifier(this._repository, this._currentUserId) : super(const FamilyState()) {
    if (_currentUserId != null) {
      fetchInitialData();
    } else {
      state = state.copyWith(isLoading: false, error: "User not authenticated for family operations.");
    }
  }

  Future<void> fetchInitialData() async {
    await fetchUserFamilies();
    await fetchPendingInvites();
  }

  /// Fetches families the current user is a member of.
  Future<void> fetchUserFamilies() async {
    if (_currentUserId == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final families = await _repository.fetchUserFamilies();
      state = state.copyWith(userFamilies: families, isLoading: false);
    } catch (e, st) {
      Logger.error('Failed to fetch user families', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Fetches members for a specific family and sets it as the selected family.
  Future<void> selectFamily(String familyId) async {
    if (_currentUserId == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final family = await _repository.fetchFamilyById(familyId);
      if (family != null) {
        final members = await _repository.fetchFamilyMembers(familyId);
        state = state.copyWith(
          selectedFamily: family,
          currentFamilyMembers: members,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'Family not found.');
      }
    } catch (e, st) {
      Logger.error('Failed to select family or fetch members for $familyId', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clears the selected family and its members.
  void clearSelectedFamily() {
    state = state.copyWith(clearSelectedFamily: true, currentFamilyMembers: []);
  }

  /// Creates a new family.
  Future<bool> createFamily(String name) async {
    if (_currentUserId == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final newFamily = await _repository.createFamily(name);
      state = state.copyWith(
        userFamilies: [...state.userFamilies, newFamily],
        isLoading: false,
      );
      await selectFamily(newFamily.id); // Select the newly created family
      return true;
    } catch (e, st) {
      Logger.error('Failed to create family', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Invites a member to the currently selected family.
  Future<bool> inviteMemberToSelectedFamily({String? email, String? phone, String? invitedUserName}) async {
    if (_currentUserId == null || state.selectedFamily == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.inviteMemberToFamily(
        state.selectedFamily!.id,
        email: email,
        phone: phone,
        invitedUserName: invitedUserName,
      );
      // Optionally, refresh pending invites or family members if needed,
      // or rely on real-time updates if implemented.
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, st) {
      Logger.error('Failed to invite member to family ${state.selectedFamily!.id}', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Fetches pending family invitations for the current user.
  Future<void> fetchPendingInvites() async {
    if (_currentUserId == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final invites = await _repository.fetchPendingInvitesForUser();
      state = state.copyWith(pendingInvites: invites, isLoading: false);
    } catch (e, st) {
      Logger.error('Failed to fetch pending invites', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Responds to a family invitation.
  Future<bool> respondToFamilyInvite(String inviteId, bool accept) async {
    if (_currentUserId == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.respondToFamilyInvite(inviteId, accept);
      // Refresh pending invites and user families
      await fetchPendingInvites();
      if (accept) {
        await fetchUserFamilies();
      }
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, st) {
      Logger.error('Failed to respond to family invite $inviteId', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Removes a member from the currently selected family.
  Future<bool> removeFamilyMember(String memberIdToRemove) async {
    if (_currentUserId == null || state.selectedFamily == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.removeFamilyMember(state.selectedFamily!.id, memberIdToRemove);
      // Refresh members for the selected family
      await selectFamily(state.selectedFamily!.id);
      // If the current user removed themselves, also refresh user's families list
      if (_currentUserId == memberIdToRemove) {
        await fetchUserFamilies();
        clearSelectedFamily();
      }
      state = state.copyWith(isLoading: false); // isLoading was already set by selectFamily if successful
      return true;
    } catch (e, st) {
      Logger.error('Failed to remove member $memberIdToRemove from family ${state.selectedFamily!.id}', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Updates a member's role in the currently selected family.
  Future<bool> updateFamilyMemberRole(String memberIdToUpdate, FamilyMemberRole newRole) async {
    if (_currentUserId == null || state.selectedFamily == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateFamilyMemberRole(state.selectedFamily!.id, memberIdToUpdate, newRole);
      // Refresh members for the selected family
      await selectFamily(state.selectedFamily!.id);
      state = state.copyWith(isLoading: false); // isLoading was already set by selectFamily if successful
      return true;
    } catch (e, st) {
      Logger.error('Failed to update role for member $memberIdToUpdate in family ${state.selectedFamily!.id}', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  /// Deletes the currently selected family.
  Future<bool> deleteSelectedFamily() async {
    if (_currentUserId == null || state.selectedFamily == null) return false;
    final familyIdToDelete = state.selectedFamily!.id;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.deleteFamily(familyIdToDelete);
      // Refresh user families and clear selection
      await fetchUserFamilies();
      clearSelectedFamily();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, st) {
      Logger.error('Failed to delete family $familyIdToDelete', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

/// Main provider for family state and operations.
final familyProvider = StateNotifierProvider<FamilyNotifier, FamilyState>((ref) {
  final repository = ref.watch(familyRepositoryProvider);
  final currentUserId = ref.watch(userIdProvider);
  return FamilyNotifier(repository, currentUserId);
});

/// Provider for the list of families the current user belongs to.
final userFamiliesProvider = Provider<List<Family>>((ref) {
  return ref.watch(familyProvider).userFamilies;
});

/// Provider for the currently selected family details.
final selectedFamilyProvider = Provider<Family?>((ref) {
  return ref.watch(familyProvider).selectedFamily;
});

/// Provider for the members of the currently selected family.
final currentFamilyMembersProvider = Provider<List<FamilyMember>>((ref) {
  return ref.watch(familyProvider).currentFamilyMembers;
});

/// Provider for pending family invitations for the current user.
final pendingFamilyInvitesProvider = Provider<List<FamilyInvite>>((ref) {
  return ref.watch(familyProvider).pendingInvites;
});

/// Provider for the loading state of family operations.
final familyLoadingProvider = Provider<bool>((ref) {
  return ref.watch(familyProvider).isLoading;
});

/// Provider for any error messages from family operations.
final familyErrorProvider = Provider<String?>((ref) {
  return ref.watch(familyProvider).error;
});

/// Provider to check if the current user has any pending family invites.
final hasPendingInvitesProvider = Provider<bool>((ref) {
  return ref.watch(pendingFamilyInvitesProvider).isNotEmpty;
});
