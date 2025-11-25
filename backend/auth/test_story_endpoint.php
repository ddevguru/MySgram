<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';

try {
    echo json_encode([
        'success' => true,
        'message' => 'Story endpoint test successful',
        'timestamp' => date('Y-m-d H:i:s'),
        'server_info' => [
            'php_version' => PHP_VERSION,
            'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
            'request_method' => $_SERVER['REQUEST_METHOD'],
            'request_uri' => $_SERVER['REQUEST_URI'] ?? 'Unknown'
        ]
    ]);
    
    // Test database connection
    try {
        $test_query = $pdo->query("SELECT 1 as test");
        $result = $test_query->fetch(PDO::FETCH_ASSOC);
        
        if ($result && $result['test'] == 1) {
            echo json_encode([
                'success' => true,
                'message' => 'Database connection successful',
                'database_test' => '✅ Connected'
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Database test failed',
                'database_test' => '❌ Failed'
            ]);
        }
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Database connection failed: ' . $e->getMessage(),
            'database_test' => '❌ Error'
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Test failed: ' . $e->getMessage()
    ]);
}
?> 