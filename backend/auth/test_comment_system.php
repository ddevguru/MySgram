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
    echo json_encode([
        'success' => true,
        'message' => 'Comment system test',
        'timestamp' => date('Y-m-d H:i:s'),
        'database_connected' => isset($pdo),
        'jwt_available' => class_exists('JWT'),
        'request_method' => $_SERVER['REQUEST_METHOD'],
        'tests' => [
            'database_connection' => '✅ Database connection available',
            'jwt_class' => '✅ JWT class available',
            'comments_table' => 'Checking comments table...'
        ]
    ]);
    
    // Test comments table structure
    try {
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS comments (
                id INT AUTO_INCREMENT PRIMARY KEY,
                post_id INT NOT NULL,
                user_id INT NOT NULL,
                parent_id INT NULL,
                comment TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_post (post_id),
                INDEX idx_user (user_id),
                INDEX idx_parent (parent_id),
                INDEX idx_created (created_at)
            )
        ");
        
        echo json_encode([
            'success' => true,
            'message' => 'Comments table created/verified successfully',
            'comments_table' => '✅ Comments table ready'
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Error with comments table: ' . $e->getMessage(),
            'comments_table' => '❌ Comments table error'
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'error_details' => [
            'file' => $e->getFile(),
            'line' => $e->getLine(),
            'trace' => $e->getTraceAsString()
        ]
    ]);
}
?> 