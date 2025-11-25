<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

try {
    // Delete stories older than 24 hours
    $twenty_four_hours_ago = date('Y-m-d H:i:s', strtotime('-24 hours'));
    
    // First, get the list of expired stories to delete their files
    $get_expired_stories_query = "
        SELECT media_url FROM stories 
        WHERE created_at < ?
    ";
    
    $get_stmt = $db->prepare($get_expired_stories_query);
    $get_stmt->bindParam(1, $twenty_four_hours_ago);
    $get_stmt->execute();
    $expired_stories = $get_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Delete the actual files
    foreach ($expired_stories as $story) {
        $file_path = str_replace('https://devloperwala.in/MySgram/backend/', '../', $story['media_url']);
        if (file_exists($file_path)) {
            unlink($file_path);
        }
    }
    
    // Delete expired stories from database
    $delete_stories_query = "
        DELETE FROM stories 
        WHERE created_at < ?
    ";
    
    $delete_stmt = $db->prepare($delete_stories_query);
    $delete_stmt->bindParam(1, $twenty_four_hours_ago);
    $delete_stmt->execute();
    
    $deleted_count = $delete_stmt->rowCount();
    
    // Also delete related story views
    $delete_views_query = "
        DELETE sv FROM story_views sv
        INNER JOIN stories s ON sv.story_id = s.id
        WHERE s.created_at < ?
    ";
    
    $delete_views_stmt = $db->prepare($delete_views_query);
    $delete_views_stmt->bindParam(1, $twenty_four_hours_ago);
    $delete_views_stmt->execute();
    
    $deleted_views_count = $delete_views_stmt->rowCount();
    
    http_response_code(200);
    echo json_encode(array(
        "message" => "Expired stories deleted successfully",
        "deleted_stories" => $deleted_count,
        "deleted_views" => $deleted_views_count,
        "deleted_before" => $twenty_four_hours_ago
    ));

} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Server error: " . $e->getMessage()));
}
?> 