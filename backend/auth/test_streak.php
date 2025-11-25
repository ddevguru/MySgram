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
include_once '../models/User.php';
include_once '../utils/JWT.php';

$database = new Database();
$db = $database->getConnection();

echo json_encode(array(
    "message" => "Database connection test",
    "database_connected" => $db ? true : false,
    "current_time" => date('Y-m-d H:i:s'),
    "test_query" => "SELECT COUNT(*) as user_count FROM users"
));

// Test user query
try {
    $stmt = $db->prepare("SELECT id, username, streak_count, last_post_date FROM users LIMIT 5");
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "\n\nUsers in database:\n";
    foreach ($users as $user) {
        echo "ID: {$user['id']}, Username: {$user['username']}, Streak: {$user['streak_count']}, Last Post: {$user['last_post_date']}\n";
    }
} catch (Exception $e) {
    echo "\n\nError querying users: " . $e->getMessage();
}

// Test posts query
try {
    $stmt = $db->prepare("SELECT COUNT(*) as post_count FROM posts");
    $stmt->execute();
    $postCount = $stmt->fetch(PDO::FETCH_ASSOC)['post_count'];
    
    echo "\n\nTotal posts in database: $postCount\n";
    
    if ($postCount > 0) {
        $stmt = $db->prepare("SELECT p.*, u.username FROM posts p JOIN users u ON p.user_id = u.id ORDER BY p.created_at DESC LIMIT 3");
        $stmt->execute();
        $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "\nRecent posts:\n";
        foreach ($posts as $post) {
            echo "ID: {$post['id']}, User: {$post['username']}, Caption: {$post['caption']}, Created: {$post['created_at']}\n";
        }
    }
} catch (Exception $e) {
    echo "\n\nError querying posts: " . $e->getMessage();
}
?> 