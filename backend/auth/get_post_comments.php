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
    // Get token from query parameter or header
    $token = null;
    if (isset($_GET['token'])) {
        $token = $_GET['token'];
    } else {
        $headers = getallheaders();
        if (isset($headers['Authorization'])) {
            $token = str_replace('Bearer ', '', $headers['Authorization']);
        }
    }

    if (!$token) {
        http_response_code(401);
        echo json_encode(array("message" => "Token is required."));
        exit();
    }

    // Verify token
    $decoded = JWT::verify($token);
    if (!$decoded) {
        http_response_code(401);
        echo json_encode(array("message" => "Invalid token."));
        exit();
    }

    $user_id = $decoded['user_id'];
    $post_id = isset($_GET['post_id']) ? (int)$_GET['post_id'] : 0;

    if ($post_id <= 0) {
        http_response_code(400);
        echo json_encode(array("message" => "Post ID is required."));
        exit();
    }

    // Get comments for the post
    $comments_query = "SELECT 
                        c.id,
                        c.post_id,
                        c.user_id,
                        c.comment_text,
                        c.created_at,
                        u.username,
                        u.full_name,
                        u.profile_picture
                    FROM comments c
                    INNER JOIN users u ON c.user_id = u.id
                    WHERE c.post_id = ?
                    ORDER BY c.created_at ASC";

    $comments_stmt = $db->prepare($comments_query);
    $comments_stmt->bindParam(1, $post_id);
    $comments_stmt->execute();
    $comments_data = $comments_stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format comments data
    $comments = array();
    foreach ($comments_data as $comment) {
        $comments[] = array(
            'id' => $comment['id'],
            'post_id' => $comment['post_id'],
            'user_id' => $comment['user_id'],
            'username' => $comment['username'],
            'full_name' => $comment['full_name'],
            'profile_picture' => $comment['profile_picture'] ?: '',
            'comment_text' => $comment['comment_text'],
            'created_at' => $comment['created_at']
        );
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