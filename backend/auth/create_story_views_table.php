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
    // Check if story_views table exists
    $check_table_query = "SHOW TABLES LIKE 'story_views'";
    $check_stmt = $db->prepare($check_table_query);
    $check_stmt->execute();
    $table_exists = $check_stmt->rowCount() > 0;
    
    if (!$table_exists) {
        // Create story_views table
        $create_table_query = "
            CREATE TABLE story_views (
                id INT AUTO_INCREMENT PRIMARY KEY,
                story_id INT NOT NULL,
                viewer_id INT NOT NULL,
                viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (story_id) REFERENCES stories(id) ON DELETE CASCADE,
                FOREIGN KEY (viewer_id) REFERENCES users(id) ON DELETE CASCADE,
                UNIQUE KEY unique_story_view (story_id, viewer_id)
            )
        ";
        
        $db->exec($create_table_query);
        
        http_response_code(201);
        echo json_encode(array(
            "message" => "Story views table created successfully",
            "table_created" => true
        ));
    } else {
        http_response_code(200);
        echo json_encode(array(
            "message" => "Story views table already exists",
            "table_created" => false
        ));
    }

} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Server error: " . $e->getMessage()));
}
?> 