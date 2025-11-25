<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
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
    $decoded = JWT::verify($token);
    if (!$decoded) {
        http_response_code(401);
        echo json_encode(array("message" => "Invalid token"));
        exit();
    }

    $user_id = $decoded['user_id'];

    // Get stories from the last 24 hours
    $twenty_four_hours_ago = date('Y-m-d H:i:s', strtotime('-24 hours'));
    
    // First, get the current user's stories
    $current_user_stories_query = "
        SELECT 
            s.id, s.user_id, s.media_url, s.media_type, s.caption, s.duration, s.created_at,
            u.username, u.full_name, u.profile_picture
        FROM stories s
        INNER JOIN users u ON s.user_id = u.id
        WHERE s.user_id = ? AND s.created_at >= ?
        ORDER BY s.created_at DESC
    ";
    
    $current_user_stmt = $db->prepare($current_user_stories_query);
    $current_user_stmt->bindParam(1, $user_id);
    $current_user_stmt->bindParam(2, $twenty_four_hours_ago);
    $current_user_stmt->execute();
    $current_user_stories = $current_user_stmt->fetchAll(PDO::FETCH_ASSOC);

    // Get stories from users that the current user follows
    $followed_stories_query = "
        SELECT 
            s.id, s.user_id, s.media_url, s.media_type, s.caption, s.duration, s.created_at,
            u.username, u.full_name, u.profile_picture
        FROM stories s
        INNER JOIN users u ON s.user_id = u.id
        INNER JOIN follows f ON s.user_id = f.following_id
        WHERE f.follower_id = ? AND s.created_at >= ? AND s.user_id != ?
        ORDER BY s.created_at DESC
    ";
    
    $followed_stmt = $db->prepare($followed_stories_query);
    $followed_stmt->bindParam(1, $user_id);
    $followed_stmt->bindParam(2, $twenty_four_hours_ago);
    $followed_stmt->bindParam(3, $user_id);
    $followed_stmt->execute();
    $followed_stories = $followed_stmt->fetchAll(PDO::FETCH_ASSOC);

    // Combine and organize stories by user
    $all_stories = array_merge($current_user_stories, $followed_stories);
    
    // Group stories by user
    $stories_by_user = [];
    foreach ($all_stories as $story) {
        $user_id_key = $story['user_id'];
        if (!isset($stories_by_user[$user_id_key])) {
            $stories_by_user[$user_id_key] = [
                'user_id' => $story['user_id'],
                'username' => $story['username'],
                'full_name' => $story['full_name'],
                'profile_picture' => $story['profile_picture'],
                'has_story' => true,
                'story_created_at' => $story['created_at'],
                'stories' => []
            ];
        }
        $stories_by_user[$user_id_key]['stories'][] = [
            'id' => $story['id'],
            'media_url' => $story['media_url'],
            'media_type' => $story['media_type'],
            'caption' => $story['caption'],
            'duration' => $story['duration'],
            'created_at' => $story['created_at']
        ];
    }

    // Convert to indexed array and sort by most recent story
    $stories_array = array_values($stories_by_user);
    usort($stories_array, function($a, $b) {
        return strtotime($b['story_created_at']) - strtotime($a['story_created_at']);
    });

    http_response_code(200);
    echo json_encode(array(
        "message" => "Stories retrieved successfully.",
        "stories" => $stories_array,
        "total_stories" => count($stories_array)
    ));

} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Server error: " . $e->getMessage()));
}
?> 