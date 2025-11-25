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
    
    // Get users that current user follows OR who follow current user
    $stmt = $pdo->prepare("
        SELECT DISTINCT
            u.id,
            u.username,
            u.full_name,
            u.profile_picture,
            u.created_at,
            CASE 
                WHEN f1.follower_id IS NOT NULL THEN 'following'
                WHEN f2.following_id IS NOT NULL THEN 'follower'
                ELSE 'none'
            END as relationship_type,
            CASE 
                WHEN f1.follower_id IS NOT NULL THEN 1
                ELSE 0
            END as is_following,
            CASE 
                WHEN f2.following_id IS NOT NULL THEN 1
                ELSE 0
            END as is_followed_by
        FROM users u
        LEFT JOIN follows f1 ON f1.following_id = u.id AND f1.follower_id = ?
        LEFT JOIN follows f2 ON f2.follower_id = u.id AND f2.following_id = ?
        WHERE u.id != ? 
        AND (f1.follower_id IS NOT NULL OR f2.following_id IS NOT NULL)
        ORDER BY 
            CASE 
                WHEN f1.follower_id IS NOT NULL AND f2.following_id IS NOT NULL THEN 1
                WHEN f1.follower_id IS NOT NULL THEN 2
                ELSE 3
            END,
            u.username ASC
    ");
    
    $stmt->execute([$currentUserId, $currentUserId, $currentUserId]);
    
    // Debug: Log the query and results
    error_log("Follow users query for user ID: $currentUserId");
    error_log("SQL: " . $stmt->queryString);
    error_log("Parameters: " . json_encode([$currentUserId, $currentUserId, $currentUserId]));
    $users = $stmt->fetchAll();
    
    // Debug: Log the raw results
    error_log("Raw users found: " . count($users));
    error_log("Raw users data: " . json_encode($users));
    
    // Format users for response
    $formattedUsers = [];
    foreach ($users as $user) {
        $formattedUsers[] = [
            'id' => $user['id'],
            'username' => $user['username'],
            'full_name' => $user['full_name'],
            'profile_picture' => $user['profile_picture'],
            'created_at' => $user['created_at'],
            'relationship_type' => $user['relationship_type'],
            'is_following' => boolval($user['is_following']),
            'is_followed_by' => boolval($user['is_followed_by']),
            'can_chat' => true, // All follow users can chat
            'display_name' => $user['full_name'] ?: $user['username']
        ];
    }
    
    // Debug: Log the formatted results
    error_log("Formatted users: " . count($formattedUsers));
    error_log("Final response: " . json_encode($formattedUsers));
    
    echo json_encode([
        'success' => true,
        'message' => 'Follow users retrieved successfully',
        'users' => $formattedUsers,
        'count' => count($formattedUsers)
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 