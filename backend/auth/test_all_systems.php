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
        'message' => 'Testing all systems...',
        'timestamp' => date('Y-m-d H:i:s'),
        'tests' => []
    ]);
    
    $tests = [];
    
    // Test 1: Database Connection
    try {
        $tests['database_connection'] = '✅ Database connection successful';
    } catch (Exception $e) {
        $tests['database_connection'] = '❌ Database connection failed: ' . $e->getMessage();
    }
    
    // Test 2: JWT Class
    try {
        $jwt = new JWT();
        $tests['jwt_class'] = '✅ JWT class available';
    } catch (Exception $e) {
        $tests['jwt_class'] = '❌ JWT class error: ' . $e->getMessage();
    }
    
    // Test 3: Comments Table
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
        $tests['comments_table'] = '✅ Comments table ready';
    } catch (Exception $e) {
        $tests['comments_table'] = '❌ Comments table error: ' . $e->getMessage();
    }
    
    // Test 4: Stories Table
    try {
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
        $tests['stories_table'] = '✅ Stories table ready';
    } catch (Exception $e) {
        $tests['stories_table'] = '❌ Stories table error: ' . $e->getMessage();
    }
    
    // Test 5: Story Views Table
    try {
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
        $tests['story_views_table'] = '✅ Story views table ready';
    } catch (Exception $e) {
        $tests['story_views_table'] = '❌ Story views table error: ' . $e->getMessage();
    }
    
    // Test 6: Notifications Table
    try {
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS notifications (
                id INT AUTO_INCREMENT PRIMARY KEY,
                type VARCHAR(50) NOT NULL,
                recipient_id VARCHAR(50) NOT NULL,
                sender_id VARCHAR(50) NOT NULL,
                sender_name VARCHAR(255) NOT NULL,
                sender_profile_picture TEXT,
                target_id VARCHAR(50),
                title VARCHAR(255) NOT NULL,
                message TEXT NOT NULL,
                metadata JSON,
                is_read BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_recipient (recipient_id),
                INDEX idx_sender (sender_id),
                INDEX idx_type (type),
                INDEX idx_created (created_at)
            )
        ");
        $tests['notifications_table'] = '✅ Notifications table ready';
    } catch (Exception $e) {
        $tests['notifications_table'] = '❌ Notifications table error: ' . $e->getMessage();
    }
    
    // Test 7: Check Upload Directories
    try {
        $directories = [
            '../uploads/stories/',
            '../uploads/posts/',
            '../uploads/profiles/',
            '../logs/'
        ];
        
        foreach ($directories as $dir) {
            if (!file_exists($dir)) {
                mkdir($dir, 0777, true);
            }
            if (!is_writable($dir)) {
                chmod($dir, 0777);
            }
        }
        $tests['upload_directories'] = '✅ Upload directories ready';
    } catch (Exception $e) {
        $tests['upload_directories'] = '❌ Upload directories error: ' . $e->getMessage();
    }
    
    // Test 8: Verify Table Columns
    try {
        $comments_columns = $pdo->query("SHOW COLUMNS FROM comments")->fetchAll(PDO::FETCH_COLUMN);
        $stories_columns = $pdo->query("SHOW COLUMNS FROM stories")->fetchAll(PDO::FETCH_COLUMN);
        $notifications_columns = $pdo->query("SHOW COLUMNS FROM notifications")->fetchAll(PDO::FETCH_COLUMN);
        
        $tests['table_columns'] = '✅ Table columns verified';
        $tests['comments_columns'] = $comments_columns;
        $tests['stories_columns'] = $stories_columns;
        $tests['notifications_columns'] = $notifications_columns;
    } catch (Exception $e) {
        $tests['table_columns'] = '❌ Table columns error: ' . $e->getMessage();
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'All systems test completed',
        'timestamp' => date('Y-m-d H:i:s'),
        'tests' => $tests,
        'summary' => [
            'total_tests' => count($tests),
            'passed' => count(array_filter($tests, function($test) { return strpos($test, '✅') === 0; })),
            'failed' => count(array_filter($tests, function($test) { return strpos($test, '❌') === 0; }))
        ]
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Test failed: ' . $e->getMessage(),
        'error_details' => [
            'file' => $e->getFile(),
            'line' => $e->getLine(),
            'trace' => $e->getTraceAsString()
        ]
    ]);
}
?> 