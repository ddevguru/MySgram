<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'test_connection_error.log');

// Log the request
error_log("=== TEST CONNECTION REQUEST START ===");
error_log("Request Method: " . $_SERVER['REQUEST_METHOD']);
error_log("Request Time: " . date('Y-m-d H:i:s'));

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    error_log("=== TESTING INCLUDES ===");
    
    // Test database config
    error_log("Including database config...");
    require_once '../config/database.php';
    error_log("Database config included successfully");
    
    // Test JWT config
    error_log("Including JWT config...");
    require_once '../config/config.php';
    error_log("JWT config included successfully");
    
    // Test JWT utils
    error_log("Including JWT utils...");
    require_once '../utils/JWT.php';
    error_log("JWT utils included successfully");
    
    error_log("=== TESTING DATABASE CONNECTION ===");
    
    // Test if global PDO connection exists
    if (!isset($pdo) || !$pdo) {
        error_log("Global PDO connection not available, creating new one...");
        $database = new Database();
        $pdo = $database->getConnection();
    }
    
    if (!$pdo) {
        throw new Exception("Failed to create database connection");
    }
    
    error_log("Database connection created successfully");
    
    // Test a simple query
    error_log("Testing simple query...");
    $testQuery = "SELECT COUNT(*) as count FROM users";
    $stmt = $pdo->prepare($testQuery);
    
    if (!$stmt) {
        $error = "Database prepare error: " . implode(", ", $pdo->errorInfo());
        error_log($error);
        throw new Exception($error);
    }
    
    $result = $stmt->execute();
    if (!$result) {
        $error = "Database execute error: " . implode(", ", $stmt->errorInfo());
        error_log($error);
        throw new Exception($error);
    }
    
    $data = $stmt->fetch(PDO::FETCH_ASSOC);
    error_log("Query executed successfully. User count: " . $data['count']);
    
    // Test JWT functionality
    error_log("=== TESTING JWT ===");
    $testPayload = ['user_id' => 1, 'username' => 'test'];
    $token = JWT::generate($testPayload);
    error_log("JWT token generated: " . substr($token, 0, 50) . "...");
    
    $decoded = JWT::verify($token);
    if ($decoded) {
        error_log("JWT verification successful: " . print_r($decoded, true));
    } else {
        error_log("JWT verification failed");
    }
    
    error_log("=== SENDING SUCCESS RESPONSE ===");
    $response = [
        'success' => true,
        'message' => 'All tests passed successfully',
        'database_connection' => 'OK',
        'jwt_functionality' => 'OK',
        'user_count' => $data['count'],
        'test_token' => substr($token, 0, 50) . "..."
    ];
    
    error_log("Response: " . json_encode($response));
    echo json_encode($response);
    error_log("=== TEST CONNECTION REQUEST END ===");
    
} catch (Exception $e) {
    error_log("=== ERROR OCCURRED ===");
    error_log("Error message: " . $e->getMessage());
    error_log("Error file: " . $e->getFile());
    error_log("Error line: " . $e->getLine());
    error_log("Error trace: " . $e->getTraceAsString());
    
    http_response_code(500);
    $errorResponse = [
        'error' => 'Test failed',
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ];
    echo json_encode($errorResponse);
    error_log("Error response sent: " . json_encode($errorResponse));
}
?> 