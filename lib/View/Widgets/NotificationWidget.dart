import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Model/NotificationModel.dart';
import '../../services/notification_service.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;

  const NotificationWidget({
    Key? key,
    required this.notification,
    this.onTap,
    this.onMarkRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey.shade200 : Color(0xFF7D64FF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: notification.isRead ? Colors.grey.shade300 : Color(0xFF7D64FF),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: notification.senderProfilePicture != null
                        ? CachedNetworkImage(
                            imageUrl: notification.senderProfilePicture!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.person, color: Colors.grey.shade400),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.person, color: Colors.grey.shade400),
                            ),
                          )
                        : Container(
                            color: Color(0xFF7D64FF),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(width: 12),
                
                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Time
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                                fontSize: 14,
                                color: notification.isRead ? Colors.grey.shade700 : Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            notification.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 4),
                      
                      // Message
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: notification.isRead ? Colors.grey.shade600 : Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Action Buttons
                      Row(
                        children: [
                          // Mark as read button
                          if (!notification.isRead)
                            GestureDetector(
                              onTap: onMarkRead,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Color(0xFF7D64FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Color(0xFF7D64FF).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'Mark as read',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF7D64FF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          
                          Spacer(),
                          
                          // Notification type icon
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(notification.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notification.iconName,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'follow':
        return Colors.blue;
      case 'unfollow':
        return Colors.orange;
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.green;
      case 'message':
        return Color(0xFF7D64FF);
      default:
        return Colors.grey;
    }
  }
}

// Notification List Widget
class NotificationListWidget extends StatefulWidget {
  final List<NotificationModel> notifications;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const NotificationListWidget({
    Key? key,
    required this.notifications,
    this.onRefresh,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<NotificationListWidget> createState() => _NotificationListWidgetState();
}

class _NotificationListWidgetState extends State<NotificationListWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7D64FF)),
        ),
      );
    }

    if (widget.notifications.isEmpty) {
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
      onRefresh: () async {
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      },
      color: Color(0xFF7D64FF),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: widget.notifications.length,
        itemBuilder: (context, index) {
          final notification = widget.notifications[index];
          return NotificationWidget(
            notification: notification,
            onTap: () {
              // Handle notification tap based on type
              _handleNotificationTap(notification);
            },
            onMarkRead: () async {
              if (!notification.isRead) {
                final success = await NotificationService.markNotificationRead(notification.id);
                if (success && widget.onRefresh != null) {
                  widget.onRefresh!();
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
          // Navigate to sender's profile
          Get.toNamed('/user-profile', arguments: {'userId': notification.senderId});
        }
        break;
      case 'like':
      case 'comment':
        // Navigate to post
        if (notification.targetId != null) {
          // Navigate to post detail
          Get.toNamed('/post-detail', arguments: {'postId': notification.targetId});
        }
        break;
      case 'message':
        // Navigate to chat
        if (notification.senderId.isNotEmpty) {
          // Navigate to chat with sender
          Get.toNamed('/chat', arguments: {
            'user_id': notification.senderId,
            'username': notification.senderName,
            'full_name': notification.senderName,
            'profile_picture': notification.senderProfilePicture,
          });
        }
        break;
    }
  }
} 