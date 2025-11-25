<?php
// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', '../logs/story_upload_errors.log');

// Set PHP limits for large file uploads
ini_set('upload_max_filesize', '1G');
ini_set('post_max_size', '1G');
ini_set('max_execution_time', 600);
ini_set('memory_limit', '1G');

// Create logs directory if it doesn't exist
if (!file_exists('../logs')) {
    mkdir('../logs', 0777, true);
}

// Log the request
error_log("=== STORY UPLOAD REQUEST START ===");
error_log("Request Method: " . $_SERVER['REQUEST_METHOD']);
error_log("Content Type: " . ($_SERVER['CONTENT_TYPE'] ?? 'Not set'));
error_log("Content Length: " . ($_SERVER['CONTENT_LENGTH'] ?? 'Not set'));
error_log("Upload Max Filesize: " . ini_get('upload_max_filesize'));
error_log("Post Max Size: " . ini_get('post_max_size'));
error_log("Memory Limit: " . ini_get('memory_limit'));

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
    error_log("=== CHECKING FILES ARRAY ===");
    error_log("FILES array contents: " . print_r($_FILES, true));
    error_log("POST array contents: " . print_r($_POST, true));
    
    // Check if it's a POST request
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        error_log("Invalid request method: " . $_SERVER['REQUEST_METHOD']);
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
        error_log("No token provided");
        http_response_code(401);
        echo json_encode(array("message" => "Token is required"));
        exit();
    }

    // Verify token
    $jwt = new JWT();
    $decoded = $jwt->verify($token);
    if (!$decoded) {
        error_log("Invalid token provided");
        http_response_code(401);
        echo json_encode(array("message" => "Invalid token"));
        exit();
    }

    $user_id = $decoded['user_id'];
    error_log("User ID: " . $user_id);

    // Check if file was uploaded
    if (!isset($_FILES['story_media']) || $_FILES['story_media']['error'] !== UPLOAD_ERR_OK) {
        $error_code = $_FILES['story_media']['error'] ?? 'NO_FILE';
        $error_messages = [
            UPLOAD_ERR_INI_SIZE => 'File too large (exceeds upload_max_filesize)',
            UPLOAD_ERR_FORM_SIZE => 'File too large (exceeds MAX_FILE_SIZE)',
            UPLOAD_ERR_PARTIAL => 'File upload was incomplete',
            UPLOAD_ERR_NO_FILE => 'No file was uploaded',
            UPLOAD_ERR_NO_TMP_DIR => 'Missing temporary folder',
            UPLOAD_ERR_CANT_WRITE => 'Failed to write file to disk',
            UPLOAD_ERR_EXTENSION => 'File upload stopped by extension',
            'NO_FILE' => 'No file provided'
        ];
        
        error_log("Story upload error: " . ($error_messages[$error_code] ?? 'Unknown error'));
        error_log("Error code: " . $error_code);
        
        http_response_code(400);
        echo json_encode(array(
            "message" => "File upload error: " . ($error_messages[$error_code] ?? 'Unknown error'),
            "error_code" => $error_code,
            "debug_info" => [
                "upload_max_filesize" => ini_get('upload_max_filesize'),
                "post_max_size" => ini_get('post_max_size'),
                "max_execution_time" => ini_get('max_execution_time'),
                "memory_limit" => ini_get('memory_limit'),
                "files_array" => $_FILES
            ]
        ));
        exit();
    }

    $file = $_FILES['story_media'];
    $caption = $_POST['caption'] ?? '';
    $media_type = $_POST['media_type'] ?? 'image';
    $duration = $_POST['duration'] ?? null;

    error_log("=== STORY FILE DETAILS ===");
    error_log("File name: " . $file['name']);
    error_log("File size: " . $file['size']);
    error_log("File type: " . $file['type']);
    error_log("Temp path: " . $file['tmp_name']);
    error_log("Error code: " . $file['error']);
    error_log("Caption: " . $caption);
    error_log("Media type: " . $media_type);
    error_log("Duration: " . $duration);

    // Validate file type
    $allowed_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'video/mp4', 'video/avi', 'video/mov', 'video/3gp', 'video/mkv', 'video/webm'];
    $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'avi', 'mov', '3gp', 'mkv', 'webm'];
    
    // Check if mime_content_type function exists and works
    if (function_exists('mime_content_type')) {
        $file_type = mime_content_type($file['tmp_name']);
        error_log("MIME type detected: " . $file_type);
    } else {
        $file_type = $file['type'];
        error_log("Using file type from upload: " . $file_type);
    }
    
    // If MIME type is application/octet-stream, try to detect from file extension
    if ($file_type === 'application/octet-stream') {
        $file_extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        error_log("File extension detected: " . $file_extension);
        
        // Map extensions to MIME types
        $extension_mime_map = [
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'png' => 'image/png',
            'gif' => 'image/gif',
            'mp4' => 'video/mp4',
            'avi' => 'video/avi',
            'mov' => 'video/mov',
            '3gp' => 'video/3gp',
            'mkv' => 'video/mkv',
            'webm' => 'video/webm',
        ];
        
        if (isset($extension_mime_map[$file_extension])) {
            $file_type = $extension_mime_map[$file_extension];
            error_log("MIME type mapped from extension: " . $file_type);
        }
    }
    
    // Check if file type is allowed
    if (!in_array($file_type, $allowed_types)) {
        // Also check file extension as fallback
        $file_extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        if (!in_array($file_extension, $allowed_extensions)) {
            error_log("Invalid file type: " . $file_type . " and extension: " . $file_extension);
            http_response_code(400);
            echo json_encode(array(
                "message" => "Invalid file type. Only images and videos allowed",
                "debug_info" => [
                    "detected_mime_type" => $file_type,
                    "file_extension" => $file_extension,
                    "original_type" => $file['type'],
                    "file_name" => $file['name']
                ]
            ));
            exit();
        } else {
            error_log("File type rejected but extension allowed: " . $file_extension . ". Proceeding with upload.");
        }
    }

    // Validate file size (max 1GB for stories)
    $max_size = 1024 * 1024 * 1024; // 1GB
    if ($file['size'] > $max_size) {
        error_log("File too large: " . $file['size'] . " bytes");
        http_response_code(400);
        echo json_encode(array("message" => "File too large. Maximum size is 1GB"));
        exit();
    }

    // Create uploads directory if it doesn't exist
    $upload_dir = '../uploads/stories/';
    if (!file_exists($upload_dir)) {
        error_log("Creating upload directory: " . $upload_dir);
        if (!mkdir($upload_dir, 0777, true)) {
            error_log("Failed to create upload directory");
            http_response_code(500);
            echo json_encode(array("message" => "Failed to create upload directory"));
            exit();
        }
    }

    // Generate unique filename
    $file_extension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $filename = 'story_' . time() . '_' . $user_id . '.' . $file_extension;
    $filepath = $upload_dir . $filename;
    
    error_log("Generated filename: " . $filename);
    error_log("Full filepath: " . $filepath);

    // Move uploaded file
    if (!move_uploaded_file($file['tmp_name'], $filepath)) {
        error_log("Failed to move uploaded file from " . $file['tmp_name'] . " to " . $filepath);
        error_log("File exists check: " . (file_exists($file['tmp_name']) ? 'Yes' : 'No'));
        error_log("Directory writable: " . (is_writable($upload_dir) ? 'Yes' : 'No'));
        
        http_response_code(500);
        echo json_encode(array("message" => "Failed to save file"));
        exit();
    }

    error_log("File successfully moved to: " . $filepath);

    // Save story to database
    $media_url = 'https://mysgram.com/uploads/stories/' . $filename;
    
    // Ensure stories table exists with all required columns
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS stories (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            media_url TEXT NOT NULL,
            media_type VARCHAR(50) DEFAULT 'image',
            caption TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL 24 HOUR),
            is_active BOOLEAN DEFAULT TRUE,
            INDEX idx_user (user_id),
            INDEX idx_created (created_at),
            INDEX idx_expires (expires_at)
        )
    ");

    // Add is_active column if it doesn't exist (for existing tables)
    try {
        $pdo->exec("ALTER TABLE stories ADD COLUMN is_active BOOLEAN DEFAULT TRUE");
    } catch (PDOException $e) {
        // Column already exists, ignore error
        if (strpos($e->getMessage(), 'Duplicate column name') === false) {
            throw $e;
        }
    }

    // Update existing stories to be active if they don't have the column set
    $pdo->exec("UPDATE stories SET is_active = TRUE WHERE is_active IS NULL");
    
    $insert_query = "INSERT INTO stories (user_id, media_url, media_type, caption) VALUES (?, ?, ?, ?)";
    $insert_stmt = $pdo->prepare($insert_query);
    $insert_stmt->bindParam(1, $user_id);
    $insert_stmt->bindParam(2, $media_url);
    $insert_stmt->bindParam(3, $media_type);
    $insert_stmt->bindParam(4, $caption);

    if ($insert_stmt->execute()) {
        $story_id = $pdo->lastInsertId();
        
        // Create notifications for followers
        try {
            $followers_query = "SELECT follower_id FROM follows WHERE following_id = ?";
            $followers_stmt = $pdo->prepare($followers_query);
            $followers_stmt->bindParam(1, $user_id);
            $followers_stmt->execute();
            $followers = $followers_stmt->fetchAll(PDO::FETCH_COLUMN);
            
            if (!empty($followers)) {
                $notification_query = "INSERT INTO notifications (recipient_id, sender_id, type, message, post_id) VALUES (?, ?, 'story', 'posted a new story', ?)";
                $notification_stmt = $pdo->prepare($notification_query);
                
                foreach ($followers as $follower_id) {
                    $notification_stmt->bindParam(1, $follower_id);
                    $notification_stmt->bindParam(2, $user_id);
                    $notification_stmt->bindParam(3, $story_id);
                    $notification_stmt->execute();
                }
                
                error_log("Created notifications for " . count($followers) . " followers");
            }
        } catch (Exception $e) {
            error_log("Failed to create notifications: " . $e->getMessage());
        }
        
        error_log("=== STORY UPLOAD SUCCESS ===");
        error_log("Story ID: " . $story_id);
        error_log("Media URL: " . $media_url);
        
        http_response_code(201);
        echo json_encode(array(
            "message" => "Story uploaded successfully",
            "story_id" => $story_id,
            "media_url" => $media_url,
            "media_type" => $media_type
        ));
    } else {
        error_log("Failed to save story to database");
        error_log("Database error: " . print_r($insert_stmt->errorInfo(), true));
        http_response_code(500);
        echo json_encode(array("message" => "Failed to save story to database"));
    }

} catch(Exception $e) {
    error_log("Exception occurred: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    
    http_response_code(500);
    echo json_encode(array("message" => "Server error: " . $e->getMessage()));
}

error_log("=== STORY UPLOAD REQUEST END ===");
?> 