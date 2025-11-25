<?php
// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', '../logs/simple_upload_test.log');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Create logs directory if it doesn't exist
if (!file_exists('../logs')) {
    mkdir('../logs', 0777, true);
}

try {
    error_log("=== SIMPLE UPLOAD TEST START ===");
    error_log("Request Method: " . $_SERVER['REQUEST_METHOD']);
    error_log("Content Type: " . ($_SERVER['CONTENT_TYPE'] ?? 'Not set'));
    error_log("Content Length: " . ($_SERVER['CONTENT_LENGTH'] ?? 'Not set'));
    
    // Log all request data
    error_log("FILES array: " . print_r($_FILES, true));
    error_log("POST array: " . print_r($_POST, true));
    error_log("GET array: " . print_r($_GET, true));
    error_log("REQUEST array: " . print_r($_REQUEST, true));
    
    // Check if any file was uploaded
    $uploaded_files = [];
    if (!empty($_FILES)) {
        foreach ($_FILES as $key => $file) {
            $uploaded_files[$key] = [
                'name' => $file['name'] ?? 'No name',
                'size' => $file['size'] ?? 0,
                'type' => $file['type'] ?? 'No type',
                'error' => $file['error'] ?? 'No error code',
                'tmp_name' => $file['tmp_name'] ?? 'No temp name',
                'error_message' => getUploadErrorMessage($file['error'] ?? 0),
            ];
        }
    }
    
    $result = [
        'status' => 'success',
        'message' => 'Simple upload test completed',
        'request_method' => $_SERVER['REQUEST_METHOD'],
        'content_type' => $_SERVER['CONTENT_TYPE'] ?? 'Not set',
        'content_length' => $_SERVER['CONTENT_LENGTH'] ?? 'Not set',
        'files_received' => !empty($_FILES),
        'files_count' => count($_FILES),
        'uploaded_files' => $uploaded_files,
        'post_data' => $_POST,
        'timestamp' => date('Y-m-d H:i:s'),
    ];

    http_response_code(200);
    echo json_encode($result, JSON_PRETTY_PRINT);

} catch(Exception $e) {
    error_log("Simple upload test error: " . $e->getMessage());
    
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Test failed: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s'),
    ]);
}

function getUploadErrorMessage($error_code) {
    $error_messages = [
        UPLOAD_ERR_OK => 'No error',
        UPLOAD_ERR_INI_SIZE => 'File too large (exceeds upload_max_filesize)',
        UPLOAD_ERR_FORM_SIZE => 'File too large (exceeds MAX_FILE_SIZE)',
        UPLOAD_ERR_PARTIAL => 'File upload was incomplete',
        UPLOAD_ERR_NO_FILE => 'No file was uploaded',
        UPLOAD_ERR_NO_TMP_DIR => 'Missing temporary folder',
        UPLOAD_ERR_CANT_WRITE => 'Failed to write file to disk',
        UPLOAD_ERR_EXTENSION => 'File upload stopped by extension',
    ];
    
    return $error_messages[$error_code] ?? 'Unknown error';
}

error_log("=== SIMPLE UPLOAD TEST END ===");
?> 