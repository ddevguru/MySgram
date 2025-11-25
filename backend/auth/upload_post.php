<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Increase upload limits for videos
ini_set('upload_max_filesize', '50M');
ini_set('post_max_size', '50M');
ini_set('max_execution_time', 600);
ini_set('memory_limit', '512M');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Check if it's a POST request
if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed. Use POST."));
    exit();
}

try {
    // Include database and object files
    include_once '../config/database.php';
    include_once '../models/User.php';
    include_once '../utils/JWT.php';

    // Get database connection
    $database = new Database();
    $db = $database->getConnection();

    // Prepare user object
    $user = new User($db);

    // Get token from POST data
    $token = null;
    if (isset($_POST['token'])) {
        $token = $_POST['token'];
    } else {
        http_response_code(401);
        echo json_encode(array("message" => "Token is required."));
        exit();
    }

    // Verify JWT token
    $decoded = JWT::verify($token);
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

    // Check if media file was uploaded
    if (!isset($_FILES['media'])) {
        http_response_code(400);
        echo json_encode(array("message" => "No media file uploaded."));
        exit();
    }

    $uploaded_file = $_FILES['media'];
    $upload_error = $uploaded_file['error'];

    // Handle different upload errors
    if ($upload_error !== UPLOAD_ERR_OK) {
        $error_messages = array(
            UPLOAD_ERR_INI_SIZE => "File too large (exceeds upload_max_filesize)",
            UPLOAD_ERR_FORM_SIZE => "File too large (exceeds MAX_FILE_SIZE)",
            UPLOAD_ERR_PARTIAL => "File was only partially uploaded",
            UPLOAD_ERR_NO_FILE => "No file was uploaded",
            UPLOAD_ERR_NO_TMP_DIR => "Missing temporary folder",
            UPLOAD_ERR_CANT_WRITE => "Failed to write file to disk",
            UPLOAD_ERR_EXTENSION => "A PHP extension stopped the file upload"
        );
        
        $error_message = isset($error_messages[$upload_error]) ? $error_messages[$upload_error] : "Unknown upload error";
        
        http_response_code(400);
        echo json_encode(array(
            "message" => "File upload error: " . $error_message,
            "error_code" => $upload_error
        ));
        exit();
    }

    $file_name = $uploaded_file['name'];
    $file_tmp = $uploaded_file['tmp_name'];
    $file_size = $uploaded_file['size'];
    $file_type = $uploaded_file['type'];
    
    // Debug logging
    error_log("Upload debug - File name: $file_name, Type: $file_type, Size: $file_size");

    // Determine media type from file extension and MIME type
    $media_type = 'image'; // default
    $allowed_image_extensions = ['jpg', 'jpeg', 'png', 'gif'];
    $allowed_video_extensions = ['mp4', 'avi', 'mov', 'wmv', 'flv'];
    $allowed_image_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
    $allowed_video_types = ['video/mp4', 'video/avi', 'video/mov', 'video/wmv', 'video/flv'];

    // Check by file extension first
    if (in_array($file_extension, $allowed_image_extensions)) {
        $media_type = 'image';
    } elseif (in_array($file_extension, $allowed_video_extensions)) {
        $media_type = 'video';
    } else {
        // Fallback to MIME type check
        if (in_array($file_type, $allowed_image_types)) {
            $media_type = 'image';
        } elseif (in_array($file_type, $allowed_video_types)) {
            $media_type = 'video';
        } else {
            http_response_code(400);
            echo json_encode(array(
                "message" => "Invalid file type. Only images and videos allowed.",
                "file_extension" => $file_extension,
                "file_type" => $file_type,
                "file_name" => $file_name
            ));
            exit();
        }
    }

    // File size validation
    $max_size = ($media_type == 'video') ? 50 * 1024 * 1024 : 10 * 1024 * 1024; // 50MB for videos, 10MB for images
    if ($file_size > $max_size) {
        http_response_code(400);
        echo json_encode(array("message" => "File too large. Maximum " . ($max_size / 1024 / 1024) . "MB allowed for " . $media_type . "s."));
        exit();
    }

    // Create uploads directory if it doesn't exist
    $upload_dir = '../uploads/posts/';
    if (!file_exists($upload_dir)) {
        if (!mkdir($upload_dir, 0777, true)) {
            http_response_code(500);
            echo json_encode(array("message" => "Failed to create upload directory."));
            exit();
        }
    }

    // Generate unique filename
    $file_extension = strtolower(pathinfo($file_name, PATHINFO_EXTENSION));
    $new_filename = 'post_' . $user_id . '_' . time() . '_' . uniqid() . '.' . $file_extension;
    $upload_path = $upload_dir . $new_filename;

    // Move uploaded file
    if (move_uploaded_file($file_tmp, $upload_path)) {
        // Generate public URL
        $public_url = 'https://devloperwala.in/MySgram/backend/uploads/posts/' . $new_filename;
        
        // Get caption from POST data
        $caption = isset($_POST['caption']) ? $_POST['caption'] : '';
        
        // For videos, we might need to generate thumbnail later
        $thumbnail_url = null;
        if ($media_type == 'video') {
            // For now, use the same URL as thumbnail
            $thumbnail_url = $public_url;
        }
        
        // Insert post into database
        $query = "INSERT INTO posts (user_id, caption, media_type, media_url, thumbnail_url, created_at) 
                  VALUES (?, ?, ?, ?, ?, NOW())";
        $stmt = $db->prepare($query);
        $stmt->bindParam(1, $user_id);
        $stmt->bindParam(2, $caption);
        $stmt->bindParam(3, $media_type);
        $stmt->bindParam(4, $public_url);
        $stmt->bindParam(5, $thumbnail_url);
        
        if($stmt->execute()) {
            $post_id = $db->lastInsertId();
            
            // Update user's posts count
            $update_query = "UPDATE users SET posts_count = posts_count + 1 WHERE id = ?";
            $update_stmt = $db->prepare($update_query);
            $update_stmt->bindParam(1, $user_id);
            $update_stmt->execute();
            
            // Create notifications for followers about new post
            try {
                $followers_query = "SELECT follower_id FROM follows WHERE following_id = ?";
                $followers_stmt = $db->prepare($followers_query);
                $followers_stmt->bindParam(1, $user_id);
                $followers_stmt->execute();
                $followers = $followers_stmt->fetchAll(PDO::FETCH_COLUMN);
                
                foreach ($followers as $follower_id) {
                    $notification_query = "INSERT INTO notifications (recipient_id, sender_id, type, message, post_id) VALUES (?, ?, 'post', 'posted something new', ?)";
                    $notification_stmt = $db->prepare($notification_query);
                    $notification_stmt->bindParam(1, $follower_id);
                    $notification_stmt->bindParam(2, $user_id);
                    $notification_stmt->bindParam(3, $post_id);
                    $notification_stmt->execute();
                }
            } catch (Exception $e) {
                error_log("Failed to create post notifications: " . $e->getMessage());
            }
            
            // Get the created post
            $post_query = "SELECT * FROM posts WHERE id = ?";
            $post_stmt = $db->prepare($post_query);
            $post_stmt->bindParam(1, $post_id);
            $post_stmt->execute();
            $post = $post_stmt->fetch(PDO::FETCH_ASSOC);
            
            http_response_code(201);
            echo json_encode(array(
                "message" => "Post uploaded successfully.",
                "post" => $post,
                "media_url" => $public_url,
                "media_type" => $media_type
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("message" => "Failed to save post to database."));
        }
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to save uploaded file."));
    }

} catch(Exception $e) {
    error_log("Post upload error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(array("message" => "Server error: " . $e->getMessage()));
}
?> 