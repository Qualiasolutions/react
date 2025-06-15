import 'package:flutter/material.dart';

void main() {
  runApp(const VuetInstantApp());
}

class VuetInstantApp extends StatelessWidget {
  const VuetInstantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vuet - Instant Load',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: const Color(0xFFD2691E),
      ),
      home: const VuetMainScreen(),
    );
  }
}

class VuetMainScreen extends StatefulWidget {
  const VuetMainScreen({super.key});

  @override
  _VuetMainScreenState createState() => _VuetMainScreenState();
}

class _VuetMainScreenState extends State<VuetMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vuet - Task Manager'),
        backgroundColor: const Color(0xFF4A4A4A),
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          CategoriesScreen(),
          TasksScreen(),
          ListsScreen(),
          MessagesScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFFD2691E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lists'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        backgroundColor: const Color(0xFFD2691E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.task, color: Colors.green),
              title: const Text('Create Task'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task created!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.purple),
              title: const Text('Add Entity'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entity added!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD2691E), Color(0xFFFF8C42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.waving_hand, size: 48, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Welcome to Vuet!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  'Task Management Simplified',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      'Tasks Today', '5', Icons.today, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard(
                      'Categories', '13', Icons.category, Colors.purple)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      'Entities', '42', Icons.inventory, Colors.green)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard(
                      'Messages', '8', Icons.message, Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildActivityItem('Team Meeting scheduled',
              'Fixed task for today at 2:00 PM', Icons.work, Colors.blue),
          _buildActivityItem(
              'Car maintenance due',
              'Vehicle inspection needed this week',
              Icons.car_repair,
              Colors.red),
          _buildActivityItem('New pet added', 'Fluffy the cat added to pets',
              Icons.pets, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'Family',
        'icon': Icons.family_restroom,
        'color': Colors.red,
        'count': '12'
      },
      {
        'name': 'Pets',
        'icon': Icons.pets,
        'color': Colors.orange,
        'count': '3'
      },
      {
        'name': 'Social',
        'icon': Icons.group,
        'color': Colors.purple,
        'count': '8'
      },
      {
        'name': 'Education',
        'icon': Icons.school,
        'color': Colors.blue,
        'count': '5'
      },
      {
        'name': 'Career',
        'icon': Icons.work,
        'color': Colors.indigo,
        'count': '15'
      },
      {
        'name': 'Travel',
        'icon': Icons.flight,
        'color': Colors.cyan,
        'count': '7'
      },
      {
        'name': 'Health',
        'icon': Icons.favorite,
        'color': Colors.pink,
        'count': '9'
      },
      {
        'name': 'Home',
        'icon': Icons.home,
        'color': Colors.brown,
        'count': '23'
      },
      {
        'name': 'Garden',
        'icon': Icons.local_florist,
        'color': Colors.green,
        'count': '11'
      },
      {
        'name': 'Food',
        'icon': Icons.restaurant,
        'color': Colors.amber,
        'count': '6'
      },
      {
        'name': 'Finance',
        'icon': Icons.account_balance,
        'color': Colors.teal,
        'count': '4'
      },
      {
        'name': 'Transport',
        'icon': Icons.directions_car,
        'color': Colors.grey,
        'count': '2'
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('13 Life Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Organize your entities across all aspects of life',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  elevation: 3,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Opened ${category['name']} category')),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(category['icon'] as IconData,
                              size: 48, color: category['color'] as Color),
                          const SizedBox(height: 12),
                          Text(
                            category['name'] as String,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text('${category['count']} items',
                              style:
                                  const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.task_alt, size: 32, color: Color(0xFFD2691E)),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Task Management',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Fixed & Flexible task system',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: _buildTaskTypeCard('Fixed Tasks', 'Specific times',
                      Icons.schedule, Colors.blue, '12 active')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildTaskTypeCard('Flexible Tasks', 'Due dates',
                      Icons.access_time, Colors.green, '8 pending')),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Today\'s Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTaskCard('Team Meeting', 'Fixed Task - 2:00 PM', Icons.work,
              Colors.blue, true),
          _buildTaskCard('Doctor Appointment', 'Fixed Task - 4:30 PM',
              Icons.medical_services, Colors.red, false),
          _buildTaskCard('Grocery Shopping', 'Flexible Task - Due today',
              Icons.shopping_cart, Colors.green, false),
        ],
      ),
    );
  }

  Widget _buildTaskTypeCard(String title, String subtitle, IconData icon,
      Color color, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Text(status,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String title, String subtitle, IconData icon,
      Color color, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null)),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Checkbox(
              value: isCompleted, onChanged: (value) {}, activeColor: color),
        ],
      ),
    );
  }
}

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 80, color: Colors.blue),
          SizedBox(height: 24),
          Text('Lists & Organization',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Create custom lists to organize your tasks and entities.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Family Messages',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Real-time communication with family members',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildMessageBubble('Mom', 'Don\'t forget dinner at 6 PM!',
                    '2:30 PM', false, Colors.purple),
                _buildMessageBubble('You', 'Got it! I\'ll be there', '2:32 PM',
                    true, const Color(0xFFD2691E)),
                _buildMessageBubble('Dad', 'Car inspection tomorrow', '3:15 PM',
                    false, Colors.blue),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Expanded(
                    child: TextField(
                        decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none))),
                IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFD2691E)),
                    onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      String sender, String message, String time, bool isMe, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
                backgroundColor: color,
                radius: 16,
                child: Text(sender[0],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFD2691E) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(sender,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color)),
                  if (!isMe) const SizedBox(height: 4),
                  Text(message,
                      style: TextStyle(
                          fontSize: 14,
                          color: isMe ? Colors.white : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(time,
                      style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.grey[600])),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
                backgroundColor: color,
                radius: 16,
                child: const Text('Y',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold))),
          ],
        ],
      ),
    );
  }
}
