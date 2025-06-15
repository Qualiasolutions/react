// lib/features/settings/screens/day_preferences_screen.dart
// Screen for managing blocked and preferred days of the week

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vuet_flutter/core/utils/logger.dart';

// Day of week enum matching the React Native implementation
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

// Day preference type enum
enum DayPreferenceType {
  blocked,
  preferred,
  neutral,
}

// Extension to get display names for days
extension DayOfWeekExtension on DayOfWeek {
  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }

  String get shortName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Mon';
      case DayOfWeek.tuesday:
        return 'Tue';
      case DayOfWeek.wednesday:
        return 'Wed';
      case DayOfWeek.thursday:
        return 'Thu';
      case DayOfWeek.friday:
        return 'Fri';
      case DayOfWeek.saturday:
        return 'Sat';
      case DayOfWeek.sunday:
        return 'Sun';
    }
  }
}

// Providers for day preferences
final blockedDaysProvider = StateProvider<Set<DayOfWeek>>((ref) {
  // Default blocked days (weekend)
  return {DayOfWeek.saturday, DayOfWeek.sunday};
});

final preferredDaysProvider = StateProvider<Set<DayOfWeek>>((ref) {
  // Default preferred days (weekdays)
  return {
    DayOfWeek.monday,
    DayOfWeek.tuesday,
    DayOfWeek.wednesday,
    DayOfWeek.thursday,
    DayOfWeek.friday,
  };
});

class DayPreferencesScreen extends ConsumerStatefulWidget {
  const DayPreferencesScreen({super.key});

  @override
  ConsumerState<DayPreferencesScreen> createState() => _DayPreferencesScreenState();
}

class _DayPreferencesScreenState extends ConsumerState<DayPreferencesScreen> {
  // Local state for tracking changes
  late Set<DayOfWeek> _blockedDays;
  late Set<DayOfWeek> _preferredDays;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize local state from providers
    _blockedDays = Set.from(ref.read(blockedDaysProvider));
    _preferredDays = Set.from(ref.read(preferredDaysProvider));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Day Preferences'),
        centerTitle: true,
        actions: [
          // Save button
          if (_hasChanges)
            IconButton(
              icon: _isSaving
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _savePreferences,
              tooltip: 'Save preferences',
            ),
        ],
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
                  // Explanation text
                  Text(
                    'Set your day preferences for task scheduling',
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Blocked days will not be scheduled with tasks. Preferred days will be prioritized for task scheduling.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 24.h),

                  // Legend
                  _buildLegend(theme),
                  SizedBox(height: 24.h),

                  // Day selection grid
                  _buildDaySelectionGrid(theme),
                  SizedBox(height: 32.h),

                  // Reset button
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _resetToDefaults,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset to Defaults'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          theme,
          'Blocked',
          Colors.red.shade100,
          Colors.red.shade700,
          Icons.block,
        ),
        _buildLegendItem(
          theme,
          'Preferred',
          Colors.green.shade100,
          Colors.green.shade700,
          Icons.check_circle,
        ),
        _buildLegendItem(
          theme,
          'Neutral',
          Colors.grey.shade100,
          Colors.grey.shade700,
          Icons.radio_button_unchecked,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    ThemeData theme,
    String label,
    Color backgroundColor,
    Color iconColor,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Icon(icon, color: iconColor, size: 16.r),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDaySelectionGrid(ThemeData theme) {
    return Column(
      children: DayOfWeek.values.map((day) {
        final isBlocked = _blockedDays.contains(day);
        final isPreferred = _preferredDays.contains(day);
        final preferenceType = isBlocked
            ? DayPreferenceType.blocked
            : isPreferred
                ? DayPreferenceType.preferred
                : DayPreferenceType.neutral;

        return _buildDayRow(theme, day, preferenceType);
      }).toList(),
    );
  }

  Widget _buildDayRow(
    ThemeData theme,
    DayOfWeek day,
    DayPreferenceType preferenceType,
  ) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (preferenceType) {
      case DayPreferenceType.blocked:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        icon = Icons.block;
        break;
      case DayPreferenceType.preferred:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
        break;
      case DayPreferenceType.neutral:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade900;
        icon = Icons.radio_button_unchecked;
        break;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 1,
      child: InkWell(
        onTap: () => _toggleDayPreference(day),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          child: Row(
            children: [
              // Day name
              Expanded(
                child: Text(
                  day.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: textColor,
                  ),
                ),
              ),

              // Preference icon
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  icon,
                  color: textColor,
                  size: 20.r,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDayPreference(DayOfWeek day) {
    setState(() {
      if (_blockedDays.contains(day)) {
        // If currently blocked, remove from blocked and make neutral
        _blockedDays.remove(day);
        _preferredDays.remove(day); // Ensure not in preferred either
      } else if (_preferredDays.contains(day)) {
        // If currently preferred, remove from preferred and make blocked
        _preferredDays.remove(day);
        _blockedDays.add(day);
      } else {
        // If currently neutral, make preferred
        _preferredDays.add(day);
        _blockedDays.remove(day); // Ensure not in blocked
      }

      // Mark that we have unsaved changes
      _hasChanges = true;
    });
  }

  void _resetToDefaults() {
    setState(() {
      // Default blocked days (weekend)
      _blockedDays = {DayOfWeek.saturday, DayOfWeek.sunday};
      
      // Default preferred days (weekdays)
      _preferredDays = {
        DayOfWeek.monday,
        DayOfWeek.tuesday,
        DayOfWeek.wednesday,
        DayOfWeek.thursday,
        DayOfWeek.friday,
      };
      
      _hasChanges = true;
    });
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update providers with new values
      ref.read(blockedDaysProvider.notifier).state = Set.from(_blockedDays);
      ref.read(preferredDaysProvider.notifier).state = Set.from(_preferredDays);
      
      // In a real app, we would call an API to save preferences
      Logger.debug('Saving day preferences:');
      Logger.debug('Blocked days: $_blockedDays');
      Logger.debug('Preferred days: $_preferredDays');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Day preferences saved'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      Logger.error('Error saving day preferences: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save preferences'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
