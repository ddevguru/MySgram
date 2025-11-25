<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'search_users_error.log');

// Log the request
error_log("=== SEARCH USERS REQUEST START ===");
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
    
    $query = isset($_GET['q']) ? trim($_GET['q']) : '';
    error_log("Search query: '" . $query . "'");
    
    if (empty($query)) {
        error_log("Empty search query, returning empty results");
        echo json_encode([
            'success' => true,
            'message' => 'No search query provided',
            'users' => []
        ]);
        exit;
    }
    
    // Search query with follow status
    $searchQuery = "%$query%";
    $sql = "
        SELECT 
            u.id,
            u.username,
            u.full_name,
            u.profile_picture,
            u.is_private,
            CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END as is_following,
            (SELECT COUNT(*) FROM posts WHERE user_id = u.id AND is_private = 0) as public_posts_count,
            (SELECT COUNT(*) FROM follows WHERE following_id = u.id) as followers_count,
            (SELECT COUNT(*) FROM follows WHERE follower_id = u.id) as following_count
        FROM users u
        LEFT JOIN follows f ON f.follower_id = ? AND f.following_id = u.id
        WHERE (u.username LIKE ? OR u.full_name LIKE ?)
        AND u.id != ?
        ORDER BY 
            CASE WHEN u.username LIKE ? THEN 1 ELSE 2 END,
            u.username ASC
        LIMIT 20
    ";
    
    error_log("=== EXECUTING QUERY ===");
    error_log("SQL Query: " . $sql);
    error_log("Parameters: " . print_r([$searchQuery, $searchQuery, $currentUserId, $query . '%'], true));
    
    $stmt = $pdo->prepare($sql);
    if (!$stmt) {
        $error = "Database prepare error: " . implode(", ", $pdo->errorInfo());
        error_log($error);
        throw new Exception($error);
    }
    
    error_log("Statement prepared successfully");
    
    $result = $stmt->execute([
        $currentUserId, // For follow status check
        $searchQuery,
        $searchQuery,
        $currentUserId,
        $query . '%' // Exact username match gets priority
    ]);
    
    if (!$result) {
        $error = "Database execute error: " . implode(", ", $stmt->errorInfo());
        error_log($error);
        throw new Exception($error);
    }
    
    error_log("Query executed successfully");
    
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    error_log("Found " . count($users) . " users");
    error_log("Users data: " . print_r($users, true));
    
    // Format the response
    $formattedUsers = [];
    foreach ($users as $user) {
        $formattedUsers[] = [
            'id' => $user['id'],
            'username' => $user['username'],
            'full_name' => $user['full_name'],
            'profile_picture' => $user['profile_picture'],
            'is_private' => (bool)$user['is_private'],
            'public_posts_count' => (int)$user['public_posts_count'],
            'is_following' => (bool)$user['is_following'],
            'followers_count' => (int)$user['followers_count'],
            'following_count' => (int)$user['following_count']
        ];
    }
    
    error_log("=== SENDING RESPONSE ===");
    $response = [
        'success' => true,
        'message' => 'Users found successfully',
        'users' => $formattedUsers
    ];
    
    error_log("Response: " . json_encode($response));
    echo json_encode($response);
    error_log("=== SEARCH USERS REQUEST END ===");
    
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