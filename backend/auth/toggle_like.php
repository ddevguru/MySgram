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

    // Verify token
    $decoded = JWT::verify($token);
    if (!$decoded) {
        http_response_code(401);
        echo json_encode(array("message" => "Invalid token"));
        exit();
    }

    $user_id = $decoded['user_id'];

    // Check if like exists
    $check_like_query = "SELECT id FROM likes WHERE post_id = ? AND user_id = ?";
    $check_like_stmt = $db->prepare($check_like_query);
    $check_like_stmt->bindParam(1, $post_id);
    $check_like_stmt->bindParam(2, $user_id);
    $check_like_stmt->execute();
    $existing_like = $check_like_stmt->fetch(PDO::FETCH_ASSOC);

    if ($existing_like) {
        // Unlike - remove the like
        $delete_like_query = "DELETE FROM likes WHERE post_id = ? AND user_id = ?";
        $delete_like_stmt = $db->prepare($delete_like_query);
        $delete_like_stmt->bindParam(1, $post_id);
        $delete_like_stmt->bindParam(2, $user_id);
        $delete_like_stmt->execute();

        $is_liked = false;
    } else {
        // Like - add the like
        $insert_like_query = "INSERT INTO likes (post_id, user_id) VALUES (?, ?)";
        $insert_like_stmt = $db->prepare($insert_like_query);
        $insert_like_stmt->bindParam(1, $post_id);
        $insert_like_stmt->bindParam(2, $user_id);
        $insert_like_stmt->execute();

        // Create notification for post owner
        try {
            $post_owner_query = "SELECT user_id FROM posts WHERE id = ?";
            $post_owner_stmt = $db->prepare($post_owner_query);
            $post_owner_stmt->bindParam(1, $post_id);
            $post_owner_stmt->execute();
            $post_owner = $post_owner_stmt->fetch(PDO::FETCH_COLUMN);
            
            if ($post_owner && $post_owner != $user_id) {
                $notification_query = "INSERT INTO notifications (recipient_id, sender_id, type, message, post_id) VALUES (?, ?, 'like', 'liked your post', ?)";
                $notification_stmt = $db->prepare($notification_query);
                $notification_stmt->bindParam(1, $post_owner);
                $notification_stmt->bindParam(2, $user_id);
                $notification_stmt->bindParam(3, $post_id);
                $notification_stmt->execute();
            }
        } catch (Exception $e) {
            error_log("Failed to create like notification: " . $e->getMessage());
        }

        $is_liked = true;
    }

    // Update likes count in posts table
    $update_likes_query = "UPDATE posts SET likes_count = (SELECT COUNT(*) FROM likes WHERE post_id = ?) WHERE id = ?";
    $update_likes_stmt = $db->prepare($update_likes_query);
    $update_likes_stmt->bindParam(1, $post_id);
    $update_likes_stmt->bindParam(2, $post_id);
    $update_likes_stmt->execute();

    // Get updated likes count
    $get_likes_query = "SELECT likes_count FROM posts WHERE id = ?";
    $get_likes_stmt = $db->prepare($get_likes_query);
    $get_likes_stmt->bindParam(1, $post_id);
    $get_likes_stmt->execute();
    $likes_result = $get_likes_stmt->fetch(PDO::FETCH_ASSOC);
    $likes_count = $likes_result['likes_count'] ?? 0;

    http_response_code(200);
    echo json_encode(array(
        "success" => true,
        "is_liked" => $is_liked,
        "likes_count" => (int)$likes_count,
        "message" => $is_liked ? "Post liked successfully" : "Post unliked successfully"
    ));

} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array(
        "success" => false,
        "message" => "Server error: " . $e->getMessage()
    ));
}
?> 