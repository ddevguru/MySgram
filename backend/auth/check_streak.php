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
include_once '../models/User.php';
include_once '../utils/JWT.php';

$database = new Database();
$db = $database->getConnection();
$user = new User($db);
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
        
        $user_data = $user->getById($user_id);
        if(!$user_data) {
            http_response_code(404);
            echo json_encode(array("message" => "User not found."));
            exit();
        }
        
        $today = date('Y-m-d');
        $yesterday = date('Y-m-d', strtotime('-1 day'));
        $last_post_date = $user_data['last_post_date'];
        $current_streak = (int)($user_data['streak_count'] ?? 0);
        
        // Check if streak should be reset (missed more than 1 day)
        if ($last_post_date && $last_post_date < $yesterday) {
            // Reset streak to 0
            $update_query = "UPDATE users SET streak_count = 0 WHERE id = ?";
            $update_stmt = $db->prepare($update_query);
            $update_stmt->bindParam(1, $user_id);
            $update_stmt->execute();
            
            $current_streak = 0;
        }
        
        http_response_code(200);
        echo json_encode(array(
            "message" => "Streak checked successfully.",
            "current_streak" => $current_streak,
            "last_post_date" => $last_post_date,
            "today" => $today
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