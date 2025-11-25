<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';
require_once '../utils/JWT.php';

try {
    // Get authorization header
    $headers = getallheaders();
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';
    
    if (empty($authHeader) || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
        http_response_code(401);
        echo json_encode(['error' => 'No token provided']);
        exit;
    }
    
    $token = $matches[1];
    
    // Verify token
    $decoded = JWT::verify($token);
    if (!$decoded) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid token']);
        exit;
    }
    
    $currentUserId = $decoded['user_id'];
    $targetUserId = isset($_GET['user_id']) ? $_GET['user_id'] : '';
    
    if (empty($targetUserId)) {
        http_response_code(400);
        echo json_encode(['error' => 'User ID is required']);
        exit;
    }
    
    // Get user profile information
    $userQuery = "
        SELECT 
            u.*,
            (SELECT COUNT(*) FROM posts WHERE user_id = u.id) as total_posts
        FROM users u
        WHERE u.id = ?
    ";
    
    $userStmt = $pdo->prepare($userQuery);
    $userStmt->execute([$targetUserId]);
    $user = $userStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        http_response_code(404);
        echo json_encode(['error' => 'User not found']);
        exit;
    }
    
    // Check if current user can see posts
    $canSeePosts = false;
    if ($currentUserId == $targetUserId) {
        // Own profile - can see all posts
        $canSeePosts = true;
    } elseif ($user['is_private'] == '0') {
        // Public account - can see public posts
        $canSeePosts = true;
    } else {
        // Private account - for now, assume not following
        $canSeePosts = false;
    }
    
    // Get user posts if allowed
    $posts = [];
    if ($canSeePosts) {
        $postsQuery = "
            SELECT 
                p.*,
                (SELECT COUNT(*) FROM likes WHERE post_id = p.id) as likes_count,
                (SELECT COUNT(*) FROM comments WHERE post_id = p.id) as comments_count
            FROM posts p
            WHERE p.user_id = ?
            ORDER BY p.created_at DESC
        ";
        
        $postsStmt = $pdo->prepare($postsQuery);
        $postsStmt->execute([$targetUserId]);
        $posts = $postsStmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    // Check if current user is following the target user
    $isFollowing = false;
    if ($currentUserId != $targetUserId) {
        $followQuery = "SELECT id FROM follows WHERE follower_id = ? AND following_id = ?";
        $followStmt = $pdo->prepare($followQuery);
        $followStmt->execute([$currentUserId, $targetUserId]);
        $isFollowing = $followStmt->rowCount() > 0;
    }
    
    // Get follower and following counts
    $followersQuery = "SELECT COUNT(*) as count FROM follows WHERE following_id = ?";
    $followersStmt = $pdo->prepare($followersQuery);
    $followersStmt->execute([$targetUserId]);
    $followersCount = $followersStmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    $followingQuery = "SELECT COUNT(*) as count FROM follows WHERE follower_id = ?";
    $followingStmt = $pdo->prepare($followingQuery);
    $followingStmt->execute([$targetUserId]);
    $followingCount = $followingStmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // Format user data
    $formattedUser = [
        'user_id' => $user['id'],
        'username' => $user['username'],
        'full_name' => $user['full_name'],
        'profile_picture' => $user['profile_picture'],
        'bio' => $user['bio'],
        'website' => $user['website'],
        'location' => $user['location'],
        'is_private' => $user['is_private'] == '1',
        'total_posts' => (int)$user['total_posts'],
        'followers_count' => (int)$followersCount,
        'following_count' => (int)$followingCount,
        'is_following' => $isFollowing,
        'can_see_posts' => $canSeePosts
    ];
    
    // Format posts data
    $formattedPosts = [];
    foreach ($posts as $post) {
        $formattedPosts[] = [
            'id' => $post['id'],
            'media_url' => $post['media_url'],
            'media_type' => $post['media_type'],
            'caption' => $post['caption'],
            'likes_count' => (int)$post['likes_count'],
            'comments_count' => (int)$post['comments_count'],
            'created_at' => $post['created_at']
        ];
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'User profile retrieved successfully',
        'user' => $formattedUser,
        'posts' => $formattedPosts
    ]);
    
} catch (Exception $e) {
    error_log("Error in get_user_profile.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'error' => 'Internal server error',
        'message' => $e->getMessage()
    ]);
}
?> 