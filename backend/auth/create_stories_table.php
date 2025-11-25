<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
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
    
    // Create stories table if it doesn't exist
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS stories (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            media_url TEXT NOT NULL,
            media_type VARCHAR(50) DEFAULT 'image',
            caption TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL 24 HOUR),
            is_active BOOLEAN DEFAULT TRUE,
            INDEX idx_user (user_id),
            INDEX idx_created (created_at),
            INDEX idx_expires (expires_at)
        )
    ");
    
    // Create story views table if it doesn't exist
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS story_views (
            id INT AUTO_INCREMENT PRIMARY KEY,
            story_id INT NOT NULL,
            viewer_id INT NOT NULL,
            viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY unique_view (story_id, viewer_id),
            INDEX idx_story (story_id),
            INDEX idx_viewer (viewer_id)
        )
    ");
    
    echo json_encode([
        'success' => true,
        'message' => 'Stories tables created/verified successfully',
        'tables' => ['stories', 'story_views']
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 