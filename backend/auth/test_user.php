<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Include database and object files
include_once '../config/database.php';
include_once '../models/User.php';
include_once '../utils/JWT.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Prepare user object
$user = new User($db);

// Get posted data
$data = json_decode(file_get_contents("php://input"));

if ($_SERVER['REQUEST_METHOD'] == 'POST' && !empty($data->token)) {
    try {
        // Debug: Log the token
        error_log("Test User - Token received: " . substr($data->token, 0, 50) . "...");
        
        // Verify JWT token
        $decoded = JWT::verify($data->token);
        if (!$decoded) {
            error_log("Test User - Token verification failed");
            http_response_code(401);
            echo json_encode(array("message" => "Invalid token."));
            exit();
        }
        
        $user_id = $decoded['user_id'];
        error_log("Test User - User ID from token: " . $user_id);
        
        // Get user by ID
        $user_data = $user->getById($user_id);
        if(!$user_data) {
            error_log("Test User - User not found for ID: " . $user_id);
            http_response_code(404);
            echo json_encode(array("message" => "User not found."));
            exit();
        }
        
        error_log("Test User - User found: " . $user_data['username']);
        
        http_response_code(200);
        echo json_encode(array(
            "message" => "User found successfully.",
            "user" => $user_data
        ));
        
    } catch(Exception $e) {
        error_log("Test User - Exception: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(array("message" => "Server error: " . $e->getMessage()));
    }
} else {
    // List all users for debugging
    $query = "SELECT id, username, email, full_name FROM users LIMIT 10";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    http_response_code(200);
    echo json_encode(array(
        "message" => "Available users (first 10):",
        "users" => $users
    ));
}
?> 