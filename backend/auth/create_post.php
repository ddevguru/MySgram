<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
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

// Check if data is not empty
if(!empty($data->token)) {
    try {
        // Verify JWT token
        $decoded = JWT::verify($data->token);
        if (!$decoded) {
            http_response_code(401);
            echo json_encode(array("message" => "Invalid token."));
            exit();
        }
        
        $user_id = $decoded['user_id'];
        
        // Get user by ID
        $user_data = $user->getById($user_id);
        if(!$user_data) {
            http_response_code(404);
            echo json_encode(array("message" => "User not found."));
            exit();
        }
        
        // Validate required fields
        if(empty($data->media_url) || empty($data->media_type)) {
            http_response_code(400);
            echo json_encode(array("message" => "Media URL and type are required."));
            exit();
        }
        
        // Debug logging
        error_log("Create post debug - User ID: $user_id, Media URL: " . $data->media_url . ", Media Type: " . $data->media_type);
        
        // Insert post into database using the correct schema
        $query = "INSERT INTO posts (user_id, caption, media_type, media_url, thumbnail_url, duration, likes_count, comments_count, shares_count, is_public, created_at) 
                  VALUES (?, ?, ?, ?, ?, ?, 0, 0, 0, 1, NOW())";
        
        $stmt = $db->prepare($query);
        if (!$stmt) {
            error_log("Database prepare error: " . print_r($db->errorInfo(), true));
            http_response_code(500);
            echo json_encode(array("message" => "Database prepare error."));
            exit();
        }
        
        // Prepare variables to avoid bindParam reference issues
        $caption = $data->caption ?? '';
        $thumbnail_url = $data->thumbnail_url ?? $data->media_url;
        $duration = $data->duration ?? null;
        
        $stmt->bindParam(1, $user_id);
        $stmt->bindParam(2, $caption);
        $stmt->bindParam(3, $data->media_type);
        $stmt->bindParam(4, $data->media_url);
        $stmt->bindParam(5, $thumbnail_url);
        $stmt->bindParam(6, $duration);
        
        if($stmt->execute()) {
            $post_id = $db->lastInsertId();
            error_log("Post created successfully with ID: $post_id");
            
            // Update user's posts count and streak
            $today = date('Y-m-d');
            $yesterday = date('Y-m-d', strtotime('-1 day'));
            
            // Get current user data
            $user_query = "SELECT streak_count, last_post_date FROM users WHERE id = ?";
            $user_stmt = $db->prepare($user_query);
            $user_stmt->bindParam(1, $user_id);
            $user_stmt->execute();
            $user_data = $user_stmt->fetch(PDO::FETCH_ASSOC);
            
            $current_streak = $user_data['streak_count'] ?? 0;
            $last_post_date = $user_data['last_post_date'];
            
            // Calculate new streak
            $new_streak = 1; // Default to 1 for first post
            if ($last_post_date) {
                if ($last_post_date == $today) {
                    // Already posted today, keep current streak
                    $new_streak = $current_streak;
                } elseif ($last_post_date == $yesterday) {
                    // Posted yesterday, increment streak
                    $new_streak = $current_streak + 1;
                } else {
                    // Missed a day, reset streak to 1
                    $new_streak = 1;
                }
            } else {
                // First post ever, set streak to 1
                $new_streak = 1;
            }
            
            // For testing: if user has posts, set streak to posts count
            if ($current_streak == 0 && $user_data['posts_count'] > 0) {
                $new_streak = $user_data['posts_count'] + 1;
            }
            
            // Update user's posts count and streak
            $update_query = "UPDATE users SET posts_count = posts_count + 1, streak_count = ?, last_post_date = ? WHERE id = ?";
            $update_stmt = $db->prepare($update_query);
            $update_stmt->bindParam(1, $new_streak);
            $update_stmt->bindParam(2, $today);
            $update_stmt->bindParam(3, $user_id);
            $update_stmt->execute();
            
            // Get the created post
            $post_query = "SELECT * FROM posts WHERE id = ?";
            $post_stmt = $db->prepare($post_query);
            $post_stmt->bindParam(1, $post_id);
            $post_stmt->execute();
            $post = $post_stmt->fetch(PDO::FETCH_ASSOC);
            
            http_response_code(201);
            echo json_encode(array(
                "message" => "Post created successfully.",
                "post" => $post
            ));
        } else {
            error_log("Database execute error: " . print_r($stmt->errorInfo(), true));
            http_response_code(503);
            echo json_encode(array("message" => "Unable to create post."));
        }
        
    } catch(Exception $e) {
        http_response_code(500);
        echo json_encode(array("message" => "Server error: " . $e->getMessage()));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Token is required."));
}
?> 