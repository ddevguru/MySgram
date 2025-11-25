<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';
require_once '../utils/JWT.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

try {
    // Get authorization header
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? '';
    
    if (empty($authHeader) || !str_starts_with($authHeader, 'Bearer ')) {
        throw new Exception('Authorization token required');
    }
    
    $token = substr($authHeader, 7);
    
    // Verify JWT token
    $jwt = new JWT();
    $payload = $jwt->verify($token);
    
    if (!$payload) {
        throw new Exception('Invalid token');
    }
    
    $currentUserId = $payload['user_id'];
    
    // Get target user ID from query parameter
    $targetUserId = $_GET['user_id'] ?? null;
    
    if (!$targetUserId) {
        throw new Exception('Target user ID is required');
    }
    
    // Get users that the target user follows
    $stmt = $pdo->prepare("
        SELECT 
            u.id,
            u.username,
            u.full_name,
            u.profile_picture,
            u.created_at,
            CASE 
                WHEN f.follower_id IS NOT NULL THEN 1
                ELSE 0
            END as is_following
        FROM users u
        INNER JOIN follows f ON f.following_id = u.id AND f.follower_id = ?
        LEFT JOIN follows current_follow ON current_follow.following_id = u.id AND current_follow.follower_id = ?
        ORDER BY u.username ASC
    ");
    
    $stmt->execute([$targetUserId, $currentUserId]);
    $following = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format following for response
    $formattedFollowing = [];
    foreach ($following as $followedUser) {
        $formattedFollowing[] = [
            'id' => $followedUser['id'],
            'username' => $followedUser['username'],
            'full_name' => $followedUser['full_name'],
            'profile_picture' => $followedUser['profile_picture'],
            'created_at' => $followedUser['created_at'],
            'is_following' => boolval($followedUser['is_following']),
            'can_message' => true // All following users can message
        ];
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Following users retrieved successfully',
        'following' => $formattedFollowing,
        'count' => count($formattedFollowing)
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 