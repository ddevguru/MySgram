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
$data = json_decode(file_get_contents("php://input"));

if(!empty($data->token) && !empty($data->post_id)) {
    try {
        // Verify JWT token
        $decoded = JWT::verify($data->token);
        if (!$decoded) {
            http_response_code(401);
            echo json_encode(array("message" => "Invalid token."));
            exit();
        }
        
        $user_id = $decoded['user_id'];
        $post_id = $data->post_id;
        
        // Check if post exists and belongs to user
        $checkQuery = "SELECT id, user_id, media_url, thumbnail_url FROM posts WHERE id = ? AND user_id = ?";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bindParam(1, $post_id);
        $checkStmt->bindParam(2, $user_id);
        $checkStmt->execute();
        
        if($checkStmt->rowCount() == 0) {
            http_response_code(404);
            echo json_encode(array("message" => "Post not found or you don't have permission to delete it."));
            exit();
        }
        
        $post = $checkStmt->fetch(PDO::FETCH_ASSOC);
        
        // Delete associated files
        if(!empty($post['media_url'])) {
            $file_path = str_replace('https://devloperwala.in/MySgram/backend/', '../', $post['media_url']);
            $file_path = str_replace('https://mysgram.com/auth/', '../', $file_path);
            if (file_exists($file_path)) {
                unlink($file_path);
            }
        }
        
        if(!empty($post['thumbnail_url'])) {
            $thumb_path = str_replace('https://devloperwala.in/MySgram/backend/', '../', $post['thumbnail_url']);
            $thumb_path = str_replace('https://mysgram.com/auth/', '../', $thumb_path);
            if (file_exists($thumb_path)) {
                unlink($thumb_path);
            }
        }
        
        // Delete post (CASCADE will delete likes, comments automatically)
        $deleteQuery = "DELETE FROM posts WHERE id = ? AND user_id = ?";
        $deleteStmt = $db->prepare($deleteQuery);
        $deleteStmt->bindParam(1, $post_id);
        $deleteStmt->bindParam(2, $user_id);
        
        if($deleteStmt->execute()) {
            // Update user's posts count
            $updateCountQuery = "UPDATE users SET posts_count = (SELECT COUNT(*) FROM posts WHERE user_id = ?) WHERE id = ?";
            $updateCountStmt = $db->prepare($updateCountQuery);
            $updateCountStmt->bindParam(1, $user_id);
            $updateCountStmt->bindParam(2, $user_id);
            $updateCountStmt->execute();
            
            http_response_code(200);
            echo json_encode(array(
                "message" => "Post deleted successfully.",
                "success" => true
            ));
        } else {
            http_response_code(503);
            echo json_encode(array("message" => "Unable to delete post."));
        }
        
    } catch(Exception $e) {
        http_response_code(500);
        echo json_encode(array("message" => "Server error: " . $e->getMessage()));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Token and post_id are required."));
}
?>

