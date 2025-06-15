// lib/features/family/screens/family_detail_screen.dart
// Screen to display details of a selected family, manage members, and handle invites.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/data/models/family_model.dart';
import 'package:vuet_flutter/features/family/providers/family_provider.dart';
import 'package:vuet_flutter/features/user/providers/user_provider.dart'; // To get current user ID and potentially member names
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FamilyDetailScreen extends ConsumerStatefulWidget {
  final String familyId;

  const FamilyDetailScreen({
    super.key,
    required this.familyId,
  });

  @override
  ConsumerState<FamilyDetailScreen> createState() => _FamilyDetailScreenState();
}

class _FamilyDetailScreenState extends ConsumerState<FamilyDetailScreen> {
  final TextEditingController _inviteEmailController = TextEditingController();
  final TextEditingController _invitePhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch the specific family details when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(familyProvider.notifier).selectFamily(widget.familyId);
    });
  }

  @override
  void dispose() {
    _inviteEmailController.dispose();
    _invitePhoneController.dispose();
    super.dispose();
  }

  Future<void> _showInviteMemberDialog(Family family) async {
    _inviteEmailController.clear();
    _invitePhoneController.clear();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite New Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _inviteEmailController,
              decoration: const InputDecoration(
                labelText: 'Email Address (Optional)',
                hintText: 'member@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: UIConstants.paddingM.h),
            TextField(
              controller: _invitePhoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                hintText: '+1234567890',
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: UIConstants.paddingS.h),
            const Text('Provide either email or phone number.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = _inviteEmailController.text.trim();
              final phone = _invitePhoneController.text.trim();

              if (email.isEmpty && phone.isEmpty) {
                EasyLoading.showError('Please provide an email or phone number.');
                return;
              }
              Navigator.of(context).pop(); // Close dialog before showing EasyLoading

              EasyLoading.show(status: 'Sending invite...');
              final success = await ref.read(familyProvider.notifier).inviteMemberToSelectedFamily(
                    email: email.isNotEmpty ? email : null,
                    phone: phone.isNotEmpty ? phone : null,
                  );
              if (success) {
                EasyLoading.showSuccess('Invite sent successfully!');
              } else {
                final error = ref.read(familyErrorProvider);
                EasyLoading.showError('Failed to send invite: ${error ?? "Unknown error"}');
              }
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showChangeRoleDialog(Family family, FamilyMember member) async {
    FamilyMemberRole? selectedRole = member.role;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role for ${member.userId}'), // Replace with member name if available
        content: DropdownButtonFormField<FamilyMemberRole>(
          value: selectedRole,
          items: FamilyMemberRole.values.map((role) {
            // Prevent assigning HEAD role if one already exists (or handle transfer logic)
            // For simplicity, allowing HEAD for now, but real app needs more logic
            return DropdownMenuItem(
              value: role,
              child: Text(role.toDbString().capitalize()),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              selectedRole = value;
            }
          },
          decoration: const InputDecoration(labelText: 'Select Role'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (selectedRole != null && selectedRole != member.role) {
                Navigator.of(context).pop();
                EasyLoading.show(status: 'Updating role...');
                final success = await ref.read(familyProvider.notifier).updateFamilyMemberRole(member.userId, selectedRole!);
                if (success) {
                  EasyLoading.showSuccess('Role updated!');
                } else {
                  final error = ref.read(familyErrorProvider);
                  EasyLoading.showError('Failed to update role: ${error ?? "Unknown error"}');
                }
              } else {
                 Navigator.of(context).pop(); // No change
              }
            },
            child: const Text('Update Role'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRemoveMember(Family family, FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${member.userId}?'), // Replace with member name
        content: const Text('Are you sure you want to remove this member from the family?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      EasyLoading.show(status: 'Removing member...');
      final success = await ref.read(familyProvider.notifier).removeFamilyMember(member.userId);
      if (success) {
        EasyLoading.showSuccess('Member removed.');
      } else {
        final error = ref.read(familyErrorProvider);
        EasyLoading.showError('Failed to remove member: ${error ?? "Unknown error"}');
      }
    }
  }

  Future<void> _handleLeaveFamily(Family family) async {
    final currentUserId = ref.read(userIdProvider);
    if (currentUserId == null) return;

    final isHead = family.createdBy == currentUserId || 
                   ref.read(currentFamilyMembersProvider).any((m) => m.userId == currentUserId && m.role == FamilyMemberRole.head);

    if (isHead && ref.read(currentFamilyMembersProvider).length == 1) {
        EasyLoading.showInfo('As the only member and head, you must delete the family instead of leaving.');
        return;
    }
     if (isHead) {
        EasyLoading.showInfo('Family heads cannot leave. Please transfer ownership or delete the family.');
        return;
    }


    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Family?'),
        content: const Text('Are you sure you want to leave this family?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      EasyLoading.show(status: 'Leaving family...');
      final success = await ref.read(familyProvider.notifier).removeFamilyMember(currentUserId);
      if (success) {
        EasyLoading.showSuccess('You have left the family.');
        if (mounted) context.go('/families'); // Navigate back to families list
      } else {
        final error = ref.read(familyErrorProvider);
        EasyLoading.showError('Failed to leave family: ${error ?? "Unknown error"}');
      }
    }
  }
  
  Future<void> _handleDeleteFamily(Family family) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family?'),
        content: Text('Are you sure you want to delete the family "${family.name}"? This action is permanent and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Family'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      EasyLoading.show(status: 'Deleting family...');
      final success = await ref.read(familyProvider.notifier).deleteSelectedFamily();
      if (success) {
        EasyLoading.showSuccess('Family deleted.');
        if (mounted) context.go('/families'); // Navigate back to families list
      } else {
        final error = ref.read(familyErrorProvider);
        EasyLoading.showError('Failed to delete family: ${error ?? "Unknown error"}');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyProvider);
    final family = familyState.selectedFamily;
    final members = familyState.currentFamilyMembers;
    final isLoading = familyState.isLoading;
    final error = familyState.error;
    final currentUserId = ref.watch(userIdProvider);

    if (isLoading && family == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Family...'), backgroundColor: AppTheme.darkHeaderColor, foregroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor))),
      );
    }

    if (error != null && family == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error'), backgroundColor: AppTheme.darkHeaderColor, foregroundColor: Colors.white),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(UIConstants.paddingL.w),
            child: Text('Error loading family: $error', style: TextStyle(color: Colors.red, fontSize: 16.sp), textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (family == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Family Not Found'), backgroundColor: AppTheme.darkHeaderColor, foregroundColor: Colors.white),
        body: Center(child: Text('The selected family could not be found.', style: TextStyle(fontSize: 16.sp))),
      );
    }
    
    final isCurrentUserHead = members.any((m) => m.userId == currentUserId && m.role == FamilyMemberRole.head);

    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(family.name),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: Colors.white,
        actions: [
          if (isCurrentUserHead)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete Family',
              onPressed: () => _handleDeleteFamily(family),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Leave Family',
            onPressed: () => _handleLeaveFamily(family),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(familyProvider.notifier).selectFamily(widget.familyId),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(UIConstants.paddingM.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Family Name Display (Could be editable for head)
              Text(
                family.name,
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppTheme.darkTextColor),
              ),
              Text(
                'Created: ${DateFormat.yMMMd().format(family.createdAt)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: UIConstants.paddingL.h),

              // Invite Member Section (Visible to Head)
              if (isCurrentUserHead) ...[
                Text(
                  'Invite New Member',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.darkTextColor),
                ),
                SizedBox(height: UIConstants.paddingS.h),
                ElevatedButton.icon(
                  onPressed: () => _showInviteMemberDialog(family),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Send Invite'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                ),
                SizedBox(height: UIConstants.paddingL.h),
              ],

              // Members List Section
              Text(
                'Family Members (${members.length})',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.darkTextColor),
              ),
              SizedBox(height: UIConstants.paddingS.h),
              if (members.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: UIConstants.paddingL.h),
                  child: Center(child: Text('No members in this family yet.', style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]))),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isSelf = member.userId == currentUserId;
                    // TODO: Fetch member's actual name from profiles table using member.userId
                    final memberDisplayName = 'User ${member.userId.substring(0, 6)}...'; // Placeholder

                    return Card(
                      margin: EdgeInsets.only(bottom: UIConstants.paddingS.h),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(isSelf ? 0.5 : 0.2),
                          child: Text(
                            memberDisplayName.isNotEmpty ? memberDisplayName[0].toUpperCase() : '?',
                            style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(memberDisplayName + (isSelf ? ' (You)' : '')),
                        subtitle: Text(member.role.toDbString().capitalize()),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'change_role') {
                              _showChangeRoleDialog(family, member);
                            } else if (value == 'remove') {
                              _handleRemoveMember(family, member);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            if (isCurrentUserHead && !isSelf)
                              const PopupMenuItem<String>(
                                value: 'change_role',
                                child: Text('Change Role'),
                              ),
                            if (isCurrentUserHead && !isSelf)
                              const PopupMenuItem<String>(
                                value: 'remove',
                                child: Text('Remove Member', style: TextStyle(color: Colors.red)),
                              ),
                          ],
                          // Show icon only if there are actions
                          icon: (isCurrentUserHead && !isSelf) ? const Icon(Icons.more_vert) : null,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
