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
    
    // Get post ID from query parameters
    $post_id = $_GET['post_id'] ?? null;
    if (!$post_id) {
        throw new Exception('Post ID is required');
    }
    
    // Get post owner information
    $stmt = $pdo->prepare("
        SELECT user_id as owner_id, title, content
        FROM posts 
        WHERE id = ?
    ");
    
    $stmt->execute([$post_id]);
    $post = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$post) {
        throw new Exception('Post not found');
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Post owner retrieved successfully',
        'owner_id' => $post['owner_id'],
        'title' => $post['title'],
        'content' => $post['content']
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 