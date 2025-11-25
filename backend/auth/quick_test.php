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
    $results = array();
    
    // Test 1: Check comments table structure
    $comments_check = $db->query("DESCRIBE comments");
    $comments_columns = [];
    while ($row = $comments_check->fetch(PDO::FETCH_ASSOC)) {
        $comments_columns[] = $row['Field'];
    }
    $results['comments_columns'] = $comments_columns;
    
    // Test 2: Check if comment_text column exists
    $has_comment_text = in_array('comment_text', $comments_columns);
    $results['has_comment_text'] = $has_comment_text;
    
    // Test 3: Get user with posts
    $user_query = "SELECT id, username, posts_count, streak_count, last_post_date FROM users WHERE posts_count > 0 LIMIT 1";
    $user_stmt = $db->prepare($user_query);
    $user_stmt->execute();
    $user_data = $user_stmt->fetch(PDO::FETCH_ASSOC);
    $results['user_data'] = $user_data;
    
    // Test 4: Get posts count
    $posts_count = $db->query("SELECT COUNT(*) as count FROM posts")->fetch(PDO::FETCH_ASSOC)['count'];
    $results['posts_count'] = $posts_count;
    
    // Test 5: Check if posts have likes_count and comments_count
    $posts_check = $db->query("DESCRIBE posts");
    $posts_columns = [];
    while ($row = $posts_check->fetch(PDO::FETCH_ASSOC)) {
        $posts_columns[] = $row['Field'];
    }
    $results['posts_columns'] = $posts_columns;
    $results['has_likes_count'] = in_array('likes_count', $posts_columns);
    $results['has_comments_count'] = in_array('comments_count', $posts_columns);
    
    http_response_code(200);
    echo json_encode(array(
        "message" => "Quick test completed",
        "results" => $results
    ));
    
} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Test error: " . $e->getMessage()));
}
?> 