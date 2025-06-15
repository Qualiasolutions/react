// lib/features/lists/screens/lists_screen.dart
// Lists screen that exactly matches the React Native design from screenshots

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/user/providers/user_provider.dart';

// Tab index provider
final selectedListTabProvider = StateProvider<int>((ref) => 0);

// Models for lists
class ListItem {
  final String id;
  final String name;
  final bool completed;

  ListItem({
    required this.id,
    required this.name,
    this.completed = false,
  });
}

class ShoppingList {
  final String id;
  final String name;
  final String? store;
  final DateTime createdAt;
  final List<ListItem> items;
  final List<String> delegatedToUserIds;

  ShoppingList({
    required this.id,
    required this.name,
    this.store,
    required this.createdAt,
    required this.items,
    this.delegatedToUserIds = const [],
  });
}

class PlanningList {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<ListItem> items;
  final bool isTemplate;

  PlanningList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.items,
    this.isTemplate = false,
  });
}

// Sample user data for delegations
class UserSummary {
  final String id;
  final String name;
  final String? avatarUrl;
  final Color color;

  UserSummary({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.color,
  });
}

// Providers for shopping lists and planning lists
final shoppingListsProvider = StateNotifierProvider<ShoppingListsNotifier, List<ShoppingList>>((ref) {
  return ShoppingListsNotifier();
});

class ShoppingListsNotifier extends StateNotifier<List<ShoppingList>> {
  ShoppingListsNotifier() : super([
    // Sample data - in real app would come from Supabase
    ShoppingList(
      id: '1',
      name: 'Weekly Groceries',
      store: 'Supermarket',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      items: [
        ListItem(id: '1', name: 'Milk', completed: true),
        ListItem(id: '2', name: 'Bread'),
        ListItem(id: '3', name: 'Eggs'),
        ListItem(id: '4', name: 'Cheese'),
      ],
      delegatedToUserIds: ['user2'],
    ),
    ShoppingList(
      id: '2',
      name: 'Hardware Store',
      store: 'Home Depot',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      items: [
        ListItem(id: '5', name: 'Screws'),
        ListItem(id: '6', name: 'Paint'),
      ],
    ),
  ]);

  void addList(ShoppingList list) {
    state = [...state, list];
  }

  void toggleItemCompletion(String listId, String itemId) {
    state = state.map((list) {
      if (list.id == listId) {
        final updatedItems = list.items.map((item) {
          if (item.id == itemId) {
            return ListItem(
              id: item.id,
              name: item.name,
              completed: !item.completed,
            );
          }
          return item;
        }).toList();

        return ShoppingList(
          id: list.id,
          name: list.name,
          store: list.store,
          createdAt: list.createdAt,
          items: updatedItems,
          delegatedToUserIds: list.delegatedToUserIds,
        );
      }
      return list;
    }).toList();
  }

  void addItemToList(String listId, String itemName) {
    if (itemName.isEmpty) return;

    state = state.map((list) {
      if (list.id == listId) {
        final newItem = ListItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: itemName,
        );
        return ShoppingList(
          id: list.id,
          name: list.name,
          store: list.store,
          createdAt: list.createdAt,
          items: [...list.items, newItem],
          delegatedToUserIds: list.delegatedToUserIds,
        );
      }
      return list;
    }).toList();
  }

  void delegateList(String listId, String userId) {
    state = state.map((list) {
      if (list.id == listId) {
        List<String> updatedDelegations = List.from(list.delegatedToUserIds);
        if (!updatedDelegations.contains(userId)) {
          updatedDelegations.add(userId);
        }
        
        return ShoppingList(
          id: list.id,
          name: list.name,
          store: list.store,
          createdAt: list.createdAt,
          items: list.items,
          delegatedToUserIds: updatedDelegations,
        );
      }
      return list;
    }).toList();
  }
}

final planningListsProvider = StateNotifierProvider<PlanningListsNotifier, List<PlanningList>>((ref) {
  return PlanningListsNotifier();
});

class PlanningListsNotifier extends StateNotifier<List<PlanningList>> {
  PlanningListsNotifier() : super([
    // Sample data - in real app would come from Supabase
    PlanningList(
      id: '1',
      name: 'Vacation Planning',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      items: [
        ListItem(id: '1', name: 'Book flights', completed: true),
        ListItem(id: '2', name: 'Reserve hotel'),
        ListItem(id: '3', name: 'Research activities'),
      ],
    ),
    PlanningList(
      id: '2',
      name: 'Home Renovation',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      items: [
        ListItem(id: '4', name: 'Get quotes'),
        ListItem(id: '5', name: 'Buy materials'),
      ],
    ),
    PlanningList(
      id: '3',
      name: 'Party Template',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      items: [
        ListItem(id: '6', name: 'Send invitations'),
        ListItem(id: '7', name: 'Buy decorations'),
        ListItem(id: '8', name: 'Prepare food list'),
      ],
      isTemplate: true,
    ),
  ]);

  void addList(PlanningList list) {
    state = [...state, list];
  }

  void toggleItemCompletion(String listId, String itemId) {
    state = state.map((list) {
      if (list.id == listId) {
        final updatedItems = list.items.map((item) {
          if (item.id == itemId) {
            return ListItem(
              id: item.id,
              name: item.name,
              completed: !item.completed,
            );
          }
          return item;
        }).toList();

        return PlanningList(
          id: list.id,
          name: list.name,
          createdAt: list.createdAt,
          items: updatedItems,
          isTemplate: list.isTemplate,
        );
      }
      return list;
    }).toList();
  }

  void addItemToList(String listId, String itemName) {
    if (itemName.isEmpty) return;

    state = state.map((list) {
      if (list.id == listId) {
        final newItem = ListItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: itemName,
        );
        return PlanningList(
          id: list.id,
          name: list.name,
          createdAt: list.createdAt,
          items: [...list.items, newItem],
          isTemplate: list.isTemplate,
        );
      }
      return list;
    }).toList();
  }

  void createListFromTemplate(String templateId, String newName) {
    final template = state.firstWhere(
      (list) => list.id == templateId && list.isTemplate,
      orElse: () => PlanningList(
        id: '',
        name: '',
        createdAt: DateTime.now(),
        items: [],
      ),
    );

    if (template.id.isEmpty) return;

    final newList = PlanningList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: newName,
      createdAt: DateTime.now(),
      items: template.items.map((item) => 
        ListItem(id: DateTime.now().millisecondsSinceEpoch.toString() + item.id, name: item.name)
      ).toList(),
      isTemplate: false,
    );

    state = [...state, newList];
  }
}

// Provider for family members (for delegation)
final familyMembersProvider = Provider<List<UserSummary>>((ref) {
  // In a real app, this would be fetched from Supabase
  return [
    UserSummary(
      id: 'user1',
      name: 'You',
      color: Colors.blue,
    ),
    UserSummary(
      id: 'user2',
      name: 'Sarah',
      color: Colors.pink,
    ),
    UserSummary(
      id: 'user3',
      name: 'Mike',
      color: Colors.green,
    ),
  ];
});

class ListsScreen extends ConsumerStatefulWidget {
  const ListsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _newListNameController = TextEditingController();
  final TextEditingController _newListStoreController = TextEditingController();
  final TextEditingController _newItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      ref.read(selectedListTabProvider.notifier).state = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newListNameController.dispose();
    _newListStoreController.dispose();
    _newItemController.dispose();
    super.dispose();
  }

  // Show dialog to add a new shopping list
  void _showAddShoppingListDialog() {
    _newListNameController.clear();
    _newListStoreController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Shopping List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newListNameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _newListStoreController,
              decoration: const InputDecoration(
                labelText: 'Store (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_newListNameController.text.isNotEmpty) {
                // Add new shopping list
                final newList = ShoppingList(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _newListNameController.text,
                  store: _newListStoreController.text.isEmpty ? null : _newListStoreController.text,
                  createdAt: DateTime.now(),
                  items: [],
                );
                ref.read(shoppingListsProvider.notifier).addList(newList);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Show dialog to add a new planning list
  void _showAddPlanningListDialog() {
    _newListNameController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Planning List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newListNameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16.h),
            // Checkbox for template
            StatefulBuilder(
              builder: (context, setState) {
                bool isTemplate = false;
                return CheckboxListTile(
                  title: const Text('Save as template'),
                  value: isTemplate,
                  onChanged: (value) {
                    setState(() {
                      isTemplate = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_newListNameController.text.isNotEmpty) {
                // Add new planning list
                final newList = PlanningList(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _newListNameController.text,
                  createdAt: DateTime.now(),
                  items: [],
                  isTemplate: false, // Get from checkbox
                );
                ref.read(planningListsProvider.notifier).addList(newList);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Show dialog to delegate a list
  void _showDelegateListDialog(ShoppingList list) {
    final familyMembers = ref.read(familyMembersProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delegate "${list.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose a family member to delegate this list to:'),
            SizedBox(height: 16.h),
            ...familyMembers.map((member) {
              final isSelected = list.delegatedToUserIds.contains(member.id);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: member.color,
                  child: member.avatarUrl != null
                      ? null
                      : Text(
                          member.name.substring(0, 1),
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
                title: Text(member.name),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFFD2691E),
                      )
                    : null,
                onTap: () {
                  // Delegate list to this member
                  ref.read(shoppingListsProvider.notifier).delegateList(list.id, member.id);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Add new item to a list
  void _showAddItemDialog(String listId, bool isShoppingList) {
    _newItemController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: TextField(
          controller: _newItemController,
          decoration: const InputDecoration(
            labelText: 'Item Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_newItemController.text.isNotEmpty) {
                if (isShoppingList) {
                  ref.read(shoppingListsProvider.notifier).addItemToList(
                        listId,
                        _newItemController.text,
                      );
                } else {
                  ref.read(planningListsProvider.notifier).addItemToList(
                        listId,
                        _newItemController.text,
                      );
                }
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedListTabProvider);
    final shoppingLists = ref.watch(shoppingListsProvider);
    final planningLists = ref.watch(planningListsProvider);
    final userFullName = ref.watch(userFullNameProvider) ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFD2691E),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFD2691E),
              tabs: [
                Tab(
                  text: 'Shopping Lists',
                  icon: Icon(
                    Icons.shopping_cart,
                    color: selectedTab == 0 ? const Color(0xFFD2691E) : Colors.grey,
                  ),
                ),
                Tab(
                  text: 'Planning Lists',
                  icon: Icon(
                    Icons.checklist,
                    color: selectedTab == 1 ? const Color(0xFFD2691E) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Shopping Lists Tab
                shoppingLists.isEmpty
                    ? _buildEmptyState(
                        'No Shopping Lists',
                        'Create your first shopping list',
                        Icons.shopping_cart,
                        _showAddShoppingListDialog,
                      )
                    : _buildShoppingLists(shoppingLists),
                
                // Planning Lists Tab
                planningLists.isEmpty
                    ? _buildEmptyState(
                        'No Planning Lists',
                        'Create your first planning list',
                        Icons.checklist,
                        _showAddPlanningListDialog,
                      )
                    : _buildPlanningLists(planningLists),
              ],
            ),
          ),
        ],
      ),
      // FAB for adding new list
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedTab == 0) {
            _showAddShoppingListDialog();
          } else {
            _showAddPlanningListDialog();
          }
        },
        backgroundColor: const Color(0xFFD2691E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onAddPressed,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: const Text('Add List'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD2691E),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  // Shopping lists widget
  Widget _buildShoppingLists(List<ShoppingList> lists) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        final completedItems = list.items.where((item) => item.completed).length;
        final totalItems = list.items.length;
        final progress = totalItems > 0 ? completedItems / totalItems : 0.0;
        
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              // List header
              ListTile(
                title: Text(
                  list.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (list.store != null)
                      Text(
                        list.store!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    Text(
                      '$completedItems of $totalItems items',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Delegate button
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () => _showDelegateListDialog(list),
                    ),
                    // Add item button
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddItemDialog(list.id, true),
                    ),
                  ],
                ),
              ),
              
              // Progress bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD2691E)),
                  minHeight: 4.h,
                ),
              ),
              
              // List items
              if (list.items.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.items.length,
                  itemBuilder: (context, itemIndex) {
                    final item = list.items[itemIndex];
                    return CheckboxListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: item.completed ? TextDecoration.lineThrough : null,
                          color: item.completed ? Colors.grey : Colors.black87,
                        ),
                      ),
                      value: item.completed,
                      onChanged: (value) {
                        ref.read(shoppingListsProvider.notifier).toggleItemCompletion(
                              list.id,
                              item.id,
                            );
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                )
              else
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'No items in this list yet',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              
              // Add item button
              Padding(
                padding: EdgeInsets.all(16.w),
                child: OutlinedButton.icon(
                  onPressed: () => _showAddItemDialog(list.id, true),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD2691E),
                    side: const BorderSide(color: Color(0xFFD2691E)),
                  ),
                ),
              ),
              
              // Delegated users
              if (list.delegatedToUserIds.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people,
                        size: 16,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Delegated to: ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      ...list.delegatedToUserIds.map((userId) {
                        final user = ref.read(familyMembersProvider).firstWhere(
                              (u) => u.id == userId,
                              orElse: () => UserSummary(
                                id: '',
                                name: 'Unknown',
                                color: Colors.grey,
                              ),
                            );
                        
                        return Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: CircleAvatar(
                            radius: 12.r,
                            backgroundColor: user.color,
                            child: Text(
                              user.name.substring(0, 1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Planning lists widget
  Widget _buildPlanningLists(List<PlanningList> lists) {
    // Separate templates from regular lists
    final templates = lists.where((list) => list.isTemplate).toList();
    final regularLists = lists.where((list) => !list.isTemplate).toList();
    
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Templates section (if any)
        if (templates.isNotEmpty) ...[
          Text(
            'Templates',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          ...templates.map((template) => _buildPlanningListCard(template)),
          SizedBox(height: 16.h),
          const Divider(),
          SizedBox(height: 16.h),
        ],
        
        // Regular lists section
        Text(
          'My Lists',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        ...regularLists.map((list) => _buildPlanningListCard(list)),
      ],
    );
  }

  // Planning list card widget
  Widget _buildPlanningListCard(PlanningList list) {
    final completedItems = list.items.where((item) => item.completed).length;
    final totalItems = list.items.length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // List header
          ListTile(
            title: Row(
              children: [
                Text(
                  list.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (list.isTemplate)
                  Container(
                    margin: EdgeInsets.only(left: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Template',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              '$completedItems of $totalItems items',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use template button (if it's a template)
                if (list.isTemplate)
                  IconButton(
                    icon: const Icon(Icons.file_copy),
                    onPressed: () {
                      // Show dialog to create list from template
                      _newListNameController.text = list.name;
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Create from Template'),
                          content: TextField(
                            controller: _newListNameController,
                            decoration: const InputDecoration(
                              labelText: 'New List Name',
                              border: OutlineInputBorder(),
                            ),
                            autofocus: true,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (_newListNameController.text.isNotEmpty) {
                                  ref.read(planningListsProvider.notifier).createListFromTemplate(
                                        list.id,
                                        _newListNameController.text,
                                      );
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Create'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                // Add item button
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddItemDialog(list.id, false),
                ),
              ],
            ),
          ),
          
          // Progress bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD2691E)),
              minHeight: 4.h,
            ),
          ),
          
          // List items
          if (list.items.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.items.length,
              itemBuilder: (context, itemIndex) {
                final item = list.items[itemIndex];
                return CheckboxListTile(
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.completed ? TextDecoration.lineThrough : null,
                      color: item.completed ? Colors.grey : Colors.black87,
                    ),
                  ),
                  value: item.completed,
                  onChanged: (value) {
                    ref.read(planningListsProvider.notifier).toggleItemCompletion(
                          list.id,
                          item.id,
                        );
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            )
          else
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'No items in this list yet',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          
          // Add item button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: OutlinedButton.icon(
              onPressed: () => _showAddItemDialog(list.id, false),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD2691E),
                side: const BorderSide(color: Color(0xFFD2691E)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
