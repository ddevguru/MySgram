<?php
require_once '../config/config.php';
require_once '../config/database.php';
require_once '../models/User.php';
require_once '../utils/JWT.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Initialize user object
$user = new User($db);

// Get authorization header
$headers = getallheaders();
$auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';

if(empty($auth_header) || !preg_match('/Bearer\s(\S+)/', $auth_header, $matches)) {
    http_response_code(401);
    echo json_encode(array("message" => "Access denied. No token provided."));
    exit();
}

$token = $matches[1];

// Verify token
$payload = JWT::verify($token);

if(!$payload) {
    http_response_code(401);
    echo json_encode(array("message" => "Access denied. Invalid token."));
    exit();
}

// Get user data
$user_id = $payload['user_id'];
$user_data = $user->getById($user_id);

if(!$user_data) {
    http_response_code(401);
    echo json_encode(array("message" => "Access denied. User not found."));
    exit();
}

// Return user data
http_response_code(200);
echo json_encode(array(
    "message" => "Token is valid.",
    "user" => $user_data
));
?> 