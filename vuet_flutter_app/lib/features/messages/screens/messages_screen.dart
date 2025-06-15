// lib/features/messages/screens/messages_screen.dart
// Messages screen that exactly matches the React Native design from screenshots

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vuet_flutter/core/utils/logger.dart';

// Models for messages and conversations
class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });
}

class Conversation {
  final String id;
  final List<String> participantIds;
  final String? title; // For group chats
  final List<Message> messages;
  final DateTime lastMessageTime;

  Conversation({
    required this.id,
    required this.participantIds,
    this.title,
    required this.messages,
    required this.lastMessageTime,
  });

  String get lastMessageText {
    if (messages.isEmpty) return '';
    return messages.last.text;
  }

  bool get hasUnreadMessages {
    return messages.any((message) => !message.isRead);
  }
}

class ChatUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final Color color;

  ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.color,
  });
}

// Providers for messages data
final currentUserIdProvider = Provider<String>((ref) {
  return 'user1'; // In a real app, this would come from auth
});

final usersProvider = Provider<List<ChatUser>>((ref) {
  // In a real app, this would be fetched from Supabase
  return [
    ChatUser(
      id: 'user1',
      name: 'You',
      color: Colors.blue,
    ),
    ChatUser(
      id: 'user2',
      name: 'Sarah',
      color: Colors.pink,
    ),
    ChatUser(
      id: 'user3',
      name: 'Mike',
      color: Colors.green,
    ),
    ChatUser(
      id: 'user4',
      name: 'Emma',
      color: Colors.purple,
    ),
  ];
});

final conversationsProvider = StateNotifierProvider<ConversationsNotifier, List<Conversation>>((ref) {
  return ConversationsNotifier();
});

class ConversationsNotifier extends StateNotifier<List<Conversation>> {
  ConversationsNotifier() : super([
    // Sample data - in real app would come from Supabase
    Conversation(
      id: 'conv1',
      participantIds: ['user1', 'user2'],
      messages: [
        Message(
          id: 'msg1',
          senderId: 'user2',
          text: 'Hey, how are you doing?',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          isRead: true,
        ),
        Message(
          id: 'msg2',
          senderId: 'user1',
          text: 'I\'m good! Just working on the Vuet app.',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
          isRead: true,
        ),
        Message(
          id: 'msg3',
          senderId: 'user2',
          text: 'That sounds great! Can\'t wait to see it.',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: false,
        ),
      ],
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Conversation(
      id: 'conv2',
      participantIds: ['user1', 'user3'],
      messages: [
        Message(
          id: 'msg4',
          senderId: 'user1',
          text: 'Did you finish the shopping list?',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
        ),
        Message(
          id: 'msg5',
          senderId: 'user3',
          text: 'Yes, I got everything we needed.',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
        ),
      ],
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Conversation(
      id: 'conv3',
      participantIds: ['user1', 'user2', 'user3'],
      title: 'Family Chat',
      messages: [
        Message(
          id: 'msg6',
          senderId: 'user1',
          text: 'What time is dinner tonight?',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
        ),
        Message(
          id: 'msg7',
          senderId: 'user2',
          text: 'Around 7pm I think',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
        ),
        Message(
          id: 'msg8',
          senderId: 'user3',
          text: 'I might be a bit late, around 7:30',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
        ),
      ],
      lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ]);

  void sendMessage(String conversationId, String senderId, String text) {
    if (text.isEmpty) return;

    state = state.map((conversation) {
      if (conversation.id == conversationId) {
        final newMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: senderId,
          text: text,
          timestamp: DateTime.now(),
        );
        
        return Conversation(
          id: conversation.id,
          participantIds: conversation.participantIds,
          title: conversation.title,
          messages: [...conversation.messages, newMessage],
          lastMessageTime: DateTime.now(),
        );
      }
      return conversation;
    }).toList();
    
    // Sort conversations by most recent message
    state.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  void markConversationAsRead(String conversationId, String userId) {
    state = state.map((conversation) {
      if (conversation.id == conversationId) {
        final updatedMessages = conversation.messages.map((message) {
          if (message.senderId != userId && !message.isRead) {
            return Message(
              id: message.id,
              senderId: message.senderId,
              text: message.text,
              timestamp: message.timestamp,
              isRead: true,
              imageUrl: message.imageUrl,
            );
          }
          return message;
        }).toList();
        
        return Conversation(
          id: conversation.id,
          participantIds: conversation.participantIds,
          title: conversation.title,
          messages: updatedMessages,
          lastMessageTime: conversation.lastMessageTime,
        );
      }
      return conversation;
    }).toList();
  }

  void createNewConversation(List<String> participantIds, String? title) {
    // Check if conversation already exists (for 1-on-1 chats)
    if (participantIds.length == 2 && title == null) {
      final existingConversation = state.firstWhere(
        (conv) => 
          conv.participantIds.length == 2 && 
          conv.participantIds.contains(participantIds[0]) && 
          conv.participantIds.contains(participantIds[1]),
        orElse: () => Conversation(
          id: '',
          participantIds: [],
          messages: [],
          lastMessageTime: DateTime.now(),
        ),
      );
      
      if (existingConversation.id.isNotEmpty) {
        return; // Conversation already exists
      }
    }
    
    final newConversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      participantIds: participantIds,
      title: title,
      messages: [],
      lastMessageTime: DateTime.now(),
    );
    
    state = [newConversation, ...state];
  }
}

// Selected conversation provider
final selectedConversationIdProvider = StateProvider<String?>((ref) => null);

// Main Messages Screen
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  // Show dialog to start a new conversation
  void _showNewConversationDialog() {
    final users = ref.read(usersProvider);
    final currentUserId = ref.read(currentUserIdProvider);
    final otherUsers = users.where((user) => user.id != currentUserId).toList();
    
    // Track selected users for group chat
    final selectedUserIds = <String>[];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('New Conversation'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select contacts:'),
                  SizedBox(height: 8.h),
                  
                  // Selected users chips
                  if (selectedUserIds.isNotEmpty)
                    Wrap(
                      spacing: 8.w,
                      children: selectedUserIds.map((userId) {
                        final user = users.firstWhere((u) => u.id == userId);
                        return Chip(
                          label: Text(user.name),
                          backgroundColor: user.color.withOpacity(0.2),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              selectedUserIds.remove(userId);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  
                  SizedBox(height: 16.h),
                  
                  // User list
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: otherUsers.length,
                      itemBuilder: (context, index) {
                        final user = otherUsers[index];
                        final isSelected = selectedUserIds.contains(user.id);
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: user.color,
                            child: user.avatarUrl != null
                                ? null
                                : Text(
                                    user.name.substring(0, 1),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                          ),
                          title: Text(user.name),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFD2691E),
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedUserIds.remove(user.id);
                              } else {
                                selectedUserIds.add(user.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: selectedUserIds.isEmpty
                    ? null
                    : () {
                        // Create new conversation
                        final participantIds = [currentUserId, ...selectedUserIds];
                        final title = participantIds.length > 2 ? 'Group Chat' : null;
                        
                        ref.read(conversationsProvider.notifier).createNewConversation(
                              participantIds,
                              title,
                            );
                        
                        Navigator.of(context).pop();
                      },
                child: const Text('Start Chat'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final users = ref.watch(usersProvider);
    final selectedConversationId = ref.watch(selectedConversationIdProvider);
    
    // If a conversation is selected, show the conversation screen
    if (selectedConversationId != null) {
      final conversation = conversations.firstWhere(
        (conv) => conv.id == selectedConversationId,
        orElse: () => Conversation(
          id: '',
          participantIds: [],
          messages: [],
          lastMessageTime: DateTime.now(),
        ),
      );
      
      if (conversation.id.isNotEmpty) {
        return ConversationScreen(
          conversation: conversation,
          onBack: () => ref.read(selectedConversationIdProvider.notifier).state = null,
        );
      }
    }
    
    // Otherwise show the conversations list
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: conversations.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final otherParticipantIds = conversation.participantIds
                    .where((id) => id != currentUserId)
                    .toList();
                
                // Get the other user for 1-on-1 chats, or use the title for group chats
                String displayName;
                Color avatarColor;
                
                if (conversation.title != null) {
                  // Group chat
                  displayName = conversation.title!;
                  avatarColor = Colors.grey;
                } else {
                  // 1-on-1 chat
                  final otherUser = users.firstWhere(
                    (user) => user.id == otherParticipantIds.first,
                    orElse: () => ChatUser(
                      id: '',
                      name: 'Unknown',
                      color: Colors.grey,
                    ),
                  );
                  displayName = otherUser.name;
                  avatarColor = otherUser.color;
                }
                
                // Format timestamp
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final messageDate = DateTime(
                  conversation.lastMessageTime.year,
                  conversation.lastMessageTime.month,
                  conversation.lastMessageTime.day,
                );
                
                String timeString;
                if (messageDate == today) {
                  // Today, show time
                  timeString = DateFormat('HH:mm').format(conversation.lastMessageTime);
                } else if (messageDate == today.subtract(const Duration(days: 1))) {
                  // Yesterday
                  timeString = 'Yesterday';
                } else if (now.difference(messageDate).inDays < 7) {
                  // Within last week, show day name
                  timeString = DateFormat('EEEE').format(conversation.lastMessageTime);
                } else {
                  // Older, show date
                  timeString = DateFormat('dd/MM/yy').format(conversation.lastMessageTime);
                }
                
                return Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    leading: CircleAvatar(
                      backgroundColor: avatarColor,
                      radius: 24.r,
                      child: conversation.title != null
                          ? const Icon(Icons.group, color: Colors.white)
                          : Text(
                              displayName.substring(0, 1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    title: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: conversation.hasUnreadMessages
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      conversation.lastMessageText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: conversation.hasUnreadMessages
                            ? Colors.black87
                            : Colors.grey[600],
                        fontWeight: conversation.hasUnreadMessages
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Time
                        Text(
                          timeString,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // Unread indicator
                        if (conversation.hasUnreadMessages)
                          Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD2691E),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      // Mark as read and navigate to conversation
                      ref.read(conversationsProvider.notifier).markConversationAsRead(
                            conversation.id,
                            currentUserId,
                          );
                      ref.read(selectedConversationIdProvider.notifier).state = conversation.id;
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewConversationDialog,
        backgroundColor: const Color(0xFFD2691E),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No Conversations Yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start chatting with your family members',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _showNewConversationDialog,
            icon: const Icon(Icons.chat),
            label: const Text('New Conversation'),
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
}

// Conversation Screen
class ConversationScreen extends ConsumerStatefulWidget {
  final Conversation conversation;
  final VoidCallback onBack;
  
  const ConversationScreen({
    super.key,
    required this.conversation,
    required this.onBack,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  // Scroll to bottom of chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final users = ref.watch(usersProvider);
    
    // Get conversation title and participants
    String title;
    List<ChatUser> participants = [];
    
    if (widget.conversation.title != null) {
      // Group chat
      title = widget.conversation.title!;
      participants = widget.conversation.participantIds
          .map((id) => users.firstWhere(
                (user) => user.id == id,
                orElse: () => ChatUser(
                  id: id,
                  name: 'Unknown',
                  color: Colors.grey,
                ),
              ))
          .toList();
    } else {
      // 1-on-1 chat
      final otherUserId = widget.conversation.participantIds
          .firstWhere((id) => id != currentUserId);
      final otherUser = users.firstWhere(
        (user) => user.id == otherUserId,
        orElse: () => ChatUser(
          id: otherUserId,
          name: 'Unknown',
          color: Colors.grey,
        ),
      );
      title = otherUser.name;
      participants = [
        users.firstWhere((user) => user.id == currentUserId),
        otherUser,
      ];
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A4A4A),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: widget.conversation.title != null
                  ? Colors.grey
                  : participants.firstWhere((p) => p.id != currentUserId).color,
              radius: 16.r,
              child: widget.conversation.title != null
                  ? const Icon(Icons.group, color: Colors.white, size: 18)
                  : Text(
                      title.substring(0, 1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            SizedBox(width: 12.w),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          // Info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show conversation info
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversation Info',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Participants:',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...participants.map((user) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.color,
                          child: Text(
                            user.name.substring(0, 1),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: user.id == currentUserId
                            ? const Text('You')
                            : null,
                      )),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: widget.conversation.messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.w),
                    itemCount: widget.conversation.messages.length,
                    itemBuilder: (context, index) {
                      final message = widget.conversation.messages[index];
                      final isCurrentUser = message.senderId == currentUserId;
                      final sender = users.firstWhere(
                        (user) => user.id == message.senderId,
                        orElse: () => ChatUser(
                          id: message.senderId,
                          name: 'Unknown',
                          color: Colors.grey,
                        ),
                      );
                      
                      // Check if we need to show date header
                      bool showDateHeader = false;
                      if (index == 0) {
                        showDateHeader = true;
                      } else {
                        final prevMessage = widget.conversation.messages[index - 1];
                        final prevDate = DateTime(
                          prevMessage.timestamp.year,
                          prevMessage.timestamp.month,
                          prevMessage.timestamp.day,
                        );
                        final currentDate = DateTime(
                          message.timestamp.year,
                          message.timestamp.month,
                          message.timestamp.day,
                        );
                        showDateHeader = prevDate != currentDate;
                      }
                      
                      return Column(
                        children: [
                          // Date header if needed
                          if (showDateHeader)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Text(
                                    _formatMessageDate(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          
                          // Message bubble
                          Align(
                            alignment: isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(
                                bottom: 8.h,
                                left: isCurrentUser ? 64.w : 0,
                                right: isCurrentUser ? 0 : 64.w,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? const Color(0xFFD2691E).withOpacity(0.9)
                                    : sender.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16.r).copyWith(
                                  bottomRight: isCurrentUser ? Radius.zero : null,
                                  bottomLeft: !isCurrentUser ? Radius.zero : null,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Sender name (for group chats)
                                  if (!isCurrentUser && widget.conversation.title != null)
                                    Text(
                                      sender.name,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: sender.color,
                                      ),
                                    ),
                                  
                                  // Message text
                                  Text(
                                    message.text,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: isCurrentUser ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  
                                  // Time and read status
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        DateFormat('HH:mm').format(message.timestamp),
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: isCurrentUser
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      if (isCurrentUser) ...[
                                        SizedBox(width: 4.w),
                                        Icon(
                                          message.isRead
                                              ? Icons.done_all
                                              : Icons.done,
                                          size: 12.sp,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          
          // Message input
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: Colors.grey[600],
                  onPressed: () {
                    // Show attachment options
                    Logger.debug('Attachment button pressed');
                  },
                ),
                
                // Message input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                
                SizedBox(width: 8.w),
                
                // Send button
                CircleAvatar(
                  backgroundColor: const Color(0xFFD2691E),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: () {
                      if (_messageController.text.isNotEmpty) {
                        // Send message
                        ref.read(conversationsProvider.notifier).sendMessage(
                              widget.conversation.id,
                              currentUserId,
                              _messageController.text,
                            );
                        _messageController.clear();
                        _scrollToBottom();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Format message date for headers
  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }
}
