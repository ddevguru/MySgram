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
    
    // Mark all notifications as read for current user
    $stmt = $pdo->prepare("
        UPDATE notifications 
        SET is_read = TRUE 
        WHERE recipient_id = ? AND is_read = FALSE
    ");
    
    $stmt->execute([$current_user_id]);
    $updated_count = $stmt->rowCount();
    
    echo json_encode([
        'success' => true,
        'message' => "Marked $updated_count notifications as read"
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 