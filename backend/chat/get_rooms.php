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
    
    // Get chat rooms for the user
    $stmt = $pdo->prepare("
        SELECT 
            cr.room_id,
            cr.created_at,
            cr.updated_at,
            cr.last_message,
            cr.unread_count,
            CASE 
                WHEN cr.user_id_1 = ? THEN cr.user_id_2
                ELSE cr.user_id_1
            END as other_user_id,
            u.username as other_username,
            u.profile_picture as other_profile_picture,
            COALESCE(u.is_online, FALSE) as other_online,
            COALESCE(u.last_seen, NOW()) as other_last_seen
        FROM chat_rooms cr
        JOIN users u ON (
            CASE 
                WHEN cr.user_id_1 = ? THEN cr.user_id_2
                ELSE cr.user_id_1
            END = u.id
        )
        WHERE cr.user_id_1 = ? OR cr.user_id_2 = ?
        ORDER BY cr.updated_at DESC
    ");
    
    $stmt->execute([$userId, $userId, $userId, $userId]);
    $rooms = $stmt->fetchAll();
    
    // Format rooms
    $formattedRooms = [];
    foreach ($rooms as $room) {
        $formattedRooms[] = [
            'id' => $room['room_id'],
            'participants' => [$userId, $room['other_user_id']],
            'last_message' => $room['last_message'] ? [
                'message' => $room['last_message'],
                'sender_id' => $userId, // This will be updated when we get actual last message
                'timestamp' => $room['updated_at']
            ] : null,
            'unread_count' => intval($room['unread_count']),
            'created_at' => $room['created_at'],
            'updated_at' => $room['updated_at'],
            'other_user' => [
                'id' => $room['other_user_id'],
                'username' => $room['other_username'],
                'profile_picture' => $room['other_profile_picture'],
                'is_online' => boolval($room['other_online']),
                'last_seen' => $room['other_last_seen']
            ]
        ];
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Chat rooms retrieved successfully',
        'rooms' => $formattedRooms,
        'count' => count($formattedRooms)
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 