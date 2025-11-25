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
    
    $messageId = $input['message_id'] ?? '';
    
    // Validation
    if (empty($messageId)) {
        throw new Exception('Message ID is required');
    }
    
    // Check if message exists and user is the recipient
    $stmt = $pdo->prepare("
        SELECT m.*, cr.user_id_1, cr.user_id_2 
        FROM messages m
        JOIN chat_rooms cr ON m.room_id = cr.room_id
        WHERE m.message_id = ?
    ");
    $stmt->execute([$messageId]);
    $message = $stmt->fetch();
    
    if (!$message) {
        throw new Exception('Message not found');
    }
    
    // Check if user is the recipient (not the sender)
    if ($message['sender_id'] == $userId) {
        throw new Exception('Cannot mark own message as seen');
    }
    
    // Check if user has access to this chat room
    if ($message['user_id_1'] != $userId && $message['user_id_2'] != $userId) {
        throw new Exception('Access denied to this message');
    }
    
    // Mark message as seen
    $stmt = $pdo->prepare("
        UPDATE messages 
        SET is_seen = 1, seen_at = NOW() 
        WHERE message_id = ?
    ");
    
    if ($stmt->execute([$messageId])) {
        echo json_encode([
            'success' => true,
            'message' => 'Message marked as seen successfully',
            'message_id' => $messageId,
            'seen_at' => date('Y-m-d H:i:s')
        ]);
    } else {
        throw new Exception('Failed to mark message as seen');
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 