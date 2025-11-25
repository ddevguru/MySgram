<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Check if stories table exists
    $checkTable = $db->query("SHOW TABLES LIKE 'stories'");
    $tableExists = $checkTable->rowCount() > 0;
    
    if (!$tableExists) {
        // Create stories table with all necessary columns
        $createTable = "
        CREATE TABLE IF NOT EXISTS stories (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            media_type ENUM('image', 'video') NOT NULL,
            media_url TEXT NOT NULL,
            caption TEXT,
            duration INT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL 24 HOUR),
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            INDEX idx_user_id (user_id),
            INDEX idx_created_at (created_at),
            INDEX idx_expires_at (expires_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ";
        
        $db->exec($createTable);
        
        http_response_code(200);
        echo json_encode(array(
            "success" => true,
            "message" => "Stories table created successfully",
            "table_created" => true
        ));
    } else {
        // Check if duration column exists, add if missing
        $checkDuration = $db->query("SHOW COLUMNS FROM stories LIKE 'duration'");
        $durationExists = $checkDuration->rowCount() > 0;
        
        if (!$durationExists) {
            $addDuration = "ALTER TABLE stories ADD COLUMN duration INT NULL AFTER caption";
            $db->exec($addDuration);
            echo "✅ Added duration column to existing stories table\n";
        }
        
        http_response_code(200);
        echo json_encode(array(
            "success" => true,
            "message" => "Stories table already exists and updated",
            "table_created" => false,
            "duration_added" => !$durationExists
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