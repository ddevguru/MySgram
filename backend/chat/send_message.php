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
    
    $userId = $payload['user_id'];
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Invalid JSON input');
    }
    
    $roomId = $input['room_id'] ?? '';
    $message = trim($input['message'] ?? '');
    $replyTo = $input['reply_to'] ?? null;
    
    // Validation
    if (empty($roomId) || empty($message)) {
        throw new Exception('Room ID and message are required');
    }
    
    if (strlen($message) > 1000) {
        throw new Exception('Message too long (max 1000 characters)');
    }
    
    // Check if user has access to this room
    $stmt = $pdo->prepare("
        SELECT id FROM chat_rooms 
        WHERE room_id = ? AND (user_id_1 = ? OR user_id_2 = ?)
    ");
    $stmt->execute([$roomId, $userId, $userId]);
    
    if (!$stmt->fetch()) {
        throw new Exception('Access denied to this chat room');
    }
    
    // Generate unique message ID
    $messageId = uniqid('msg_', true);
    
    // Insert message
    $stmt = $pdo->prepare("
        INSERT INTO messages (message_id, room_id, sender_id, message, reply_to, timestamp) 
        VALUES (?, ?, ?, ?, ?, NOW())
    ");
    
    $stmt->execute([$messageId, $roomId, $userId, $message, $replyTo]);
    
    // Update chat room last message
    $stmt = $pdo->prepare("
        UPDATE chat_rooms 
        SET last_message = ?, updated_at = NOW() 
        WHERE room_id = ?
    ");
    $stmt->execute([$message, $roomId]);
    
    // Get recipient ID for notification
    $stmt = $pdo->prepare("
        SELECT 
            CASE 
                WHEN user_id_1 = ? THEN user_id_2 
                ELSE user_id_1 
            END as recipient_id
        FROM chat_rooms 
        WHERE room_id = ?
    ");
    $stmt->execute([$userId, $roomId]);
    $recipient = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Create notification for recipient if they're not the sender
    if ($recipient && $recipient['recipient_id'] != $userId) {
        try {
            $notification_query = "INSERT INTO notifications (recipient_id, sender_id, type, message) VALUES (?, ?, 'message', ?)";
            $notification_stmt = $pdo->prepare($notification_query);
            $notification_stmt->bindParam(1, $recipient['recipient_id']);
            $notification_stmt->bindParam(2, $userId);
            $notification_stmt->bindParam(3, $message);
            $notification_stmt->execute();
        } catch (Exception $e) {
            error_log("Failed to create message notification: " . $e->getMessage());
        }
    }
    
    // Get sender info
    $stmt = $pdo->prepare("
        SELECT username, profile_picture FROM users WHERE id = ?
    ");
    $stmt->execute([$userId]);
    $sender = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'message' => 'Message sent successfully',
        'message_id' => $messageId,
        'timestamp' => date('Y-m-d H:i:s'),
        'sender_info' => $sender
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 