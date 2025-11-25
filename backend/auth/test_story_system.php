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
        'message' => 'Testing story system...',
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    
    // Test 1: Check if stories table exists
    try {
        $check_table = $pdo->query("SHOW TABLES LIKE 'stories'");
        $table_exists = $check_table->rowCount() > 0;
        
        if (!$table_exists) {
            // Create stories table
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
            echo json_encode(['success' => true, 'message' => 'Stories table created successfully']);
        } else {
            echo json_encode(['success' => true, 'message' => 'Stories table already exists']);
        }
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => 'Stories table error: ' . $e->getMessage()]);
        exit;
    }
    
    // Test 2: Check if story_views table exists
    try {
        $check_views_table = $pdo->query("SHOW TABLES LIKE 'story_views'");
        $views_table_exists = $check_views_table->rowCount() > 0;
        
        if (!$views_table_exists) {
            // Create story_views table
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
            echo json_encode(['success' => true, 'message' => 'Story views table created successfully']);
        } else {
            echo json_encode(['success' => true, 'message' => 'Story views table already exists']);
        }
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => 'Story views table error: ' . $e->getMessage()]);
        exit;
    }
    
    // Test 3: Check table structure
    try {
        $stories_columns = $pdo->query("SHOW COLUMNS FROM stories")->fetchAll(PDO::FETCH_COLUMN);
        $views_columns = $pdo->query("SHOW COLUMNS FROM story_views")->fetchAll(PDO::FETCH_COLUMN);
        
        echo json_encode([
            'success' => true,
            'message' => 'Table structure verified',
            'stories_columns' => $stories_columns,
            'views_columns' => $views_columns
        ]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => 'Table structure error: ' . $e->getMessage()]);
        exit;
    }
    
    // Test 4: Check if there are any stories
    try {
        $stories_count = $pdo->query("SELECT COUNT(*) FROM stories")->fetchColumn();
        $active_stories = $pdo->query("SELECT COUNT(*) FROM stories WHERE is_active = TRUE AND expires_at > NOW()")->fetchColumn();
        
        echo json_encode([
            'success' => true,
            'message' => 'Story count retrieved',
            'total_stories' => $stories_count,
            'active_stories' => $active_stories
        ]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => 'Story count error: ' . $e->getMessage()]);
        exit;
    }
    
    // Test 5: Check upload directory
    try {
        $upload_dir = '../uploads/stories/';
        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }
        
        if (is_writable($upload_dir)) {
            echo json_encode(['success' => true, 'message' => 'Upload directory is writable']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Upload directory is not writable']);
        }
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => 'Upload directory error: ' . $e->getMessage()]);
        exit;
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'All story system tests completed successfully',
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Test failed: ' . $e->getMessage(),
        'error_details' => [
            'file' => $e->getFile(),
            'line' => $e->getLine()
        ]
    ]);
}
?> 