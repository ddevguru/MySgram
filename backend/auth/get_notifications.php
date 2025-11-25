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

try {
    // Get authorization header
    $headers = getallheaders();
    $auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';
    
    if (empty($auth_header) || !str_starts_with($auth_header, 'Bearer ')) {
        throw new Exception('Authorization header missing or invalid');
    }
    
    $token = substr($auth_header, 7);
    
    // Verify JWT token
    $jwt = new JWT();
    $decoded = $jwt->verify($token);
    
    if (!$decoded || !isset($decoded['user_id'])) {
        throw new Exception('Invalid or expired token');
    }
    
    $current_user_id = $decoded['user_id'];
    
    // Check if notifications table exists, create if not
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS notifications (
            id INT AUTO_INCREMENT PRIMARY KEY,
            recipient_id INT NOT NULL,
            sender_id INT NOT NULL,
            type ENUM('follow', 'like', 'comment', 'follow_request', 'mention', 'message', 'unfollow', 'unlike', 'post', 'story') NOT NULL,
            post_id INT NULL,
            comment_id INT NULL,
            message TEXT,
            is_read BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
            INDEX idx_recipient_id (recipient_id),
            INDEX idx_sender_id (sender_id),
            INDEX idx_type (type),
            INDEX idx_is_read (is_read),
            INDEX idx_created_at (created_at)
        )
    ");
    
    // Get notifications for current user with sender information
    $stmt = $pdo->prepare("
        SELECT 
            n.id,
            n.type,
            n.post_id,
            n.comment_id,
            n.message,
            n.is_read,
            n.created_at,
            s.id as sender_id,
            s.username as sender_username,
            s.full_name as sender_full_name,
            s.profile_picture as sender_profile_picture
        FROM notifications n
        INNER JOIN users s ON n.sender_id = s.id
        WHERE n.recipient_id = ?
        ORDER BY n.created_at DESC
        LIMIT 50
    ");
    
    $stmt->execute([$current_user_id]);
    $notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format notifications for frontend
    $formatted_notifications = [];
    foreach ($notifications as $notif) {
        // Generate title and message based on type
        $title = '';
        $message = '';
        
        switch ($notif['type']) {
            case 'follow':
                $title = 'New Follower';
                $message = $notif['sender_full_name'] ?: $notif['sender_username'];
                $message .= ' started following you';
                break;
            case 'unfollow':
                $title = 'Follower Removed';
                $message = $notif['sender_full_name'] ?: $notif['sender_username'];
                $message .= ' unfollowed you';
                break;
            case 'like':
                $title = 'New Like';
                $message = $notif['sender_full_name'] ?: $notif['sender_username'];
                $message .= ' liked your post';
                break;
            case 'unlike':
                $title = 'Like Removed';
                $message = $notif['sender_full_name'] ?: $notif['sender_username'];
                $message .= ' unliked your post';
                break;
            case 'comment':
                $title = 'New Comment';
                $message = $notif['sender_full_name'] ?: $notif['sender_username'];
                $message .= ' commented: ' . ($notif['message'] ?: 'on your post');
                break;
            case 'message':
                $title = 'New Message';
                $message = $notif['sender_full_name'] ?: $notif['sender_username'];
                $message .= ' sent you a message';
                break;
            default:
                $title = 'New Activity';
                $message = $notif['sender_full_name'] ?: $notif['sender_username'];
                $message .= ' performed an action';
        }
        
        $formatted_notifications[] = [
            'id' => $notif['id'],
            'type' => $notif['type'],
            'title' => $title,
            'message' => $message,
            'image_url' => $notif['sender_profile_picture'],
            'target_id' => $notif['post_id'] ? $notif['post_id'] : null,
            'sender_id' => $notif['sender_id'],
            'sender_name' => $notif['sender_full_name'] ?: $notif['sender_username'],
            'sender_profile_picture' => $notif['sender_profile_picture'],
            'timestamp' => $notif['created_at'],
            'is_read' => (bool)$notif['is_read'],
            'metadata' => [
                'post_id' => $notif['post_id'],
                'comment_id' => $notif['comment_id']
            ]
        ];
    }
    
    echo json_encode([
        'success' => true,
        'notifications' => $formatted_notifications,
        'count' => count($formatted_notifications)
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 