import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/features/auth/domain/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vuet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            Container(
              padding: EdgeInsets.all(AppTheme.spacingM.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.borderRadiusL.r),
                  bottomRight: Radius.circular(AppTheme.borderRadiusL.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user?.displayName ?? 'User'}!',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: AppTheme.spacingXs.h),
                  Text(
                    'Your tasks and life, simplified.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                  SizedBox(height: AppTheme.spacingM.h),
                  // Quick Actions (e.g., Add Task, Add Entity)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickActionButton(
                        context,
                        icon: Icons.add_task,
                        label: 'Add Task',
                        onTap: () {
                          // TODO: Navigate to Add Task Screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Add Task coming soon!')),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.add_box,
                        label: 'Add Entity',
                        onTap: () {
                          // TODO: Navigate to Add Entity Screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Add Entity coming soon!')),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.calendar_today,
                        label: 'View Calendar',
                        onTap: () => context.go('/calendar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.spacingM.h),

            // Task Overview Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Day at a Glance',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: AppTheme.spacingS.h),
                  Card(
                    elevation: AppTheme.elevationS,
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacingM.w),
                      child: Column(
                        children: [
                          _buildTaskOverviewItem(
                            context,
                            icon: Icons.today,
                            label: 'Tasks Due Today',
                            count: 5, // Placeholder
                            color: AppTheme.primaryColor,
                            onTap: () {
                              // TODO: Navigate to Today's Tasks
                            },
                          ),
                          Divider(height: AppTheme.spacingM.h),
                          _buildTaskOverviewItem(
                            context,
                            icon: Icons.warning_amber,
                            label: 'Overdue Tasks',
                            count: 2, // Placeholder
                            color: AppTheme.errorColor,
                            onTap: () {
                              // TODO: Navigate to Overdue Tasks
                            },
                          ),
                          Divider(height: AppTheme.spacingM.h),
                          _buildTaskOverviewItem(
                            context,
                            icon: Icons.event_note,
                            label: 'Upcoming Events',
                            count: 3, // Placeholder
                            color: AppTheme.secondaryColor,
                            onTap: () {
                              // TODO: Navigate to Upcoming Events
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.spacingL.h),

            // Categories Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Categories',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: AppTheme.spacingS.h),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: AppTheme.spacingM.w,
                    crossAxisSpacing: AppTheme.spacingM.w,
                    childAspectRatio: 1.2, // Adjust as needed
                    children: [
                      _buildCategoryCard(
                        context,
                        'FAMILY',
                        Icons.family_restroom,
                        AppTheme.categoryColors['FAMILY']!,
                        () => context.go('/categories?id=1'),
                      ),
                      _buildCategoryCard(
                        context,
                        'PETS',
                        Icons.pets,
                        AppTheme.categoryColors['PETS']!,
                        () => context.go('/categories?id=2'),
                      ),
                      _buildCategoryCard(
                        context,
                        'SOCIAL_INTERESTS',
                        Icons.people,
                        AppTheme.categoryColors['SOCIAL_INTERESTS']!,
                        () => context.go('/categories?id=3'),
                      ),
                      _buildCategoryCard(
                        context,
                        'EDUCATION',
                        Icons.school,
                        AppTheme.categoryColors['EDUCATION']!,
                        () => context.go('/categories?id=4'),
                      ),
                      _buildCategoryCard(
                        context,
                        'CAREER',
                        Icons.work,
                        AppTheme.categoryColors['CAREER']!,
                        () => context.go('/categories?id=5'),
                      ),
                      _buildCategoryCard(
                        context,
                        'TRAVEL',
                        Icons.flight,
                        AppTheme.categoryColors['TRAVEL']!,
                        () => context.go('/categories?id=6'),
                      ),
                      // Add more categories as needed
                    ],
                  ),
                  SizedBox(height: AppTheme.spacingM.h),
                  Center(
                    child: OutlinedButton(
                      onPressed: () => context.go('/categories'),
                      child: const Text('View All Categories'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacingL.h),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/categories');
              break;
            case 2:
              context.go('/calendar'); // Assuming tasks are viewed in calendar
              break;
            case 3:
              context.go('/messages');
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add task dialog or navigate to add task screen
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add New Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_task),
                    title: const Text('Add Task'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to Add Task Screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add Task coming soon!')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_box),
                    title: const Text('Add Entity'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to Add Entity Screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add Entity coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        FloatingActionButton.small(
          heroTag: label, // Unique tag for each FAB
          onPressed: onTap,
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          elevation: AppTheme.elevationS,
          child: Icon(icon, size: 24.w),
        ),
        SizedBox(height: AppTheme.spacingXs.h),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
              ),
        ),
      ],
    );
  }

  Widget _buildTaskOverviewItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusM.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingS.h),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28.w),
            SizedBox(width: AppTheme.spacingM.w),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(width: AppTheme.spacingS.w),
            Icon(Icons.arrow_forward_ios, size: 16.w, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String categoryName,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusL.r),
      child: Card(
        elevation: AppTheme.elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusL.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacingM.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40.w,
                color: color,
              ),
            ),
            SizedBox(height: AppTheme.spacingS.h),
            Text(
              AppTheme.categoryColors.keys.firstWhere(
                (k) => AppTheme.categoryColors[k] == color,
                orElse: () => categoryName,
              ),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
