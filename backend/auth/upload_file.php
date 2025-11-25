<?php
// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', '../logs/upload_errors.log');

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
error_log("=== UPLOAD FILE REQUEST START ===");
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

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

try {
    error_log("=== CHECKING FILES ARRAY ===");
    error_log("FILES array contents: " . print_r($_FILES, true));
    
    // Check if file was uploaded
    if (!isset($_FILES['media']) || $_FILES['media']['error'] !== UPLOAD_ERR_OK) {
        $error_code = $_FILES['media']['error'] ?? 'NO_FILE';
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
        
        error_log("File upload error: " . ($error_messages[$error_code] ?? 'Unknown error'));
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

    $file = $_FILES['media'];
    error_log("=== FILE DETAILS ===");
    error_log("File name: " . $file['name']);
    error_log("File size: " . $file['size']);
    error_log("File type: " . $file['type']);
    error_log("Temp path: " . $file['tmp_name']);
    error_log("Error code: " . $file['error']);

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

    // Validate file size (max 1GB for posts)
    $max_size = 1024 * 1024 * 1024; // 1GB
    if ($file['size'] > $max_size) {
        error_log("File too large: " . $file['size'] . " bytes");
        http_response_code(400);
        echo json_encode(array("message" => "File too large. Maximum size is 1GB"));
        exit();
    }

    // Create uploads directory if it doesn't exist
    $upload_dir = '../uploads/posts/';
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
    $filename = 'post_' . time() . '_' . uniqid() . '.' . $file_extension;
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

    // Return the public URL
    $media_url = 'https://devloperwala.in/MySgram/backend/uploads/posts/' . $filename;
    
    error_log("=== UPLOAD SUCCESS ===");
    error_log("Media URL: " . $media_url);
    
    http_response_code(201);
    echo json_encode(array(
        "message" => "File uploaded successfully",
        "media_url" => $media_url,
        "file_type" => $file_type,
        "file_size" => $file['size']
    ));

} catch(Exception $e) {
    error_log("Exception occurred: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    
    http_response_code(500);
    echo json_encode(array("message" => "Server error: " . $e->getMessage()));
}

error_log("=== UPLOAD FILE REQUEST END ===");
?> 