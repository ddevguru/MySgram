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
    $results = array();
    
    // Test 1: Check tables exist
    $tables = ['users', 'posts', 'likes', 'comments'];
    foreach ($tables as $table) {
        $check = $db->query("SHOW TABLES LIKE '$table'");
        $results['tables'][$table] = $check->rowCount() > 0;
    }
    
    // Test 2: Check users table structure
    $users_check = $db->query("DESCRIBE users");
    $users_columns = [];
    while ($row = $users_check->fetch(PDO::FETCH_ASSOC)) {
        $users_columns[] = $row['Field'];
    }
    $results['users_columns'] = $users_columns;
    
    // Test 3: Get user count and sample user
    $user_count = $db->query("SELECT COUNT(*) as count FROM users")->fetch(PDO::FETCH_ASSOC)['count'];
    $results['user_count'] = $user_count;
    
    if ($user_count > 0) {
        $sample_user = $db->query("SELECT id, username, posts_count, streak_count FROM users LIMIT 1")->fetch(PDO::FETCH_ASSOC);
        $results['sample_user'] = $sample_user;
    }
    
    // Test 4: Get posts count and sample post
    $post_count = $db->query("SELECT COUNT(*) as count FROM posts")->fetch(PDO::FETCH_ASSOC)['count'];
    $results['post_count'] = $post_count;
    
    if ($post_count > 0) {
        $sample_post = $db->query("SELECT id, user_id, caption, likes_count, comments_count FROM posts LIMIT 1")->fetch(PDO::FETCH_ASSOC);
        $results['sample_post'] = $sample_post;
    }
    
    // Test 5: Check likes and comments counts
    $likes_count = $db->query("SELECT COUNT(*) as count FROM likes")->fetch(PDO::FETCH_ASSOC)['count'];
    $comments_count = $db->query("SELECT COUNT(*) as count FROM comments")->fetch(PDO::FETCH_ASSOC)['count'];
    $results['likes_count'] = $likes_count;
    $results['comments_count'] = $comments_count;
    
    // Test 6: Check if posts table has required columns
    $posts_check = $db->query("DESCRIBE posts");
    $posts_columns = [];
    while ($row = $posts_check->fetch(PDO::FETCH_ASSOC)) {
        $posts_columns[] = $row['Field'];
    }
    $results['posts_columns'] = $posts_columns;
    
    // Test 7: Check if likes table has required columns
    if ($results['tables']['likes']) {
        $likes_check = $db->query("DESCRIBE likes");
        $likes_columns = [];
        while ($row = $likes_check->fetch(PDO::FETCH_ASSOC)) {
            $likes_columns[] = $row['Field'];
        }
        $results['likes_columns'] = $likes_columns;
    }
    
    // Test 8: Check if comments table has required columns
    if ($results['tables']['comments']) {
        $comments_check = $db->query("DESCRIBE comments");
        $comments_columns = [];
        while ($row = $comments_check->fetch(PDO::FETCH_ASSOC)) {
            $comments_columns[] = $row['Field'];
        }
        $results['comments_columns'] = $comments_columns;
    }
    
    http_response_code(200);
    echo json_encode(array(
        "message" => "All tests completed successfully",
        "results" => $results
    ));
    
} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Test error: " . $e->getMessage()));
}
?> 