<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

try {
    // Check if likes table exists
    $likes_check = $db->query("SHOW TABLES LIKE 'likes'");
    $likes_exists = $likes_check->rowCount() > 0;
    
    // Check if comments table exists
    $comments_check = $db->query("SHOW TABLES LIKE 'comments'");
    $comments_exists = $comments_check->rowCount() > 0;
    
    $created_tables = [];
    
    // Create likes table if it doesn't exist
    if (!$likes_exists) {
        $create_likes = "CREATE TABLE likes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            post_id INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
            UNIQUE KEY unique_like (user_id, post_id)
        )";
        $db->exec($create_likes);
        $created_tables[] = 'likes';
    }
    
    // Create comments table if it doesn't exist
    if (!$comments_exists) {
        $create_comments = "CREATE TABLE comments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            post_id INT NOT NULL,
            comment_text TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
        )";
        $db->exec($create_comments);
        $created_tables[] = 'comments';
    }
    
    // Check users table structure
    $users_check = $db->query("DESCRIBE users");
    $users_columns = [];
    while ($row = $users_check->fetch(PDO::FETCH_ASSOC)) {
        $users_columns[] = $row['Field'];
    }
    
    $missing_columns = [];
    
    // Check if streak_count column exists
    if (!in_array('streak_count', $users_columns)) {
        $db->exec("ALTER TABLE users ADD COLUMN streak_count INT DEFAULT 0");
        $missing_columns[] = 'streak_count';
    }
    
    // Check if last_post_date column exists
    if (!in_array('last_post_date', $users_columns)) {
        $db->exec("ALTER TABLE users ADD COLUMN last_post_date DATE");
        $missing_columns[] = 'last_post_date';
    }
    
    http_response_code(200);
    echo json_encode(array(
        "message" => "Database check completed",
        "likes_table_exists" => $likes_exists,
        "comments_table_exists" => $comments_exists,
        "created_tables" => $created_tables,
        "missing_columns" => $missing_columns,
        "users_columns" => $users_columns
    ));
    
} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Database error: " . $e->getMessage()));
}
?> 