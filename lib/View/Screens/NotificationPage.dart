import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/notification_service.dart';
import '../Widgets/NotificationWidget.dart';
import '../../Model/NotificationModel.dart';
import 'NotificationTestPage.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final notificationsList = await NotificationService.getNotifications();
      
      setState(() {
        notifications = notificationsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('❌ Error loading notifications: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final success = await NotificationService.markAllNotificationsRead();
      if (success) {
        // Refresh notifications to update read status
        _loadNotifications();
        Get.snackbar(
          'Success',
          'All notifications marked as read',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to mark notifications as read',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      Get.snackbar(
        'Error',
        'Failed to mark notifications as read: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF7D64FF),
        elevation: 0,
        actions: [
          // Mark all as read button
          if (notifications.any((n) => !n.isRead))
            IconButton(
              icon: Icon(Icons.done_all, color: Colors.black),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
            ),
          
          // Test button
          IconButton(
            icon: Icon(Icons.bug_report, color: Colors.black),
            tooltip: 'Test Notifications',
            onPressed: () {
              Get.to(() => NotificationTestPage());
            },
          ),
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            tooltip: 'Refresh',
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with stats
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF7D64FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Total notifications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Notifications',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${notifications.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    // Unread count
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Unread',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${notifications.where((n) => !n.isRead).length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Notification type filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', null, notifications.length),
                      _buildFilterChip('Follow', 'follow', notifications.where((n) => n.type == 'follow').length),
                      _buildFilterChip('Likes', 'like', notifications.where((n) => n.type == 'like').length),
                      _buildFilterChip('Comments', 'comment', notifications.where((n) => n.type == 'comment').length),
                      _buildFilterChip('Messages', 'message', notifications.where((n) => n.type == 'message').length),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Notifications list
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? type, int count) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: false,
        onSelected: (selected) {
          // TODO: Implement filtering by type
          print('Filter by type: $type');
        },
        backgroundColor: Colors.white.withOpacity(0.2),
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        checkmarkColor: Color(0xFF7D64FF),
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7D64FF)),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            SizedBox(height: 16),
            Text(
              'Error loading notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7D64FF),
                foregroundColor: Colors.white,
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You\'ll see notifications here when people interact with your content',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: Color(0xFF7D64FF),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationWidget(
            notification: notification,
            onTap: () {
              _handleNotificationTap(notification);
            },
            onMarkRead: () async {
              if (!notification.isRead) {
                final success = await NotificationService.markNotificationRead(notification.id);
                if (success) {
                  // Refresh notifications to update read status
                  _loadNotifications();
                }
              }
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle different notification types
    switch (notification.type) {
      case 'follow':
      case 'unfollow':
        // Navigate to user profile
        if (notification.senderId.isNotEmpty) {
          // TODO: Navigate to sender's profile
          print('Navigate to user profile: ${notification.senderId}');
        }
        break;
      case 'like':
      case 'comment':
        // Navigate to post
        if (notification.targetId != null) {
          // TODO: Navigate to post detail
          print('Navigate to post: ${notification.targetId}');
        }
        break;
      case 'message':
        // Navigate to chat
        if (notification.senderId.isNotEmpty) {
          // TODO: Navigate to chat with sender
          print('Navigate to chat with: ${notification.senderId}');
        }
        break;
    }
  }
} 