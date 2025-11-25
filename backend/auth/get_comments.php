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

    // Get post_id from query parameters
    $post_id = $_GET['post_id'] ?? null;
    
    if (!$post_id) {
        http_response_code(400);
        echo json_encode(array("message" => "Post ID is required"));
        exit();
    }

    // Use comment column (standard name)
    $comments_query = "SELECT 
                        c.id, c.post_id, c.user_id, c.parent_id, c.comment, c.created_at,
                        u.username, u.full_name, u.profile_picture
                    FROM comments c
                    INNER JOIN users u ON c.user_id = u.id
                    WHERE c.post_id = ?
                    ORDER BY c.parent_id ASC, c.created_at ASC";

    $comments_stmt = $db->prepare($comments_query);
    $comments_stmt->bindParam(1, $post_id);
    $comments_stmt->execute();
    
    $comments = [];
    $replies = [];
    
    while ($row = $comments_stmt->fetch(PDO::FETCH_ASSOC)) {
        $comment_data = array(
            'id' => $row['id'],
            'post_id' => $row['post_id'],
            'user_id' => $row['user_id'],
            'parent_id' => $row['parent_id'],
            'comment' => $row['comment'],
            'created_at' => $row['created_at'],
            'username' => $row['username'],
            'full_name' => $row['full_name'],
            'profile_picture' => $row['profile_picture'],
            'replies' => []
        );
        
        if ($row['parent_id'] === null) {
            // This is a main comment
            $comments[] = $comment_data;
        } else {
            // This is a reply
            $replies[] = $comment_data;
        }
    }
    
    // Organize replies under their parent comments
    foreach ($replies as $reply) {
        foreach ($comments as &$comment) {
            if ($comment['id'] == $reply['parent_id']) {
                $comment['replies'][] = $reply;
                break;
            }
        }
    }

    http_response_code(200);
    echo json_encode(array(
        "message" => "Comments retrieved successfully.",
        "comments" => $comments,
        "total_comments" => count($comments)
    ));

} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Server error: " . $e->getMessage()));
}
?> 