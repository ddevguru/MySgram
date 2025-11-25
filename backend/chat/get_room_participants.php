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
    
    // Get room ID from query parameters
    $room_id = $_GET['room_id'] ?? null;
    if (!$room_id) {
        throw new Exception('Room ID is required');
    }
    
    // Get room participants
    $stmt = $pdo->prepare("
        SELECT 
            p.user_id,
            u.username,
            u.full_name,
            u.profile_picture
        FROM participants p
        JOIN users u ON p.user_id = u.id
        WHERE p.room_id = ?
        ORDER BY p.joined_at ASC
    ");
    
    $stmt->execute([$room_id]);
    $participants = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($participants)) {
        throw new Exception('Room not found or no participants');
    }
    
    // Format participants data
    $formatted_participants = [];
    foreach ($participants as $participant) {
        $formatted_participants[] = [
            'user_id' => $participant['user_id'],
            'username' => $participant['username'],
            'full_name' => $participant['full_name'],
            'profile_picture' => $participant['profile_picture']
        ];
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Room participants retrieved successfully',
        'participants' => $formatted_participants,
        'total_participants' => count($formatted_participants)
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 