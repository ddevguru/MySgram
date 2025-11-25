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
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
    $offset = ($page - 1) * $limit;

    // Get posts with user information and like status
    $posts_query = "SELECT 
                        p.id,
                        p.user_id,
                        p.media_url,
                        p.media_type,
                        p.caption,
                        p.likes_count,
                        p.comments_count,
                        p.shares_count,
                        p.is_public,
                        p.created_at,
                        u.username,
                        u.full_name,
                        u.profile_picture,
                        CASE 
                            WHEN l.id IS NOT NULL THEN 1 
                            ELSE 0 
                        END as is_liked
                    FROM posts p
                    INNER JOIN users u ON p.user_id = u.id
                    LEFT JOIN likes l ON p.id = l.post_id AND l.user_id = ?
                    WHERE p.is_public = 1
                    ORDER BY p.created_at DESC
                    LIMIT ? OFFSET ?";

    $posts_stmt = $db->prepare($posts_query);
    $posts_stmt->bindParam(1, $user_id);
    $posts_stmt->bindParam(2, $limit, PDO::PARAM_INT);
    $posts_stmt->bindParam(3, $offset, PDO::PARAM_INT);
    $posts_stmt->execute();
    $posts_data = $posts_stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format posts data
    $posts = array();
    foreach ($posts_data as $post) {
        $posts[] = array(
            'id' => $post['id'],
            'user_id' => $post['user_id'],
            'username' => $post['username'],
            'full_name' => $post['full_name'],
            'profile_picture' => $post['profile_picture'] ?: '',
            'media_url' => $post['media_url'],
            'media_type' => $post['media_type'],
            'caption' => $post['caption'],
            'likes_count' => (int)$post['likes_count'],
            'comments_count' => (int)$post['comments_count'],
            'shares_count' => (int)$post['shares_count'],
            'is_public' => (bool)$post['is_public'],
            'created_at' => $post['created_at'],
            'is_liked' => (bool)$post['is_liked']
        );
    }

    // Get total count
    $count_query = "SELECT COUNT(*) as total FROM posts WHERE is_public = 1";
    $count_stmt = $db->prepare($count_query);
    $count_stmt->execute();
    $total_count = $count_stmt->fetch(PDO::FETCH_ASSOC)['total'];

    http_response_code(200);
    echo json_encode(array(
        "message" => "Posts retrieved successfully.",
        "posts" => $posts,
        "total_posts" => (int)$total_count,
        "current_page" => $page,
        "total_pages" => ceil($total_count / $limit)
    ));

} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Server error: " . $e->getMessage()));
}
?> 