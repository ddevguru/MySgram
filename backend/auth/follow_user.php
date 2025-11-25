<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';
require_once '../utils/JWT.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
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
    
    // Debug logging
    error_log("Follow request - Current user ID: " . $currentUserId);
    
    // Get request body
    $rawInput = file_get_contents('php://input');
    $input = json_decode($rawInput, true);
    
    // Debug logging
    error_log("Follow request - Raw input: " . $rawInput);
    error_log("Follow request - Parsed input: " . print_r($input, true));
    
    // Support both parameter names for backward compatibility
    $targetUserId = $input['target_user_id'] ?? $input['following_id'] ?? null;
    $action = $input['action'] ?? 'follow'; // 'follow' or 'unfollow'
    
    error_log("Follow request - Target user ID: " . ($targetUserId ?? 'NULL'));
    error_log("Follow request - Action: " . $action);
    error_log("Follow request - Parameter source: " . (isset($input['target_user_id']) ? 'target_user_id' : (isset($input['following_id']) ? 'following_id' : 'none')));
    
    if (!$targetUserId) {
        error_log("Follow request failed - target_user_id/following_id missing");
        error_log("Available keys: " . implode(', ', array_keys($input ?? [])));
        throw new Exception('Target user ID is required. Received: ' . json_encode($input));
    }
    
    if ($currentUserId == $targetUserId) {
        throw new Exception('Cannot follow yourself');
    }
    
    // Check if user exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE id = ?");
    $stmt->execute([$targetUserId]);
    if (!$stmt->fetch()) {
        throw new Exception('Target user not found');
    }
    
    if ($action === 'follow') {
        // Check if already following
        $stmt = $pdo->prepare("SELECT id FROM follows WHERE follower_id = ? AND following_id = ?");
        $stmt->execute([$currentUserId, $targetUserId]);
        
        if ($stmt->fetch()) {
            throw new Exception('Already following this user');
        }
        
        // Add follow relationship
        $stmt = $pdo->prepare("INSERT INTO follows (follower_id, following_id, created_at) VALUES (?, ?, NOW())");
        $stmt->execute([$currentUserId, $targetUserId]);
        
        // Create notification for the user being followed
        try {
            $notification_query = "INSERT INTO notifications (recipient_id, sender_id, type, message) VALUES (?, ?, 'follow', 'started following you')";
            $notification_stmt = $pdo->prepare($notification_query);
            $notification_stmt->bindParam(1, $targetUserId);
            $notification_stmt->bindParam(2, $currentUserId);
            $notification_stmt->execute();
        } catch (Exception $e) {
            error_log("Failed to create follow notification: " . $e->getMessage());
        }
        
        // Update follower counts
        $stmt = $pdo->prepare("UPDATE users SET followers_count = followers_count + 1 WHERE id = ?");
        $stmt->execute([$targetUserId]);
        
        $stmt = $pdo->prepare("UPDATE users SET following_count = following_count + 1 WHERE id = ?");
        $stmt->execute([$currentUserId]);
        
        $message = 'Successfully followed user';
        
    } else if ($action === 'unfollow') {
        // Check if following
        $stmt = $pdo->prepare("SELECT id FROM follows WHERE follower_id = ? AND following_id = ?");
        $stmt->execute([$currentUserId, $targetUserId]);
        
        if (!$stmt->fetch()) {
            throw new Exception('Not following this user');
        }
        
        // Remove follow relationship
        $stmt = $pdo->prepare("DELETE FROM follows WHERE follower_id = ? AND following_id = ?");
        $stmt->execute([$currentUserId, $targetUserId]);
        
        // Update follower counts
        $stmt = $pdo->prepare("UPDATE users SET followers_count = GREATEST(followers_count - 1, 0) WHERE id = ?");
        $stmt->execute([$targetUserId]);
        
        $stmt = $pdo->prepare("UPDATE users SET following_count = GREATEST(following_count - 1, 0) WHERE id = ?");
        $stmt->execute([$currentUserId]);
        
        $message = 'Successfully unfollowed user';
    }
    
    // Get current follow status after action
    $stmt = $pdo->prepare("SELECT id FROM follows WHERE follower_id = ? AND following_id = ?");
    $stmt->execute([$currentUserId, $targetUserId]);
    $isFollowing = $stmt->fetch() ? true : false;
    
    // Debug logging
    error_log("Follow action completed - Action: $action, Is following: " . ($isFollowing ? 'true' : 'false'));
    
    $response = [
        'success' => true,
        'message' => $message,
        'action' => $action,
        'target_user_id' => $targetUserId,
        'is_following' => $isFollowing
    ];
    
    error_log("Sending response: " . json_encode($response));
    echo json_encode($response);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 