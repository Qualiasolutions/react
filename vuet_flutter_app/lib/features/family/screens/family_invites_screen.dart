// lib/features/family/screens/family_invites_screen.dart
// Screen to display and manage pending family invitations.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/data/models/family_model.dart';
import 'package:vuet_flutter/features/family/providers/family_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// Provider to fetch family details for an invite, to display the family name
final familyDetailsForInviteProvider = FutureProvider.family<Family?, String>((ref, familyId) async {
  final familyRepository = ref.watch(familyRepositoryProvider);
  try {
    return await familyRepository.fetchFamilyById(familyId);
  } catch (e, st) {
    Logger.error('Failed to fetch family details for invite (familyId: $familyId)', e, st);
    return null;
  }
});

class FamilyInvitesScreen extends ConsumerStatefulWidget {
  const FamilyInvitesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FamilyInvitesScreen> createState() => _FamilyInvitesScreenState();
}

class _FamilyInvitesScreenState extends ConsumerState<FamilyInvitesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch pending invites when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(familyProvider.notifier).fetchPendingInvites();
    });
  }

  Future<void> _handleInviteResponse(String inviteId, bool accept) async {
    final action = accept ? 'Accepting' : 'Declining';
    EasyLoading.show(status: '$action invite...');
    final success = await ref.read(familyProvider.notifier).respondToFamilyInvite(inviteId, accept);
    if (success) {
      EasyLoading.showSuccess('Invite ${accept ? 'accepted' : 'declined'} successfully!');
      // If accepted, the user might want to be navigated to the family screen or their families list updated.
      // The familyProvider should handle refreshing relevant data.
      if (accept && mounted) {
         // Potentially navigate to the newly joined family or refresh current view
         // For now, just stay on this screen, list will update.
      }
    } else {
      final error = ref.read(familyErrorProvider);
      EasyLoading.showError('Failed to $action invite: ${error ?? "Unknown error"}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyProvider);
    final pendingInvites = familyState.pendingInvites;
    final isLoading = familyState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: const Text('Family Invitations'),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/'); // Fallback if no previous route
            }
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(familyProvider.notifier).fetchPendingInvites(),
        child: Column(
          children: [
            if (isLoading && pendingInvites.isEmpty)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
              )
            else if (pendingInvites.isEmpty)
              Expanded(child: _buildEmptyState())
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(UIConstants.paddingM.w),
                  itemCount: pendingInvites.length,
                  itemBuilder: (context, index) {
                    final invite = pendingInvites[index];
                    return _buildInviteCard(invite);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCard(FamilyInvite invite) {
    final familyDetailsAsync = ref.watch(familyDetailsForInviteProvider(invite.familyId));
    // TODO: Fetch inviter's name using invite.invitedBy if desired

    return Card(
      margin: EdgeInsets.only(bottom: UIConstants.paddingM.h),
      elevation: AppTheme.lightTheme.cardTheme.elevation ?? 2,
      shape: AppTheme.lightTheme.cardTheme.shape,
      child: Padding(
        padding: EdgeInsets.all(UIConstants.paddingM.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            familyDetailsAsync.when(
              data: (family) => Text(
                'Invitation to join "${family?.name ?? 'a family'}"',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkTextColor,
                ),
              ),
              loading: () => Row(
                children: [
                  Text(
                    'Loading family name...',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTextColor,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  SizedBox(height: 18.sp, width: 18.sp, child: const CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
              error: (err, st) => Text(
                'Invitation to join a family (ID: ${invite.familyId})',
                 style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkTextColor,
                ),
              ),
            ),
            SizedBox(height: UIConstants.paddingXS.h),
            Text(
              'Invited on: ${DateFormat.yMMMd().format(invite.createdAt)}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            if (invite.expiresAt != null)
              Text(
                'Expires on: ${DateFormat.yMMMd().format(invite.expiresAt!)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.orange[700]),
              ),
            SizedBox(height: UIConstants.paddingM.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _handleInviteResponse(invite.id, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(horizontal: UIConstants.paddingM.w, vertical: UIConstants.paddingS.h),
                  ),
                  child: const Text('Decline'),
                ),
                SizedBox(width: UIConstants.paddingS.w),
                ElevatedButton(
                  onPressed: () => _handleInviteResponse(invite.id, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: UIConstants.paddingM.w, vertical: UIConstants.paddingS.h),
                  ),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UIConstants.paddingXL.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: UIConstants.paddingL.h),
            Text(
              'No Pending Invitations',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: UIConstants.paddingM.h),
            Text(
              'You have no pending family invitations at the moment.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
