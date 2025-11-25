<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';

try {
    echo json_encode([
        'success' => true,
        'message' => 'Fixing comments table structure...',
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    
    // Check current table structure
    $check_table = $pdo->query("SHOW TABLES LIKE 'comments'");
    $table_exists = $check_table->rowCount() > 0;
    
    if (!$table_exists) {
        // Create comments table if it doesn't exist
        $pdo->exec("
            CREATE TABLE comments (
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
            'message' => 'Comments table created successfully'
        ]);
    } else {
        // Check if comment column exists
        $check_column = $pdo->query("SHOW COLUMNS FROM comments LIKE 'comment'");
        $has_comment = $check_column->rowCount() > 0;
        
        if (!$has_comment) {
            // Check if comment_text column exists
            $check_comment_text = $pdo->query("SHOW COLUMNS FROM comments LIKE 'comment_text'");
            $has_comment_text = $check_comment_text->rowCount() > 0;
            
            if ($has_comment_text) {
                // Rename comment_text to comment
                $pdo->exec("ALTER TABLE comments CHANGE comment_text comment TEXT NOT NULL");
                echo json_encode([
                    'success' => true,
                    'message' => 'Renamed comment_text to comment column'
                ]);
            } else {
                // Add comment column
                $pdo->exec("ALTER TABLE comments ADD COLUMN comment TEXT NOT NULL AFTER parent_id");
                echo json_encode([
                    'success' => true,
                    'message' => 'Added comment column to existing table'
                ]);
            }
        } else {
            echo json_encode([
                'success' => true,
                'message' => 'Comments table structure is already correct'
            ]);
        }
    }
    
    // Verify final structure
    $columns = $pdo->query("SHOW COLUMNS FROM comments")->fetchAll(PDO::FETCH_COLUMN);
    echo json_encode([
        'success' => true,
        'message' => 'Comments table structure verified',
        'columns' => $columns
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error fixing comments table: ' . $e->getMessage()
    ]);
}
?> 