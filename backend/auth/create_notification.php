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

try {
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Invalid JSON input');
    }
    
    // Validate required fields
    $required_fields = ['type', 'recipient_id', 'sender_id'];
    foreach ($required_fields as $field) {
        if (empty($input[$field])) {
            throw new Exception("Missing required field: $field");
        }
    }
    
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
    
    // Verify sender is the current user
    if ($current_user_id != $input['sender_id']) {
        throw new Exception('Unauthorized: Can only send notifications as yourself');
    }
    
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
    
    // Determine post_id and comment_id based on type and target_id
    $post_id = null;
    $comment_id = null;
    $notification_message = '';
    
    switch ($input['type']) {
        case 'like':
        case 'unlike':
        case 'comment':
        case 'post':
        case 'story':
            $post_id = isset($input['target_id']) ? intval($input['target_id']) : null;
            $notification_message = $input['message'] ?? '';
            break;
        case 'follow':
        case 'unfollow':
            $notification_message = $input['message'] ?? '';
            break;
        case 'message':
            $notification_message = $input['message'] ?? '';
            break;
        default:
            $notification_message = $input['message'] ?? '';
    }
    
    // Insert notification
    $stmt = $pdo->prepare("
        INSERT INTO notifications (
            recipient_id, sender_id, type, post_id, comment_id, message
        ) VALUES (?, ?, ?, ?, ?, ?)
    ");
    
    $stmt->execute([
        intval($input['recipient_id']),
        intval($input['sender_id']),
        $input['type'],
        $post_id,
        $comment_id,
        $notification_message
    ]);
    
    $notification_id = $pdo->lastInsertId();
    
    echo json_encode([
        'success' => true,
        'message' => 'Notification created successfully',
        'notification_id' => $notification_id
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 