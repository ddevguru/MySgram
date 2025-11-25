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

if(!empty($data->token)) {
    try {
        $decoded = JWT::verify($data->token);
        if (!$decoded) {
            http_response_code(401);
            echo json_encode(array("message" => "Invalid token."));
            exit();
        }
        $user_id = $decoded['user_id'];
        
        // Get user's posts count
        $user_query = "SELECT posts_count, streak_count FROM users WHERE id = ?";
        $user_stmt = $db->prepare($user_query);
        $user_stmt->bindParam(1, $user_id);
        $user_stmt->execute();
        $user_data = $user_stmt->fetch(PDO::FETCH_ASSOC);
        
        if(!$user_data) {
            http_response_code(404);
            echo json_encode(array("message" => "User not found."));
            exit();
        }
        
        $posts_count = $user_data['posts_count'];
        $current_streak = $user_data['streak_count'];
        
        // Fix streak: if user has posts but zero streak, set streak to posts count
        if ($posts_count > 0 && $current_streak == 0) {
            $update_query = "UPDATE users SET streak_count = ? WHERE id = ?";
            $update_stmt = $db->prepare($update_query);
            $update_stmt->bindParam(1, $posts_count);
            $update_stmt->bindParam(2, $user_id);
            $update_stmt->execute();
            
            $new_streak = $posts_count;
        } else {
            $new_streak = $current_streak;
        }
        
        http_response_code(200);
        echo json_encode(array(
            "message" => "Streak fixed successfully.",
            "posts_count" => $posts_count,
            "old_streak" => $current_streak,
            "new_streak" => $new_streak
        ));
        
    } catch(Exception $e) {
        http_response_code(500);
        echo json_encode(array("message" => "Server error: " . $e->getMessage()));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Token is required."));
}
?> 