<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once 'config/database.php';

$database = new Database();
$db = $database->getConnection();

try {
    // Create posts table if it doesn't exist
    $create_posts_table = "
    CREATE TABLE IF NOT EXISTS posts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        caption TEXT,
        media_type ENUM('image', 'video', 'reel') NOT NULL,
        media_url TEXT NOT NULL,
        thumbnail_url TEXT,
        duration INT,
        likes_count INT DEFAULT 0,
        comments_count INT DEFAULT 0,
        shares_count INT DEFAULT 0,
        is_public BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id),
        INDEX idx_created_at (created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $stmt = $db->prepare($create_posts_table);
    if ($stmt->execute()) {
        echo json_encode(array(
            "message" => "Database setup completed successfully.",
            "posts_table_created" => true
        ));
    } else {
        echo json_encode(array(
            "message" => "Failed to create posts table.",
            "error" => $db->errorInfo()
        ));
    }
    
} catch(Exception $e) {
    echo json_encode(array(
        "message" => "Database setup error: " . $e->getMessage(),
        "error" => true
    ));
}
?> 