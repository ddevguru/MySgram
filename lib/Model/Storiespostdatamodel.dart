// Story Model
class StoryModel {
  final String id;
  final String username;
  final String profileImage;
  final bool hasStory;
  final int storyCount;
  final List<dynamic> allStories;
  final bool hasUnviewedStory; // New field to track view status

  StoryModel({
    required this.id,
    required this.username,
    required this.profileImage,
    required this.hasStory,
    this.storyCount = 1,
    this.allStories = const [],
    this.hasUnviewedStory = true, // Default to true (unviewed)
  });
}

// Post Model
class PostModel {
  final String postId;
  final String? userId; // Make userId nullable
  final String username;
  final String profileImage;
  final String postImage;
  final String likes;
  final String caption;
  final String timeAgo;
  final bool isLiked;
  final String commentCount;

  PostModel({
    required this.postId,
    this.userId, // Make userId optional
    required this.username,
    required this.profileImage,
    required this.postImage,
    required this.likes,
    required this.caption,
    required this.timeAgo,
    this.isLiked = false,
    this.commentCount = "0",
  });

  @override
  String toString() {
    return 'PostModel{postId: $postId, userId: $userId, username: $username}';
  }
}
