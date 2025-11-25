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
    
    $userId1 = $payload['user_id'];
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Invalid JSON input');
    }
    
    $userId2 = $input['user_id_2'] ?? '';
    
    // Validation
    if (empty($userId2)) {
        throw new Exception('User ID 2 is required');
    }
    
    if ($userId1 == $userId2) {
        throw new Exception('Cannot create chat room with yourself');
    }
    
    // Check if room already exists
    $stmt = $pdo->prepare("
        SELECT room_id FROM chat_rooms 
        WHERE (user_id_1 = ? AND user_id_2 = ?) OR (user_id_1 = ? AND user_id_2 = ?)
    ");
    $stmt->execute([$userId1, $userId2, $userId2, $userId1]);
    $existingRoom = $stmt->fetch();
    
    if ($existingRoom) {
        echo json_encode([
            'success' => true,
            'message' => 'Chat room already exists',
            'room_id' => $existingRoom['room_id']
        ]);
        exit;
    }
    
    // Generate unique room ID
    $roomId = uniqid('room_', true);
    
    // Create new room
    $stmt = $pdo->prepare("
        INSERT INTO chat_rooms (room_id, user_id_1, user_id_2, created_at) 
        VALUES (?, ?, ?, NOW())
    ");
    
    $stmt->execute([$roomId, $userId1, $userId2]);
    
    echo json_encode([
        'success' => true,
        'message' => 'Chat room created successfully',
        'room_id' => $roomId
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 