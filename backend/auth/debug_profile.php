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
include_once '../utils/JWT.php';

$database = new Database();
$db = $database->getConnection();

try {
    // Get user data directly from database
    $user_query = "SELECT id, username, full_name, email, profile_picture, bio, website, location, 
                          phone, gender, date_of_birth, followers_count, following_count, posts_count, 
                          is_private, streak_count, last_post_date, created_at, updated_at
                   FROM users 
                   WHERE posts_count > 0 
                   ORDER BY id DESC 
                   LIMIT 1";
    
    $user_stmt = $db->prepare($user_query);
    $user_stmt->execute();
    $user_data = $user_stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user_data) {
        // Check data types
        $debug_info = array();
        foreach ($user_data as $key => $value) {
            $debug_info[$key] = array(
                "value" => $value,
                "type" => gettype($value),
                "is_null" => is_null($value),
                "is_empty" => empty($value)
            );
        }
        
        // Get posts for this user
        $posts_query = "SELECT id, caption, created_at FROM posts WHERE user_id = ? ORDER BY created_at DESC";
        $posts_stmt = $db->prepare($posts_query);
        $posts_stmt->bindParam(1, $user_data['id']);
        $posts_stmt->execute();
        $posts = $posts_stmt->fetchAll(PDO::FETCH_ASSOC);
        
        http_response_code(200);
        echo json_encode(array(
            "message" => "Debug profile data",
            "user_data" => $user_data,
            "debug_info" => $debug_info,
            "posts" => $posts,
            "posts_count" => count($posts),
            "streak_count_raw" => $user_data['streak_count'],
            "streak_count_int" => (int)$user_data['streak_count'],
            "streak_count_string" => (string)$user_data['streak_count']
        ));
    } else {
        http_response_code(404);
        echo json_encode(array("message" => "No user found with posts"));
    }
    
} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Debug error: " . $e->getMessage()));
}
?> 