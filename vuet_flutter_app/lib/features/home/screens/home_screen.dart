// lib/features/home/screens/home_screen.dart
// Home screen with calendar view and tasks that exactly matches the React Native design

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:vuet_flutter/core/utils/logger.dart';

// Sample task data provider (would be replaced with real data from Supabase)
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final tasksProvider = Provider<List<TaskItem>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  // Sample tasks - in real app would come from Supabase
  return [
    TaskItem(
      id: '1',
      title: 'Task: Do research about X',
      dateTime: DateTime.now(),
      type: TaskType.task,
    ),
    TaskItem(
      id: '2',
      title: 'Appointment: doctor',
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      type: TaskType.appointment,
    ),
  ];
});

// Task type enum
enum TaskType { task, appointment, dueDate, flight }

// Task item model
class TaskItem {
  final String id;
  final String title;
  final DateTime dateTime;
  final TaskType type;

  TaskItem({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.type,
  });

  // Get color based on task type
  Color get color {
    switch (type) {
      case TaskType.task:
        return const Color(0xFF4CAF50); // Green
      case TaskType.appointment:
        return const Color(0xFF9C27B0); // Purple
      case TaskType.dueDate:
        return const Color(0xFFF44336); // Red
      case TaskType.flight:
        return const Color(0xFF2196F3); // Blue
    }
  }

  // Get icon based on task type
  IconData get icon {
    switch (type) {
      case TaskType.task:
        return Icons.check_circle_outline;
      case TaskType.appointment:
        return Icons.person;
      case TaskType.dueDate:
        return Icons.event;
      case TaskType.flight:
        return Icons.flight;
    }
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar title and settings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Calendar title
                    Text(
                      'Calendar',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    // Row with settings and expand buttons
                    Row(
                      children: [
                        // Settings button
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Logger.debug('Calendar settings pressed');
                          },
                        ),
                        
                        // Expand/collapse button
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                              _calendarFormat = _isExpanded 
                                  ? CalendarFormat.month 
                                  : CalendarFormat.week;
                            });
                          },
                          icon: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.black54,
                          ),
                          label: Text(
                            _isExpanded ? 'Collapse' : 'Expand',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.sp,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Date subtitle
                Text(
                  DateFormat('MMMM d, yyyy').format(selectedDate),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Calendar widget
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDate,
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              ref.read(selectedDateProvider.notifier).state = selectedDay;
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
                _isExpanded = format == CalendarFormat.month;
              });
            },
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.black54),
              rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.black54),
              titleTextStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              markersMaxCount: 3,
              markersAnchor: 1.7,
              markerDecoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                shape: BoxShape.circle,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.black87,
                fontSize: 14.sp,
              ),
              weekendStyle: TextStyle(
                color: Colors.black54,
                fontSize: 14.sp,
              ),
            ),
          ),
          
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks and events...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 16.w,
                ),
              ),
              onChanged: (value) {
                // Search functionality would be implemented here
                Logger.debug('Search: $value');
              },
            ),
          ),
          
          // Today section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today header
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 24.sp,
                          color: Colors.black87,
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Task list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskListItem(task: task);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Task list item widget
class TaskListItem extends StatelessWidget {
  final TaskItem task;
  
  const TaskListItem({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('HH:mm').format(task.dateTime),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '00:00',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            // Task type indicator
            Container(
              width: 4.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: task.color,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 12.w),
            // Task content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task type
                  Text(
                    task.type.toString().split('.').last.capitalize(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: task.color,
                    ),
                  ),
                  // Task title
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: () {
          // Navigate to task details
          Logger.debug('Task tapped: ${task.id}');
        },
      ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
