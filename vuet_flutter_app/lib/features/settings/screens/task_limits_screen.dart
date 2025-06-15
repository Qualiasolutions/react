// lib/features/settings/screens/task_limits_screen.dart
// Screen for managing task limits including daily and weekly maximums

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vuet_flutter/core/utils/logger.dart';

// Task limit model
class TaskLimit {
  final int dailyLimit;
  final int weeklyLimit;
  final int dailyHoursLimit;
  final Map<String, int> categoryLimits;

  const TaskLimit({
    required this.dailyLimit,
    required this.weeklyLimit,
    required this.dailyHoursLimit,
    required this.categoryLimits,
  });

  TaskLimit copyWith({
    int? dailyLimit,
    int? weeklyLimit,
    int? dailyHoursLimit,
    Map<String, int>? categoryLimits,
  }) {
    return TaskLimit(
      dailyLimit: dailyLimit ?? this.dailyLimit,
      weeklyLimit: weeklyLimit ?? this.weeklyLimit,
      dailyHoursLimit: dailyHoursLimit ?? this.dailyHoursLimit,
      categoryLimits: categoryLimits ?? this.categoryLimits,
    );
  }
}

// Mock categories for demo
class Category {
  final String id;
  final String name;
  final Color color;

  const Category({
    required this.id,
    required this.name,
    required this.color,
  });
}

// Providers for task limits
final taskLimitProvider = StateProvider<TaskLimit>((ref) {
  // Default limits
  return TaskLimit(
    dailyLimit: 5,
    weeklyLimit: 25,
    dailyHoursLimit: 8,
    categoryLimits: {
      'home': 3,
      'work': 5,
      'health': 2,
      'social': 2,
      'finance': 1,
    },
  );
});

// Provider for available categories
final categoriesProvider = Provider<List<Category>>((ref) {
  return [
    Category(id: 'home', name: 'Home', color: Colors.blue),
    Category(id: 'work', name: 'Work', color: Colors.orange),
    Category(id: 'health', name: 'Health', color: Colors.green),
    Category(id: 'social', name: 'Social', color: Colors.purple),
    Category(id: 'finance', name: 'Finance', color: Colors.red),
  ];
});

class TaskLimitsScreen extends ConsumerStatefulWidget {
  const TaskLimitsScreen({super.key});

  @override
  ConsumerState<TaskLimitsScreen> createState() => _TaskLimitsScreenState();
}

class _TaskLimitsScreenState extends ConsumerState<TaskLimitsScreen> {
  // Local state for tracking changes
  late TaskLimit _taskLimit;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize local state from provider
    _taskLimit = ref.read(taskLimitProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Limits'),
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
              onPressed: _isSaving ? null : _saveTaskLimits,
              tooltip: 'Save limits',
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
                    'Set your task limits to manage your workload',
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'These limits will help prevent overloading your schedule with too many tasks.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 24.h),

                  // Daily task limit
                  _buildLimitSection(
                    theme,
                    title: 'Daily Task Limit',
                    subtitle: 'Maximum number of tasks per day',
                    value: _taskLimit.dailyLimit,
                    min: 1,
                    max: 15,
                    icon: Icons.today,
                    onChanged: (value) {
                      setState(() {
                        _taskLimit = _taskLimit.copyWith(dailyLimit: value.round());
                        _hasChanges = true;
                      });
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Weekly task limit
                  _buildLimitSection(
                    theme,
                    title: 'Weekly Task Limit',
                    subtitle: 'Maximum number of tasks per week',
                    value: _taskLimit.weeklyLimit,
                    min: 5,
                    max: 70,
                    icon: Icons.calendar_view_week,
                    onChanged: (value) {
                      setState(() {
                        _taskLimit = _taskLimit.copyWith(weeklyLimit: value.round());
                        _hasChanges = true;
                      });
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Daily hours limit
                  _buildLimitSection(
                    theme,
                    title: 'Daily Hours Limit',
                    subtitle: 'Maximum hours of tasks per day',
                    value: _taskLimit.dailyHoursLimit,
                    min: 1,
                    max: 16,
                    icon: Icons.access_time,
                    onChanged: (value) {
                      setState(() {
                        _taskLimit = _taskLimit.copyWith(dailyHoursLimit: value.round());
                        _hasChanges = true;
                      });
                    },
                    valueLabel: (value) => '$value ${value == 1 ? 'hour' : 'hours'}',
                  ),
                  SizedBox(height: 32.h),

                  // Category limits section
                  Text(
                    'Category Limits',
                    style: theme.textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Set maximum tasks per day for each category',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16.h),

                  // Category limit sliders
                  ...categories.map((category) => _buildCategoryLimitSection(
                        theme,
                        category: category,
                        value: _taskLimit.categoryLimits[category.id] ?? 0,
                      )),
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

  Widget _buildLimitSection(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required int value,
    required double min,
    required double max,
    required IconData icon,
    required ValueChanged<double> onChanged,
    String Function(int)? valueLabel,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Text(
                  valueLabel != null ? valueLabel(value) : value.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Slider(
                    value: value.toDouble(),
                    min: min,
                    max: max,
                    divisions: (max - min).round(),
                    label: valueLabel != null ? valueLabel(value) : value.toString(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLimitSection(
    ThemeData theme, {
    required Category category,
    required int value,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 16.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: category.color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  category.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Text(
                  '$value ${value == 1 ? 'task' : 'tasks'}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Slider(
                    value: value.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: '$value ${value == 1 ? 'task' : 'tasks'}',
                    activeColor: category.color,
                    onChanged: (newValue) {
                      final newCategoryLimits = Map<String, int>.from(_taskLimit.categoryLimits);
                      newCategoryLimits[category.id] = newValue.round();
                      
                      setState(() {
                        _taskLimit = _taskLimit.copyWith(categoryLimits: newCategoryLimits);
                        _hasChanges = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _taskLimit = TaskLimit(
        dailyLimit: 5,
        weeklyLimit: 25,
        dailyHoursLimit: 8,
        categoryLimits: {
          'home': 3,
          'work': 5,
          'health': 2,
          'social': 2,
          'finance': 1,
        },
      );
      _hasChanges = true;
    });
  }

  Future<void> _saveTaskLimits() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Validate limits
      if (_taskLimit.weeklyLimit < _taskLimit.dailyLimit * 5) {
        // Show warning if weekly limit is less than 5 days of daily limit
        final shouldContinue = await _showWeeklyLimitWarning();
        if (!shouldContinue) {
          setState(() {
            _isSaving = false;
          });
          return;
        }
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update provider with new values
      ref.read(taskLimitProvider.notifier).state = _taskLimit;
      
      // In a real app, we would call an API to save task limits
      Logger.debug('Saving task limits:');
      Logger.debug('Daily limit: ${_taskLimit.dailyLimit}');
      Logger.debug('Weekly limit: ${_taskLimit.weeklyLimit}');
      Logger.debug('Daily hours limit: ${_taskLimit.dailyHoursLimit}');
      Logger.debug('Category limits: ${_taskLimit.categoryLimits}');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task limits saved'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      Logger.error('Error saving task limits: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save task limits'),
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

  Future<bool> _showWeeklyLimitWarning() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weekly Limit Warning'),
        content: Text(
          'Your weekly limit (${_taskLimit.weeklyLimit}) is less than 5 days of your daily limit (${_taskLimit.dailyLimit * 5}).\n\n'
          'This might result in hitting your weekly limit before the week ends.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ADJUST LIMITS'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('SAVE ANYWAY'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}
