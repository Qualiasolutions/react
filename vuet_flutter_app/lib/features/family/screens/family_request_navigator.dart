// lib/features/family/screens/family_request_navigator.dart
// Screen that handles family invite acceptance flow

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FamilyRequestNavigator extends ConsumerStatefulWidget {
  const FamilyRequestNavigator({Key? key}) : super(key: key);

  @override
  ConsumerState<FamilyRequestNavigator> createState() => _FamilyRequestNavigatorState();
}

class _FamilyRequestNavigatorState extends ConsumerState<FamilyRequestNavigator> {
  List<Map<String, dynamic>> _invites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInvites();
  }

  Future<void> _fetchInvites() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      // Fetch invites from Supabase
      final response = await Supabase.instance.client
          .from('family_invites')
          .select('*, families(name, created_by, profiles(full_name))')
          .eq('email', user.email)
          .eq('status', 'PENDING');

      if (response == null) {
        setState(() {
          _invites = [];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _invites = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e, st) {
      Logger.error('Error fetching family invites', e, st);
      setState(() {
        _error = 'Failed to load invites: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleInviteResponse(Map<String, dynamic> invite, bool accept) async {
    try {
      EasyLoading.show(status: accept ? 'Accepting...' : 'Declining...');

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        EasyLoading.showError('User not authenticated');
        return;
      }

      if (accept) {
        // Accept the invite
        // 1. Update invite status
        await Supabase.instance.client
            .from('family_invites')
            .update({'status': 'ACCEPTED'})
            .eq('id', invite['id']);

        // 2. Add user to family members
        await Supabase.instance.client.from('family_members').insert({
          'family_id': invite['family_id'],
          'user_id': user.id,
          'role': 'MEMBER',
        });

        EasyLoading.showSuccess('Invitation accepted!');
      } else {
        // Decline the invite
        await Supabase.instance.client
            .from('family_invites')
            .update({'status': 'DECLINED'})
            .eq('id', invite['id']);

        EasyLoading.showSuccess('Invitation declined');
      }

      // Refresh the invites list
      await _fetchInvites();

      // If no more invites, navigate to main app
      if (_invites.isEmpty) {
        context.go('/');
      }
    } catch (e, st) {
      Logger.error('Error handling invite response', e, st);
      EasyLoading.showError('Failed: ${e.toString()}');
    } finally {
      EasyLoading.dismiss();
    }
  }

  String _getInviterName(Map<String, dynamic> invite) {
    try {
      if (invite['families'] != null && 
          invite['families']['profiles'] != null) {
        return invite['families']['profiles']['full_name'] ?? 'Unknown';
      }
    } catch (e) {
      // Fallback if structure is different
    }
    return 'Someone';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A4A4A),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Family Invitations'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: _fetchInvites,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD2691E),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _invites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 60.sp,
                              color: Colors.green,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No Pending Invitations',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'You have no pending family invitations.',
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 24.h),
                            ElevatedButton(
                              onPressed: () => context.go('/'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD2691E),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Continue to App'),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'You have been invited to join the following families:',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24.h),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _invites.length,
                                itemBuilder: (context, index) {
                                  final invite = _invites[index];
                                  final familyName = invite['families']?['name'] ?? 'Family';
                                  final inviterName = _getInviterName(invite);
                                  
                                  return Card(
                                    margin: EdgeInsets.only(bottom: 16.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: const Color(0xFFD2691E),
                                                child: Icon(
                                                  Icons.family_restroom,
                                                  color: Colors.white,
                                                  size: 24.sp,
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      familyName,
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Invited by $inviterName',
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16.h),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () => _handleInviteResponse(invite, false),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                    side: const BorderSide(color: Colors.red),
                                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.r),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Decline',
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16.w),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () => _handleInviteResponse(invite, true),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF4CAF50), // Green
                                                    foregroundColor: Colors.white,
                                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.r),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Accept',
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
