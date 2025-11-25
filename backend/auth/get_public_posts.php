<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'get_public_posts_error.log');

// Log the request
error_log("=== GET PUBLIC POSTS REQUEST START ===");
error_log("Request Method: " . $_SERVER['REQUEST_METHOD']);
error_log("Request Time: " . date('Y-m-d H:i:s'));
error_log("Request URI: " . $_SERVER['REQUEST_URI']);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';
require_once '../utils/JWT.php';

try {
    error_log("=== INCLUDING FILES ===");
    require_once '../config/database.php';
    error_log("Database config included successfully");
    require_once '../utils/JWT.php';
    error_log("JWT utils included successfully");
    
    // Get authorization header
    $headers = getallheaders();
    error_log("Headers received: " . print_r($headers, true));
    
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';
    error_log("Auth header: " . $authHeader);
    
    if (empty($authHeader) || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
        error_log("No valid authorization header found");
        http_response_code(401);
        echo json_encode(['error' => 'No token provided']);
        exit;
    }
    
    $token = $matches[1];
    error_log("Token extracted: " . substr($token, 0, 20) . "...");
    
    // Verify token
    error_log("=== VERIFYING TOKEN ===");
    $decoded = JWT::verify($token);
    if (!$decoded) {
        error_log("Token verification failed");
        http_response_code(401);
        echo json_encode(['error' => 'Invalid token']);
        exit;
    }
    
    error_log("Token verified successfully");
    $currentUserId = $decoded['user_id'];
    error_log("Current user ID: " . $currentUserId);
    
    // Get all public posts with user information
    $query = "
        SELECT 
            p.*,
            u.username,
            u.full_name,
            u.profile_picture
        FROM posts p
        JOIN users u ON p.user_id = u.id
        WHERE p.is_public = 1
        ORDER BY p.created_at DESC
    ";
    
    error_log("=== EXECUTING QUERY ===");
    error_log("SQL Query: " . $query);
    
    $stmt = $pdo->prepare($query);
    if (!$stmt) {
        $error = "Database prepare error: " . implode(", ", $pdo->errorInfo());
        error_log($error);
        throw new Exception($error);
    }
    
    error_log("Statement prepared successfully");
    
    $result = $stmt->execute();
    if (!$result) {
        $error = "Database execute error: " . implode(", ", $stmt->errorInfo());
        error_log($error);
        throw new Exception($error);
    }
    
    error_log("Query executed successfully");
    
    $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    error_log("Found " . count($posts) . " posts");
    error_log("Posts data: " . print_r($posts, true));
    
    // Format the response
    $formattedPosts = [];
    foreach ($posts as $post) {
        $formattedPosts[] = [
            'id' => $post['id'],
            'user_id' => $post['user_id'],
            'username' => $post['username'],
            'full_name' => $post['full_name'],
            'profile_picture' => $post['profile_picture'],
            'media_url' => $post['media_url'],
            'media_type' => $post['media_type'],
            'caption' => $post['caption'],
            'likes_count' => 0, // Default value
            'comments_count' => 0, // Default value
            'created_at' => $post['created_at'],
            'is_following' => false // Default value
        ];
    }
    
    error_log("=== SENDING RESPONSE ===");
    $response = [
        'success' => true,
        'message' => 'Public posts retrieved successfully',
        'posts' => $formattedPosts
    ];
    
    error_log("Response: " . json_encode($response));
    echo json_encode($response);
    error_log("=== GET PUBLIC POSTS REQUEST END ===");
    
} catch (Exception $e) {
    error_log("=== ERROR OCCURRED ===");
    error_log("Error message: " . $e->getMessage());
    error_log("Error file: " . $e->getFile());
    error_log("Error line: " . $e->getLine());
    error_log("Error trace: " . $e->getTraceAsString());
    
    http_response_code(500);
    $errorResponse = [
        'error' => 'Internal server error',
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ];
    echo json_encode($errorResponse);
    error_log("Error response sent: " . json_encode($errorResponse));
}
?> 