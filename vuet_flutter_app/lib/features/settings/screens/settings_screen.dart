// lib/features/settings/screens/settings_screen.dart
// Main settings screen with navigation to all settings sub-screens

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/user/providers/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(userIsPremiumProvider) ?? false;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSettingsButton(
                    context,
                    'Family Settings',
                    onPressed: () => _navigateTo(context, '/settings/family'),
                  ),
                  SizedBox(height: 12.h),
                  
                  _buildSettingsButton(
                    context,
                    'Integrations',
                    onPressed: () => _navigateTo(context, '/settings/integrations'),
                  ),
                  SizedBox(height: 12.h),
                  
                  _buildSettingsButton(
                    context,
                    'Personal Assistant',
                    onPressed: isPremium
                        ? () => _navigateTo(context, '/settings/personal-assistant')
                        : null,
                    isPremiumFeature: true,
                    isPremium: isPremium,
                  ),
                  SizedBox(height: 12.h),
                  
                  _buildSettingsButton(
                    context,
                    'Routines & Time Blocks',
                    onPressed: isPremium
                        ? () => _navigateTo(context, '/settings/routines-timeblocks')
                        : null,
                    isPremiumFeature: true,
                    isPremium: isPremium,
                  ),
                  SizedBox(height: 12.h),
                  
                  _buildSettingsButton(
                    context,
                    'Day Preferences',
                    onPressed: () => _navigateTo(context, '/settings/day-preferences'),
                  ),
                  SizedBox(height: 12.h),
                  
                  _buildSettingsButton(
                    context,
                    'Flexible Task Preferences',
                    onPressed: () => _navigateTo(context, '/settings/flexible-task-preferences'),
                  ),
                  SizedBox(height: 12.h),
                  
                  _buildSettingsButton(
                    context,
                    'Task Limits',
                    onPressed: () => _navigateTo(context, '/settings/task-limits'),
                  ),
                  SizedBox(height: 12.h),
                  
                  _buildSettingsButton(
                    context,
                    'Adding Tasks',
                    onPressed: () => _navigateTo(context, '/settings/adding-tasks'),
                  ),
                  SizedBox(height: 12.h),
                  
                  _buildSettingsButton(
                    context,
                    'What My Family Sees',
                    onPressed: () => _navigateTo(context, '/settings/what-family-sees'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton(
    BuildContext context,
    String title, {
    required VoidCallback? onPressed,
    bool isPremiumFeature = false,
    bool isPremium = false,
  }) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: onPressed == null 
                    ? theme.colorScheme.onPrimaryContainer.withOpacity(0.5)
                    : null,
              ),
            ),
          ),
          if (isPremiumFeature)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isPremium 
                    ? Colors.amber.shade700
                    : Colors.grey,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'PREMIUM',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    try {
      context.push(route);
    } catch (e) {
      Logger.error('Navigation error: $e');
      
      // Show temporary dialog for unimplemented screens
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Coming Soon'),
          content: const Text(
            'This settings screen is currently being implemented.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

// Provider for settings navigation state
final settingsNavigationProvider = StateProvider<String>((ref) => '/settings');
