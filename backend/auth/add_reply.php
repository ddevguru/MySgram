<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
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
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    $token = $input['token'] ?? null;
    $post_id = $input['post_id'] ?? null;
    $parent_comment_id = $input['parent_comment_id'] ?? null;
    $reply_text = $input['reply_text'] ?? null;

    if (!$token) {
        http_response_code(401);
        echo json_encode(array("message" => "Token is required"));
        exit();
    }

    if (!$post_id) {
        http_response_code(400);
        echo json_encode(array("message" => "Post ID is required"));
        exit();
    }

    if (!$parent_comment_id) {
        http_response_code(400);
        echo json_encode(array("message" => "Parent comment ID is required"));
        exit();
    }

    if (!$reply_text || trim($reply_text) === '') {
        http_response_code(400);
        echo json_encode(array("message" => "Reply text is required"));
        exit();
    }

    // Verify token
    $decoded = JWT::verify($token);
    if (!$decoded) {
        http_response_code(401);
        echo json_encode(array("message" => "Invalid token"));
        exit();
    }

    $user_id = $decoded['user_id'];

    // Check if parent comment exists
    $check_parent_query = "SELECT id FROM comments WHERE id = ? AND post_id = ?";
    $check_parent_stmt = $db->prepare($check_parent_query);
    $check_parent_stmt->bindParam(1, $parent_comment_id);
    $check_parent_stmt->bindParam(2, $post_id);
    $check_parent_stmt->execute();
    
    if ($check_parent_stmt->rowCount() == 0) {
        http_response_code(400);
        echo json_encode(array("message" => "Parent comment not found"));
        exit();
    }

    // Check if comments table has comment_text column
    $check_column = $db->query("SHOW COLUMNS FROM comments LIKE 'comment_text'");
    $has_comment_text = $check_column->rowCount() > 0;
    
    if ($has_comment_text) {
        // Use comment_text column
        $insert_query = "INSERT INTO comments (post_id, user_id, parent_id, comment_text) VALUES (?, ?, ?, ?)";
    } else {
        // Use comment column (old name)
        $insert_query = "INSERT INTO comments (post_id, user_id, parent_id, comment) VALUES (?, ?, ?, ?)";
    }

    $insert_stmt = $db->prepare($insert_query);
    $insert_stmt->bindParam(1, $post_id);
    $insert_stmt->bindParam(2, $user_id);
    $insert_stmt->bindParam(3, $parent_comment_id);
    $insert_stmt->bindParam(4, $reply_text);

    if ($insert_stmt->execute()) {
        $reply_id = $db->lastInsertId();
        
        // Update comments count in posts table
        $update_query = "UPDATE posts SET comments_count = (SELECT COUNT(*) FROM comments WHERE post_id = ?) WHERE id = ?";
        $update_stmt = $db->prepare($update_query);
        $update_stmt->bindParam(1, $post_id);
        $update_stmt->bindParam(2, $post_id);
        $update_stmt->execute();

        // Get user info for the new reply
        $user_query = "SELECT username, full_name, profile_picture FROM users WHERE id = ?";
        $user_stmt = $db->prepare($user_query);
        $user_stmt->bindParam(1, $user_id);
        $user_stmt->execute();
        $user_data = $user_stmt->fetch(PDO::FETCH_ASSOC);

        // Get updated comments count
        $count_query = "SELECT comments_count FROM posts WHERE id = ?";
        $count_stmt = $db->prepare($count_query);
        $count_stmt->bindParam(1, $post_id);
        $count_stmt->execute();
        $post_data = $count_stmt->fetch(PDO::FETCH_ASSOC);
        $comments_count = $post_data['comments_count'] ?? 0;

        http_response_code(201);
        echo json_encode(array(
            "success" => true,
            "message" => "Reply added successfully",
            "reply" => array(
                'id' => $reply_id,
                'post_id' => $post_id,
                'user_id' => $user_id,
                'parent_id' => $parent_comment_id,
                'comment' => $reply_text,
                'created_at' => date('Y-m-d H:i:s'),
                'username' => $user_data['username'],
                'full_name' => $user_data['full_name'],
                'profile_picture' => $user_data['profile_picture']
            ),
            "comments_count" => (int)$comments_count
        ));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to add reply"));
    }

} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array(
        "success" => false,
        "message" => "Server error: " . $e->getMessage()
    ));
}
?> 