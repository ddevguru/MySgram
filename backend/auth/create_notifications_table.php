<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Check if notifications table exists
    $checkTable = $db->query("SHOW TABLES LIKE 'notifications'");
    $tableExists = $checkTable->rowCount() > 0;
    
    if (!$tableExists) {
        // Create notifications table
        $createTable = "
        CREATE TABLE IF NOT EXISTS notifications (
            id INT AUTO_INCREMENT PRIMARY KEY,
            recipient_id INT NOT NULL,
            sender_id INT NOT NULL,
            type ENUM('follow', 'like', 'comment', 'follow_request', 'mention') NOT NULL,
            post_id INT NULL,
            comment_id INT NULL,
            message TEXT,
            is_read BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
            FOREIGN KEY (comment_id) REFERENCES comments(id) ON DELETE CASCADE,
            INDEX idx_recipient_id (recipient_id),
            INDEX idx_sender_id (sender_id),
            INDEX idx_type (type),
            INDEX idx_is_read (is_read),
            INDEX idx_created_at (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ";
        
        $db->exec($createTable);
        
        http_response_code(200);
        echo json_encode(array(
            "success" => true,
            "message" => "Notifications table created successfully",
            "table_created" => true
        ));
    } else {
        http_response_code(200);
        echo json_encode(array(
            "success" => true,
            "message" => "Notifications table already exists",
            "table_exists" => true
        ));
    }
    
} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array(
        "success" => false,
        "message" => "Database error: " . $e->getMessage()
    ));
}
?> 