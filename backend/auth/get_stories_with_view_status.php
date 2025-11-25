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
    
    // Ensure stories table exists
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
    
    // Ensure story_views table exists
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
    
    // Get all active stories with view status for current user
    $stmt = $pdo->prepare("
        SELECT 
            s.id,
            s.user_id,
            s.media_url,
            s.media_type,
            s.caption,
            s.created_at,
            s.expires_at,
            u.username,
            u.full_name,
            u.profile_picture,
            CASE 
                WHEN sv.viewer_id IS NOT NULL THEN TRUE 
                ELSE FALSE 
            END as is_viewed
        FROM stories s
        INNER JOIN users u ON s.user_id = u.id
        LEFT JOIN story_views sv ON s.id = sv.story_id AND sv.viewer_id = ?
        WHERE s.is_active = TRUE 
        AND s.expires_at > NOW()
        ORDER BY s.created_at DESC
    ");
    
    $stmt->execute([$current_user_id]);
    $stories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format stories for response
    $formatted_stories = [];
    foreach ($stories as $story) {
        $formatted_stories[] = [
            'id' => $story['id'],
            'user_id' => $story['user_id'],
            'media_url' => $story['media_url'],
            'media_type' => $story['media_type'],
            'caption' => $story['caption'],
            'created_at' => $story['created_at'],
            'expires_at' => $story['expires_at'],
            'username' => $story['username'],
            'full_name' => $story['full_name'],
            'profile_picture' => $story['profile_picture'],
            'is_viewed' => (bool)$story['is_viewed']
        ];
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Stories with view status retrieved successfully',
        'stories' => $formatted_stories,
        'total_stories' => count($formatted_stories)
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 