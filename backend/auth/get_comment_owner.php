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
    
    // Get comment ID from query parameters
    $comment_id = $_GET['comment_id'] ?? null;
    if (!$comment_id) {
        throw new Exception('Comment ID is required');
    }
    
    // Get comment owner information
    $stmt = $pdo->prepare("
        SELECT user_id as owner_id, comment, post_id
        FROM comments 
        WHERE id = ?
    ");
    
    $stmt->execute([$comment_id]);
    $comment = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$comment) {
        throw new Exception('Comment not found');
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Comment owner retrieved successfully',
        'owner_id' => $comment['owner_id'],
        'comment' => $comment['comment'],
        'post_id' => $comment['post_id']
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 