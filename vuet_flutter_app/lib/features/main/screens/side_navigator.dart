// lib/features/main/screens/side_navigator.dart
// Main navigation component that handles both drawer (web) and bottom navigation (mobile)
// Exactly matches the React Native navigation structure from the screenshots

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/user/providers/user_provider.dart';

// Tab screens
import 'package:vuet_flutter/features/home/screens/home_screen.dart';
import 'package:vuet_flutter/features/categories/screens/categories_screen.dart';
import 'package:vuet_flutter/features/lists/screens/lists_screen.dart';
import 'package:vuet_flutter/features/messages/screens/messages_screen.dart';

// Current tab provider
final currentTabProvider = StateProvider<int>((ref) => 0);

class SideNavigator extends ConsumerStatefulWidget {
  final bool hasJustSignedUp;
  
  const SideNavigator({
    Key? key,
    this.hasJustSignedUp = false,
  }) : super(key: key);

  @override
  ConsumerState<SideNavigator> createState() => _SideNavigatorState();
}

class _SideNavigatorState extends ConsumerState<SideNavigator> {
  // Key for the scaffold to access the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Tab screens
  late final List<Widget> _tabScreens;
  
  // Tab titles
  final List<String> _tabTitles = [
    'Home',
    'Categories',
    'Lists',
    'Messages',
  ];
  
  // Tab icons
  final List<IconData> _tabIcons = [
    Icons.home_outlined,
    Icons.grid_view_outlined,
    Icons.list_alt_outlined,
    Icons.chat_bubble_outline,
  ];
  
  // Selected tab icons (filled versions)
  final List<IconData> _selectedTabIcons = [
    Icons.home,
    Icons.grid_view,
    Icons.list_alt,
    Icons.chat_bubble,
  ];
  
  // FAB actions based on current tab
  void _handleFabPressed() {
    final currentTab = ref.read(currentTabProvider);
    
    switch (currentTab) {
      case 0: // Home
        _showAddTaskDialog();
        break;
      case 1: // Categories
        _showAddEntityDialog();
        break;
      case 2: // Lists
        _showAddListDialog();
        break;
      case 3: // Messages
        _showNewMessageDialog();
        break;
    }
  }
  
  // Dialog placeholders - these would be implemented with actual functionality
  void _showAddTaskDialog() {
    _showComingSoonDialog('Add Task');
  }
  
  void _showAddEntityDialog() {
    _showComingSoonDialog('Add Entity');
  }
  
  void _showAddListDialog() {
    _showComingSoonDialog('Add List');
  }
  
  void _showNewMessageDialog() {
    _showComingSoonDialog('New Message');
  }
  
  // Temporary placeholder for dialogs
  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $feature'),
        content: Text('$feature functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize tab screens
    _tabScreens = [
      const HomeScreen(),
      const CategoriesScreen(),
      const ListsScreen(),
      const MessagesScreen(),
    ];
    
    // Show welcome message for new users
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.hasJustSignedUp) {
        _showWelcomeDialog();
      }
    });
  }
  
  // Welcome dialog for new users
  void _showWelcomeDialog() {
    final userName = ref.read(userFullNameProvider) ?? 'there';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to Vuet!'),
        content: Text('Hi $userName! Your account is all set up and ready to go. Start by adding your first task or entity.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final userFullName = ref.watch(userFullNameProvider) ?? 'User';
    final userEmail = ref.watch(userEmailProvider) ?? 'user@example.com';
    final userAvatar = ref.watch(userAvatarProvider);
    
    return Scaffold(
      key: _scaffoldKey,
      
      // App Bar
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A4A4A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_tabTitles[currentTab]),
        centerTitle: false,
        leading: isDesktop
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _handleFabPressed(),
          ),
        ],
      ),
      
      // Drawer for desktop/tablet
      drawer: isDesktop
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A4A4A),
                    ),
                    accountName: Text(userFullName),
                    accountEmail: Text(userEmail),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: userAvatar != null
                          ? NetworkImage(userAvatar)
                          : null,
                      child: userAvatar == null
                          ? const Icon(Icons.person, color: Color(0xFF4A4A4A))
                          : null,
                    ),
                  ),
                  
                  // Navigation items
                  for (int i = 0; i < _tabTitles.length; i++)
                    ListTile(
                      leading: Icon(
                        currentTab == i ? _selectedTabIcons[i] : _tabIcons[i],
                        color: currentTab == i ? const Color(0xFFD2691E) : null,
                      ),
                      title: Text(
                        _tabTitles[i],
                        style: TextStyle(
                          fontWeight: currentTab == i ? FontWeight.bold : FontWeight.normal,
                          color: currentTab == i ? const Color(0xFFD2691E) : null,
                        ),
                      ),
                      selected: currentTab == i,
                      onTap: () {
                        ref.read(currentTabProvider.notifier).state = i;
                        if (!isDesktop) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  
                  const Divider(),
                  
                  // Settings
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    onTap: () {
                      // Navigate to settings
                      Logger.debug('Navigate to settings');
                    },
                  ),
                  
                  // Help
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help'),
                    onTap: () {
                      // Navigate to help
                      Logger.debug('Navigate to help');
                    },
                  ),
                ],
              ),
            )
          : null,
      
      // Body - Current tab content
      body: _tabScreens[currentTab],
      
      // Floating Action Button - centered on the bottom navigation
      floatingActionButton: FloatingActionButton(
        onPressed: _handleFabPressed,
        backgroundColor: const Color(0xFFD2691E), // Exact color from screenshots
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Bottom Navigation - for mobile
      bottomNavigationBar: !isDesktop
          ? BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              color: Colors.white,
              child: SizedBox(
                height: 60.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_tabTitles.length, (index) {
                    // Create two groups of tabs, before and after the FAB
                    if (index == _tabTitles.length ~/ 2) {
                      return const SizedBox(width: 40); // Space for FAB
                    }
                    
                    final adjustedIndex = index >= _tabTitles.length ~/ 2 ? index - 1 : index;
                    final isSelected = currentTab == adjustedIndex;
                    
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          ref.read(currentTabProvider.notifier).state = adjustedIndex;
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelected ? _selectedTabIcons[adjustedIndex] : _tabIcons[adjustedIndex],
                              color: isSelected ? const Color(0xFFD2691E) : Colors.grey,
                            ),
                            Text(
                              _tabTitles[adjustedIndex],
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isSelected ? const Color(0xFFD2691E) : Colors.grey,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            )
          : null,
    );
  }
}

// Placeholder screen implementations
// These would be replaced with actual screen implementations

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Screen - Calendar and Tasks'),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Categories Screen'),
    );
  }
}

class ListsScreen extends StatelessWidget {
  const ListsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Lists Screen'),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Messages Screen'),
    );
  }
}
