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
    
    // Validation
    if (empty($roomId)) {
        throw new Exception('Room ID is required');
    }
    
    // Check if user has access to this chat room
    $stmt = $pdo->prepare("
        SELECT id FROM chat_rooms 
        WHERE room_id = ? AND (user_id_1 = ? OR user_id_2 = ?)
    ");
    $stmt->execute([$roomId, $userId, $userId]);
    
    if (!$stmt->fetch()) {
        throw new Exception('Access denied to this chat room');
    }
    
    // Mark all unread messages as seen (only messages from other users)
    $stmt = $pdo->prepare("
        UPDATE messages 
        SET is_seen = 1, seen_at = NOW() 
        WHERE room_id = ? AND sender_id != ? AND is_seen = 0
    ");
    
    if ($stmt->execute([$roomId, $userId])) {
        $affectedRows = $stmt->rowCount();
        echo json_encode([
            'success' => true,
            'message' => 'All messages marked as seen successfully',
            'room_id' => $roomId,
            'messages_updated' => $affectedRows,
            'updated_at' => date('Y-m-d H:i:s')
        ]);
    } else {
        throw new Exception('Failed to mark messages as seen');
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 