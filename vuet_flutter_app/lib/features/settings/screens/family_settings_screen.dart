// lib/features/settings/screens/family_settings_screen.dart
// Family settings screen with member management, invitations, and permissions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/user/providers/user_provider.dart';

// Temporary model classes - will be moved to proper models folder later
class FamilyMember {
  final String id;
  final String name;
  final String? avatarUrl;
  final String email;
  final bool isAdmin;
  final bool isOwner;

  const FamilyMember({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.email,
    this.isAdmin = false,
    this.isOwner = false,
  });
}

class FamilyInvitation {
  final String id;
  final String email;
  final String? phoneNumber;
  final DateTime sentDate;
  final bool isPending;

  const FamilyInvitation({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.sentDate,
    this.isPending = true,
  });
}

// Temporary providers - will be moved to proper providers folder later
final familyNameProvider = StateProvider<String>((ref) => 'My Family');

final familyMembersProvider = StateProvider<List<FamilyMember>>((ref) => [
      FamilyMember(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        isOwner: true,
        isAdmin: true,
      ),
      FamilyMember(
        id: '2',
        name: 'Jane Doe',
        email: 'jane@example.com',
      ),
    ]);

final familyInvitationsProvider = StateProvider<List<FamilyInvitation>>((ref) => [
      FamilyInvitation(
        id: '1',
        email: 'guest@example.com',
        sentDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);

class FamilySettingsScreen extends ConsumerStatefulWidget {
  const FamilySettingsScreen({super.key});

  @override
  ConsumerState<FamilySettingsScreen> createState() => _FamilySettingsScreenState();
}

class _FamilySettingsScreenState extends ConsumerState<FamilySettingsScreen> {
  final _familyNameController = TextEditingController();
  bool _isEditingFamilyName = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _familyNameController.text = ref.read(familyNameProvider);
    });
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final familyName = ref.watch(familyNameProvider);
    final familyMembers = ref.watch(familyMembersProvider);
    final familyInvitations = ref.watch(familyInvitationsProvider);
    final currentUserId = ref.watch(userIdProvider) ?? '1'; // Default to first member for demo

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Family name section
                  _buildFamilyNameSection(familyName, theme),
                  SizedBox(height: 24.h),

                  // Family members section
                  Text(
                    'Family Members',
                    style: theme.textTheme.titleLarge,
                  ),
                  SizedBox(height: 12.h),
                  ...familyMembers.map((member) => _buildFamilyMemberTile(
                        member,
                        theme,
                        isCurrentUser: member.id == currentUserId,
                      )),
                  SizedBox(height: 16.h),

                  // Add family member button
                  _buildAddFamilyMemberButton(theme),
                  SizedBox(height: 32.h),

                  // Pending invitations section
                  if (familyInvitations.isNotEmpty) ...[
                    Text(
                      'Pending Invitations',
                      style: theme.textTheme.titleLarge,
                    ),
                    SizedBox(height: 12.h),
                    ...familyInvitations.map((invitation) => _buildInvitationTile(invitation, theme)),
                    SizedBox(height: 16.h),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyNameSection(String familyName, ThemeData theme) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Family Name',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            _isEditingFamilyName
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _familyNameController,
                          decoration: InputDecoration(
                            hintText: 'Enter family name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          autofocus: true,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          ref.read(familyNameProvider.notifier).state = _familyNameController.text;
                          setState(() {
                            _isEditingFamilyName = false;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _familyNameController.text = familyName;
                          setState(() {
                            _isEditingFamilyName = false;
                          });
                        },
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        familyName,
                        style: theme.textTheme.bodyLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _isEditingFamilyName = true;
                          });
                        },
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMemberTile(FamilyMember member, ThemeData theme, {required bool isCurrentUser}) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member.isOwner ? theme.colorScheme.primary : theme.colorScheme.secondary,
          backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
          child: member.avatarUrl == null
              ? Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.name,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (member.isOwner)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'OWNER',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (member.isAdmin && !member.isOwner)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'ADMIN',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(member.email),
        trailing: isCurrentUser || member.isOwner
            ? null
            : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'make_admin':
                      _toggleAdminStatus(member);
                      break;
                    case 'remove':
                      _showRemoveMemberDialog(member);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'make_admin',
                    child: Text(member.isAdmin ? 'Remove Admin' : 'Make Admin'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'remove',
                    child: Text('Remove from Family'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAddFamilyMemberButton(ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: () {
        context.push('/settings/family/invite');
      },
      icon: const Icon(Icons.person_add),
      label: const Text('Add Family Member'),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      ),
    );
  }

  Widget _buildInvitationTile(FamilyInvitation invitation, ThemeData theme) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.tertiary.withOpacity(0.7),
          child: const Icon(Icons.email, color: Colors.white),
        ),
        title: Text(
          invitation.email,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          'Sent ${_formatDate(invitation.sentDate)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showCancelInvitationDialog(invitation),
        ),
      ),
    );
  }

  void _toggleAdminStatus(FamilyMember member) {
    final updatedMembers = ref.read(familyMembersProvider).map((m) {
      if (m.id == member.id) {
        return FamilyMember(
          id: m.id,
          name: m.name,
          avatarUrl: m.avatarUrl,
          email: m.email,
          isOwner: m.isOwner,
          isAdmin: !m.isAdmin,
        );
      }
      return m;
    }).toList();

    ref.read(familyMembersProvider.notifier).state = updatedMembers;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          member.isAdmin
              ? '${member.name} is no longer an admin'
              : '${member.name} is now an admin',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showRemoveMemberDialog(FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Family Member'),
        content: Text('Are you sure you want to remove ${member.name} from your family?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeFamilyMember(member);
            },
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
  }

  void _removeFamilyMember(FamilyMember member) {
    final updatedMembers = ref.read(familyMembersProvider).where((m) => m.id != member.id).toList();
    ref.read(familyMembersProvider.notifier).state = updatedMembers;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.name} has been removed from your family'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCancelInvitationDialog(FamilyInvitation invitation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Invitation'),
        content: Text('Are you sure you want to cancel the invitation to ${invitation.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelInvitation(invitation);
            },
            child: const Text('YES'),
          ),
        ],
      ),
    );
  }

  void _cancelInvitation(FamilyInvitation invitation) {
    final updatedInvitations = ref.read(familyInvitationsProvider).where((i) => i.id != invitation.id).toList();
    ref.read(familyInvitationsProvider.notifier).state = updatedInvitations;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation to ${invitation.email} has been cancelled'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
  }
}
