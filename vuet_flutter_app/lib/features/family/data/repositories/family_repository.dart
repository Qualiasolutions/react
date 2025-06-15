// lib/features/family/data/repositories/family_repository.dart
// Family repository that handles CRUD operations for families and members with Supabase

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:uuid/uuid.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/data/models/family_model.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';
import 'package:vuet_flutter/features/user/providers/user_provider.dart'; // For user email/phone

abstract class BaseFamilyRepository {
  Future<List<Family>> fetchUserFamilies();
  Future<List<FamilyMember>> fetchFamilyMembers(String familyId);
  Future<Family> createFamily(String name);
  Future<FamilyInvite> inviteMemberToFamily(String familyId, {String? email, String? phone, String? invitedUserName});
  Future<void> respondToFamilyInvite(String inviteId, bool accept);
  Future<void> removeFamilyMember(String familyId, String memberId);
  Future<void> updateFamilyMemberRole(String familyId, String memberId, FamilyMemberRole newRole);
  Future<List<FamilyInvite>> fetchPendingInvitesForUser();
  Future<Family?> fetchFamilyById(String familyId);
  Future<void> deleteFamily(String familyId);
}

class SupabaseFamilyRepository implements BaseFamilyRepository {
  final SupabaseClient _supabase;
  final String? _currentUserId;
  final String? _currentUserEmail;
  final String? _currentUserPhone;

  SupabaseFamilyRepository(this._supabase, this._currentUserId, this._currentUserEmail, this._currentUserPhone);

  @override
  Future<List<Family>> fetchUserFamilies() async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    try {
      final response = await _supabase
          .from('family_members')
          .select('family_id, families!inner(*)')
          .eq('user_id', _currentUserId!);
      
      return (response as List)
          .map((item) => Family.fromJson(item['families'] as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      Logger.error('Failed to fetch user families', e, st);
      rethrow;
    }
  }

  @override
  Future<Family?> fetchFamilyById(String familyId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    try {
      final response = await _supabase
          .from('families')
          .select()
          .eq('id', familyId)
          .maybeSingle();
      
      if (response == null) return null;
      return Family.fromJson(response);
    } catch (e, st) {
      Logger.error('Failed to fetch family by ID', e, st);
      rethrow;
    }
  }

  @override
  Future<List<FamilyMember>> fetchFamilyMembers(String familyId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    try {
      final response = await _supabase
          .from('family_members')
          .select()
          .eq('family_id', familyId);
      return (response as List).map((item) => FamilyMember.fromJson(item)).toList();
    } catch (e, st) {
      Logger.error('Failed to fetch family members for family $familyId', e, st);
      rethrow;
    }
  }

  @override
  Future<Family> createFamily(String name) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    try {
      final familyId = const Uuid().v4();
      final familyData = {
        'id': familyId,
        'name': name,
        'created_by': _currentUserId!,
      };
      final response = await _supabase.from('families').insert(familyData).select().single();
      
      // Add the creator as the HEAD of the family
      await _supabase.from('family_members').insert({
        'family_id': familyId,
        'user_id': _currentUserId!,
        'role': FamilyMemberRole.head.toDbString(),
      });
      
      return Family.fromJson(response);
    } catch (e, st) {
      Logger.error('Failed to create family', e, st);
      rethrow;
    }
  }

  @override
  Future<FamilyInvite> inviteMemberToFamily(String familyId, {String? email, String? phone, String? invitedUserName}) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    if (email == null && phone == null) throw ArgumentError('Either email or phone must be provided for invite.');
    
    try {
      final inviteData = {
        'family_id': familyId,
        'invited_by': _currentUserId!,
        'email': email,
        'phone': phone,
        'status': FamilyInviteStatus.pending.toDbString(),
        'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      };
      final response = await _supabase.from('family_invites').insert(inviteData).select().single();
      return FamilyInvite.fromJson(response);
    } catch (e, st) {
      Logger.error('Failed to invite member to family $familyId', e, st);
      rethrow;
    }
  }

  @override
  Future<void> respondToFamilyInvite(String inviteId, bool accept) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    try {
      final newStatus = accept ? FamilyInviteStatus.accepted : FamilyInviteStatus.declined;
      
      final inviteResponse = await _supabase
          .from('family_invites')
          .update({'status': newStatus.toDbString()})
          .eq('id', inviteId)
          .select()
          .single();
          
      final invite = FamilyInvite.fromJson(inviteResponse);

      if (accept) {
        // Add user to family_members table
        await _supabase.from('family_members').insert({
          'family_id': invite.familyId,
          'user_id': _currentUserId!,
          'role': FamilyMemberRole.member.toDbString(), // Default role
        });
      }
    } catch (e, st) {
      Logger.error('Failed to respond to family invite $inviteId', e, st);
      rethrow;
    }
  }

  @override
  Future<void> removeFamilyMember(String familyId, String memberIdToRemove) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    try {
      // Fetch current user's role in the family
      final currentUserMember = await _supabase
          .from('family_members')
          .select('role')
          .eq('family_id', familyId)
          .eq('user_id', _currentUserId!)
          .single();
      
      final currentUserRole = FamilyMemberRole.fromString(currentUserMember['role']);

      if (_currentUserId == memberIdToRemove) {
        // User is removing themselves
        await _supabase
            .from('family_members')
            .delete()
            .eq('family_id', familyId)
            .eq('user_id', memberIdToRemove);
      } else if (currentUserRole == FamilyMemberRole.head) {
        // Family head is removing another member
        await _supabase
            .from('family_members')
            .delete()
            .eq('family_id', familyId)
            .eq('user_id', memberIdToRemove);
      } else {
        throw Exception('User does not have permission to remove this member.');
      }
    } catch (e, st) {
      Logger.error('Failed to remove member $memberIdToRemove from family $familyId', e, st);
      rethrow;
    }
  }

  @override
  Future<void> updateFamilyMemberRole(String familyId, String memberIdToUpdate, FamilyMemberRole newRole) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    try {
      // Fetch current user's role in the family
      final currentUserMember = await _supabase
          .from('family_members')
          .select('role')
          .eq('family_id', familyId)
          .eq('user_id', _currentUserId!)
          .single();
      
      final currentUserRole = FamilyMemberRole.fromString(currentUserMember['role']);

      if (currentUserRole == FamilyMemberRole.head) {
        // Only head can update roles
        await _supabase
            .from('family_members')
            .update({'role': newRole.toDbString()})
            .eq('family_id', familyId)
            .eq('user_id', memberIdToUpdate);
      } else {
        throw Exception('User does not have permission to update roles.');
      }
    } catch (e, st) {
      Logger.error('Failed to update role for member $memberIdToUpdate in family $familyId', e, st);
      rethrow;
    }
  }

  @override
  Future<List<FamilyInvite>> fetchPendingInvitesForUser() async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    if (_currentUserEmail == null && _currentUserPhone == null) {
      Logger.warning('Current user has no email or phone to check for invites.');
      return [];
    }

    try {
      var query = _supabase
          .from('family_invites')
          .select()
          .eq('status', FamilyInviteStatus.pending.toDbString());
      
      final conditions = <String>[];
      if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
        conditions.add('email.eq.$_currentUserEmail');
      }
      if (_currentUserPhone != null && _currentUserPhone!.isNotEmpty) {
        conditions.add('phone.eq.$_currentUserPhone');
      }
      
      if (conditions.isEmpty) return []; // Should not happen if check above is done

      query = query.or(conditions.join(','));
          
      final response = await query;
      return (response as List).map((item) => FamilyInvite.fromJson(item)).toList();
    } catch (e, st) {
      Logger.error('Failed to fetch pending invites for user', e, st);
      rethrow;
    }
  }

  @override
  Future<void> deleteFamily(String familyId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    try {
      // Verify if the current user is the head of the family
      final familyMember = await _supabase
          .from('family_members')
          .select('role')
          .eq('family_id', familyId)
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      if (familyMember == null || FamilyMemberRole.fromString(familyMember['role']) != FamilyMemberRole.head) {
        throw Exception('Only the family head can delete the family.');
      }

      // Proceed with deletion (Supabase RLS should handle cascading deletes if set up)
      // Or handle manually: delete members, invites, then family
      await _supabase.from('family_members').delete().eq('family_id', familyId);
      await _supabase.from('family_invites').delete().eq('family_id', familyId);
      await _supabase.from('families').delete().eq('id', familyId);
      
    } catch (e, st) {
      Logger.error('Failed to delete family $familyId', e, st);
      rethrow;
    }
  }
}

/// Provider for the Family Repository
final familyRepositoryProvider = Provider<BaseFamilyRepository>((ref) {
  final supabase = Supabase.instance.client;
  final currentUserId = ref.watch(userIdProvider);
  final currentUserEmail = ref.watch(userEmailProvider); // Assuming userEmailProvider exists
  final currentUserPhone = ref.watch(userPhoneProvider); // Assuming userPhoneProvider exists
  return SupabaseFamilyRepository(supabase, currentUserId, currentUserEmail, currentUserPhone);
});
