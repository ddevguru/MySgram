<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config/database.php';
require_once '../utils/JWT.php';

try {
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

    $user_id = $decoded['user_id'];

    // Get story ID from query parameter
    if (!isset($_GET['story_id'])) {
        http_response_code(400);
        echo json_encode(array("message" => "Story ID is required"));
        exit();
    }

    $story_id = $_GET['story_id'];

    // Check if story belongs to the current user
    $check_ownership_query = "SELECT user_id FROM stories WHERE id = ?";
    $check_stmt = $pdo->prepare($check_ownership_query);
    $check_stmt->bindParam(1, $story_id);
    $check_stmt->execute();
    
    if ($check_stmt->rowCount() == 0) {
        http_response_code(404);
        echo json_encode(array("message" => "Story not found"));
        exit();
    }

    $story = $check_stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($story['user_id'] != $user_id) {
        http_response_code(403);
        echo json_encode(array("message" => "Not authorized to view this story's viewers"));
        exit();
    }

    // Get story viewers
    $get_views_query = "
        SELECT 
            sv.viewed_at,
            u.id as viewer_id,
            u.username,
            u.full_name,
            u.profile_picture
        FROM story_views sv
        INNER JOIN users u ON sv.viewer_id = u.id
        WHERE sv.story_id = ?
        ORDER BY sv.viewed_at DESC
    ";
    
    $views_stmt = $pdo->prepare($get_views_query);
    $views_stmt->bindParam(1, $story_id);
    $views_stmt->execute();
    $views = $views_stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format the response
    $formatted_views = [];
    foreach ($views as $view) {
        $formatted_views[] = [
            'viewer_id' => $view['viewer_id'],
            'username' => $view['username'],
            'full_name' => $view['full_name'],
            'profile_picture' => $view['profile_picture'],
            'viewed_at' => $view['viewed_at'],
            'time_ago' => _getTimeAgo($view['viewed_at'])
        ];
    }

    http_response_code(200);
    echo json_encode(array(
        "message" => "Story views retrieved successfully",
        "story_id" => $story_id,
        "total_views" => count($formatted_views),
        "views" => $formatted_views
    ));

} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Server error: " . $e->getMessage()));
}

function _getTimeAgo($datetime) {
    $time = strtotime($datetime);
    $now = time();
    $diff = $now - $time;
    
    if ($diff < 60) {
        return 'Just now';
    } elseif ($diff < 3600) {
        $minutes = floor($diff / 60);
        return $minutes . 'm ago';
    } elseif ($diff < 86400) {
        $hours = floor($diff / 3600);
        return $hours . 'h ago';
    } else {
        $days = floor($diff / 86400);
        return $days . 'd ago';
    }
}
?> 