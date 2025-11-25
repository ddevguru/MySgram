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
    // Get user with posts
    $user_query = "SELECT id, username, posts_count, streak_count, last_post_date FROM users WHERE posts_count > 0 LIMIT 1";
    $user_stmt = $db->prepare($user_query);
    $user_stmt->execute();
    $user_data = $user_stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user_data) {
        $streak_raw = $user_data['streak_count'];
        $streak_int = (int)$streak_raw;
        $streak_string = (string)$streak_raw;
        
        http_response_code(200);
        echo json_encode(array(
            "message" => "Streak display test",
            "user_id" => $user_data['id'],
            "username" => $user_data['username'],
            "posts_count" => $user_data['posts_count'],
            "streak_raw" => $streak_raw,
            "streak_int" => $streak_int,
            "streak_string" => $streak_string,
            "streak_type" => gettype($streak_raw),
            "last_post_date" => $user_data['last_post_date']
        ));
    } else {
        http_response_code(404);
        echo json_encode(array("message" => "No user found with posts"));
    }
    
} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Test error: " . $e->getMessage()));
}
?> 