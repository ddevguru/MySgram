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
    
    $userId = $payload['user_id'];
    
    // Get query parameters
    $roomId = $_GET['room_id'] ?? '';
    $limit = intval($_GET['limit'] ?? 50);
    $offset = intval($_GET['offset'] ?? 0);
    
    // Validation
    if (empty($roomId)) {
        throw new Exception('Room ID is required');
    }
    
    if ($limit > 100) {
        $limit = 100; // Max limit
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
    
    // Get messages - order by timestamp ASC (oldest first, newest last)
    // This way oldest messages appear at top and newest at bottom in chat
    $stmt = $pdo->prepare("
        SELECT m.*, u.username, u.profile_picture, u.full_name
        FROM messages m
        JOIN users u ON m.sender_id = u.id
        WHERE m.room_id = ?
        ORDER BY m.timestamp ASC
        LIMIT $limit OFFSET $offset
    ");
    
    $stmt->execute([$roomId]);
    $messages = $stmt->fetchAll();
    
    // Format messages - keep in ASC order (oldest first, newest last)
    $formattedMessages = [];
    foreach ($messages as $msg) {
        $formattedMessages[] = [
            'id' => $msg['message_id'],
            'room_id' => $msg['room_id'],
            'sender_id' => $msg['sender_id'],
            'message' => $msg['message'],
            'reply_to' => $msg['reply_to'],
            'type' => $msg['message_type'] ?? 'text',
            'metadata' => json_decode($msg['metadata'] ?? '{}', true),
            'timestamp' => $msg['timestamp'],
            'sender_name' => $msg['full_name'] ?? $msg['username'],
            'sender_photo' => $msg['profile_picture'],
            'is_seen' => $msg['is_seen'] ?? false,
            'seen_at' => $msg['seen_at'] ?? null
        ];
    }
    
    // Don't reverse - keep messages in chronological order (oldest first, newest last)
    
    echo json_encode([
        'success' => true,
        'message' => 'Messages retrieved successfully',
        'messages' => $formattedMessages,
        'count' => count($formattedMessages)
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 