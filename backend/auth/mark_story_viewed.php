<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config/database.php';
require_once '../utils/JWT.php';

try {
    // Check if it's a POST request
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(array("message" => "Method not allowed"));
        exit();
    }

    // Get token from header
    $headers = getallheaders();
    $token = null;
    if (isset($headers['Authorization'])) {
        $token = str_replace('Bearer ', '', $headers['Authorization']);
    }

    if (!$token) {
        http_response_code(401);
        echo json_encode(array("message" => "Token is required"));
        exit();
    }

    // Verify token
    $jwt = new JWT();
    $decoded = $jwt->verify($token);
    if (!$decoded) {
        http_response_code(401);
        echo json_encode(array("message" => "Invalid token"));
        exit();
    }

    $viewer_id = $decoded['user_id'];

    // Get request body
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['story_id'])) {
        http_response_code(400);
        echo json_encode(array("message" => "Story ID is required"));
        exit();
    }

    $story_id = $input['story_id'];

    // Check if story exists and is not older than 24 hours
    $check_story_query = "
        SELECT id, user_id FROM stories 
        WHERE id = ? AND created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
    ";
    
    $check_stmt = $pdo->prepare($check_story_query);
    $check_stmt->bindParam(1, $story_id);
    $check_stmt->execute();
    
    if ($check_stmt->rowCount() == 0) {
        http_response_code(404);
        echo json_encode(array("message" => "Story not found or expired"));
        exit();
    }

    $story = $check_stmt->fetch(PDO::FETCH_ASSOC);
    
    // Don't mark own stories as viewed
    if ($story['user_id'] == $viewer_id) {
        http_response_code(200);
        echo json_encode(array(
            "message" => "Own story view not recorded",
            "viewed" => false
        ));
        exit();
    }

    // Check if already viewed
    $check_view_query = "SELECT id FROM story_views WHERE story_id = ? AND viewer_id = ?";
    $check_view_stmt = $pdo->prepare($check_view_query);
    $check_view_stmt->bindParam(1, $story_id);
    $check_view_stmt->bindParam(2, $viewer_id);
    $check_view_stmt->execute();

    if ($check_view_stmt->rowCount() > 0) {
        http_response_code(200);
        echo json_encode(array(
            "message" => "Story already viewed",
            "viewed" => true
        ));
        exit();
    }

    // Mark story as viewed
    $insert_view_query = "INSERT INTO story_views (story_id, viewer_id) VALUES (?, ?)";
    $insert_view_stmt = $pdo->prepare($insert_view_query);
    $insert_view_stmt->bindParam(1, $story_id);
    $insert_view_stmt->bindParam(2, $viewer_id);
    
    if ($insert_view_stmt->execute()) {
        http_response_code(201);
        echo json_encode(array(
            "message" => "Story marked as viewed",
            "viewed" => true
        ));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to mark story as viewed"));
    }

} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Server error: " . $e->getMessage()));
}
?> 