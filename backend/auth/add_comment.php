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
    $comment_text = $input['comment'] ?? null;

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

    if (!$comment_text || trim($comment_text) === '') {
        http_response_code(400);
        echo json_encode(array("message" => "Comment text is required"));
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

    // Use comment column (standard name)
    $insert_query = "INSERT INTO comments (post_id, user_id, comment) VALUES (?, ?, ?)";

    $insert_stmt = $db->prepare($insert_query);
    $insert_stmt->bindParam(1, $post_id);
    $insert_stmt->bindParam(2, $user_id);
    $insert_stmt->bindParam(3, $comment_text);

            if ($insert_stmt->execute()) {
            $comment_id = $db->lastInsertId();
            
            // Create notification for post owner
            try {
                $post_owner_query = "SELECT user_id FROM posts WHERE id = ?";
                $post_owner_stmt = $db->prepare($post_owner_query);
                $post_owner_stmt->bindParam(1, $post_id);
                $post_owner_stmt->execute();
                $post_owner = $post_owner_stmt->fetch(PDO::FETCH_COLUMN);
                
                if ($post_owner && $post_owner != $user_id) {
                    $notification_query = "INSERT INTO notifications (recipient_id, sender_id, type, message, post_id, comment_id) VALUES (?, ?, 'comment', 'commented on your post', ?, ?)";
                    $notification_stmt = $db->prepare($notification_query);
                    $notification_stmt->bindParam(1, $post_owner);
                    $notification_stmt->bindParam(2, $user_id);
                    $notification_stmt->bindParam(3, $post_id);
                    $notification_stmt->bindParam(4, $comment_id);
                    $notification_stmt->execute();
                }
            } catch (Exception $e) {
                error_log("Failed to create comment notification: " . $e->getMessage());
            }
            
            // Update comments count in posts table
            $update_query = "UPDATE posts SET comments_count = (SELECT COUNT(*) FROM comments WHERE post_id = ?) WHERE id = ?";
            $update_stmt = $db->prepare($update_query);
            $update_stmt->bindParam(1, $post_id);
            $update_stmt->bindParam(2, $post_id);
            $update_stmt->execute();

        // Get user info for the new comment
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
            "message" => "Comment added successfully",
            "comment" => array(
                'id' => $comment_id,
                'post_id' => $post_id,
                'user_id' => $user_id,
                'comment' => $comment_text,
                'created_at' => date('Y-m-d H:i:s'),
                'username' => $user_data['username'],
                'full_name' => $user_data['full_name'],
                'profile_picture' => $user_data['profile_picture']
            ),
            "comments_count" => (int)$comments_count
        ));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to add comment"));
    }

} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array(
        "success" => false,
        "message" => "Server error: " . $e->getMessage()
    ));
}
?> 