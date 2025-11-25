<?php
// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', '../logs/test_upload_config.log');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
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
    // Test PHP configuration
    $php_config = [
        'upload_max_filesize' => ini_get('upload_max_filesize'),
        'post_max_size' => ini_get('post_max_size'),
        'max_execution_time' => ini_get('max_execution_time'),
        'memory_limit' => ini_get('memory_limit'),
        'max_input_time' => ini_get('max_input_time'),
        'file_uploads' => ini_get('file_uploads'),
        'upload_tmp_dir' => ini_get('upload_tmp_dir'),
        'max_file_uploads' => ini_get('max_file_uploads'),
    ];

    // Test directory permissions
    $upload_dirs = [
        '../uploads/',
        '../uploads/posts/',
        '../uploads/stories/',
        '../uploads/profile_photos/',
    ];

    $dir_permissions = [];
    foreach ($upload_dirs as $dir) {
        if (!file_exists($dir)) {
            mkdir($dir, 0777, true);
        }
        $dir_permissions[$dir] = [
            'exists' => file_exists($dir),
            'readable' => is_readable($dir),
            'writable' => is_writable($dir),
            'permissions' => substr(sprintf('%o', fileperms($dir)), -4),
        ];
    }

    // Test file upload capabilities
    $upload_test = [
        'files_array_empty' => empty($_FILES),
        'files_array_contents' => $_FILES,
        'post_array_contents' => $_POST,
        'request_method' => $_SERVER['REQUEST_METHOD'],
        'content_type' => $_SERVER['CONTENT_TYPE'] ?? 'Not set',
        'content_length' => $_SERVER['CONTENT_LENGTH'] ?? 'Not set',
    ];

    // Test if we can create a test file
    $test_file_path = '../uploads/test_write.txt';
    $test_write = file_put_contents($test_file_path, 'Test write at ' . date('Y-m-d H:i:s'));
    if ($test_write !== false) {
        unlink($test_file_path); // Clean up
    }

    $result = [
        'status' => 'success',
        'message' => 'Upload configuration test completed',
        'php_config' => $php_config,
        'dir_permissions' => $dir_permissions,
        'upload_test' => $upload_test,
        'test_write_success' => $test_write !== false,
        'server_info' => [
            'php_version' => PHP_VERSION,
            'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
            'document_root' => $_SERVER['DOCUMENT_ROOT'] ?? 'Unknown',
        ],
        'timestamp' => date('Y-m-d H:i:s'),
    ];

    http_response_code(200);
    echo json_encode($result, JSON_PRETTY_PRINT);

} catch(Exception $e) {
    error_log("Test upload config error: " . $e->getMessage());
    
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Test failed: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s'),
    ]);
}
?> 