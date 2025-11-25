class NotificationModel {
  final String id;
  final String type; // 'follow', 'unfollow', 'like', 'unlike', 'comment', 'message'
  final String title;
  final String message;
  final String? imageUrl;
  final String? targetId; // ID of the post, comment, or user being acted upon
  final String senderId;
  final String senderName;
  final String? senderProfilePicture;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata; // Additional data for specific notification types

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.imageUrl,
    this.targetId,
    required this.senderId,
    required this.senderName,
    this.senderProfilePicture,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      imageUrl: json['image_url'],
      targetId: json['target_id'],
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'] ?? '',
      senderProfilePicture: json['sender_profile_picture'],
      timestamp: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'image_url': imageUrl,
      'target_id': targetId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_profile_picture': senderProfilePicture,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'metadata': metadata,
    };
  }

  // Helper methods for different notification types
  bool get isFollowNotification => type == 'follow';
  bool get isUnfollowNotification => type == 'unfollow';
  bool get isLikeNotification => type == 'like';
  bool get isUnlikeNotification => type == 'unlike';
  bool get isCommentNotification => type == 'comment';
  bool get isMessageNotification => type == 'message';

  // Get appropriate icon for notification type
  String get iconName {
    switch (type) {
      case 'follow':
        return '👥';
      case 'unfollow':
        return '👋';
      case 'like':
        return '❤️';
      case 'unlike':
        return '💔';
      case 'comment':
        return '💬';
      case 'message':
        return '💌';
      default:
        return '🔔';
    }
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
} 