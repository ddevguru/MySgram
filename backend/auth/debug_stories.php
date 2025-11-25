<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    echo json_encode([
        'success' => true,
        'message' => 'Debug stories endpoint reached',
        'timestamp' => date('Y-m-d H:i:s'),
        'debug_info' => [
            'request_method' => $_SERVER['REQUEST_METHOD'],
            'request_uri' => $_SERVER['REQUEST_URI'] ?? 'Unknown',
            'headers' => getallheaders(),
            'php_version' => PHP_VERSION
        ]
    ]);
    
    // Test if we can include the required files
    try {
        require_once '../config/database.php';
        echo json_encode(['success' => true, 'message' => 'Database config loaded']);
        
        require_once '../utils/JWT.php';
        echo json_encode(['success' => true, 'message' => 'JWT utils loaded']);
        
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => 'File include error: ' . $e->getMessage()]);
        exit;
    }
    
    // Test database connection
    try {
        $test_query = $pdo->query("SELECT 1 as test");
        $result = $test_query->fetch(PDO::FETCH_ASSOC);
        echo json_encode(['success' => true, 'message' => 'Database connection successful']);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
        exit;
    }
    
    // Test stories table
    try {
        $stories_count = $pdo->query("SELECT COUNT(*) FROM stories")->fetchColumn();
        echo json_encode(['success' => true, 'message' => 'Stories table accessible', 'count' => $stories_count]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => 'Stories table error: ' . $e->getMessage()]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Debug failed: ' . $e->getMessage(),
        'error_details' => [
            'file' => $e->getFile(),
            'line' => $e->getLine(),
            'trace' => $e->getTraceAsString()
        ]
    ]);
}
?> 