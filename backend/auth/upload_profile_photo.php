<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Increase upload limits
ini_set('upload_max_filesize', '30M');
ini_set('post_max_size', '30M');
ini_set('max_execution_time', 300);
ini_set('memory_limit', '256M');

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

    // Check if file was uploaded
    if (!isset($_FILES['profile_photo'])) {
        http_response_code(400);
        echo json_encode(array("message" => "No file uploaded."));
        exit();
    }

    $uploaded_file = $_FILES['profile_photo'];
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
            "error_code" => $upload_error,
            "upload_max_filesize" => ini_get('upload_max_filesize'),
            "post_max_size" => ini_get('post_max_size')
        ));
        exit();
    }

    $file_name = $uploaded_file['name'];
    $file_tmp = $uploaded_file['tmp_name'];
    $file_size = $uploaded_file['size'];

    // Basic file validation
    $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif'];
    $file_extension = strtolower(pathinfo($file_name, PATHINFO_EXTENSION));
    
    if (!in_array($file_extension, $allowed_extensions)) {
        http_response_code(400);
        echo json_encode(array("message" => "Invalid file type. Only JPG, PNG, GIF allowed."));
        exit();
    }

    if ($file_size > 5 * 1024 * 1024) { // 5MB limit
        http_response_code(400);
        echo json_encode(array("message" => "File too large. Maximum 5MB allowed."));
        exit();
    }

    // Create uploads directory if it doesn't exist
    $upload_dir = '../uploads/profile_photos/';
    if (!file_exists($upload_dir)) {
        if (!mkdir($upload_dir, 0777, true)) {
            http_response_code(500);
            echo json_encode(array("message" => "Failed to create upload directory."));
            exit();
        }
    }

    // Generate unique filename
    $new_filename = 'profile_' . $user_id . '_' . time() . '.' . $file_extension;
    $upload_path = $upload_dir . $new_filename;

    // Move uploaded file
    if (move_uploaded_file($file_tmp, $upload_path)) {
        // Generate public URL
        $public_url = 'https://devloperwala.in/MySgram/backend/uploads/profile_photos/' . $new_filename;
        
        // Update user's profile picture in database
        $user->id = $user_id;
        $update_fields = array('profile_picture' => $public_url);
        
        if ($user->updateFields($update_fields)) {
            // Get updated user data
            $updated_user = $user->getById($user_id);
            
            http_response_code(200);
            echo json_encode(array(
                "message" => "Profile photo uploaded successfully.",
                "profile_picture" => $public_url,
                "user" => $updated_user
            ));
        } else {
            http_response_code(500);
            echo json_encode(array("message" => "Failed to update profile picture in database."));
        }
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to save uploaded file."));
    }

} catch(Exception $e) {
    error_log("Profile photo upload error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(array("message" => "Server error: " . $e->getMessage()));
}
?> 