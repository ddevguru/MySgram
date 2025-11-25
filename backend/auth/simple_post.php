<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Check if it's a POST request
if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed. Use POST."));
    exit();
}

try {
    // Get posted data
    $data = json_decode(file_get_contents("php://input"));
    
    // Validate required fields
    if(empty($data->media_url) || empty($data->media_type)) {
        http_response_code(400);
        echo json_encode(array("message" => "Media URL and type are required."));
        exit();
    }
    
    // Create posts directory if it doesn't exist
    $posts_dir = '../data/posts/';
    if (!file_exists($posts_dir)) {
        mkdir($posts_dir, 0777, true);
    }
    
    // Create a simple post object
    $post = array(
        'id' => time() . '_' . uniqid(),
        'user_id' => $data->user_id ?? '1',
        'username' => $data->username ?? 'user',
        'full_name' => $data->full_name ?? 'User',
        'profile_picture' => $data->profile_picture ?? '',
        'caption' => $data->caption ?? '',
        'media_url' => $data->media_url,
        'media_type' => $data->media_type,
        'thumbnail_url' => $data->thumbnail_url ?? $data->media_url,
        'likes_count' => 0,
        'comments_count' => 0,
        'created_at' => date('Y-m-d H:i:s'),
        'updated_at' => date('Y-m-d H:i:s')
    );
    
    // Save post to JSON file
    $post_file = $posts_dir . $post['id'] . '.json';
    if (file_put_contents($post_file, json_encode($post, JSON_PRETTY_PRINT))) {
        http_response_code(201);
        echo json_encode(array(
            "message" => "Post created successfully.",
            "post" => $post
        ));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to save post."));
    }
    
} catch(Exception $e) {
    error_log("Simple post error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(array("message" => "Server error: " . $e->getMessage()));
}
?> 