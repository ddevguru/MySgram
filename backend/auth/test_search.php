<?php
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
    // Get authorization header
    $headers = getallheaders();
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';
    
    if (empty($authHeader) || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
        http_response_code(401);
        echo json_encode(['error' => 'No token provided']);
        exit;
    }
    
    $token = $matches[1];
    
    // Verify token
    $decoded = JWT::verify($token);
    if (!$decoded) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid token']);
        exit;
    }
    
    $currentUserId = $decoded['user_id'];
    $query = isset($_GET['q']) ? trim($_GET['q']) : '';
    
    // Simple test query
    $searchQuery = "%$query%";
    $sql = "
        SELECT 
            u.id,
            u.username,
            u.full_name,
            u.profile_picture,
            u.is_private
        FROM users u
        WHERE (u.username LIKE ? OR u.full_name LIKE ?)
        AND u.id != ?
        ORDER BY u.username ASC
        LIMIT 10
    ";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        $searchQuery,
        $searchQuery,
        $currentUserId
    ]);
    
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format the response
    $formattedUsers = [];
    foreach ($users as $user) {
        $formattedUsers[] = [
            'id' => $user['id'],
            'username' => $user['username'],
            'full_name' => $user['full_name'],
            'profile_picture' => $user['profile_picture'],
            'is_private' => (bool)$user['is_private'],
            'public_posts_count' => 0,
            'is_following' => false,
            'followers_count' => 0,
            'following_count' => 0
        ];
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Test search completed',
        'users' => $formattedUsers,
        'query' => $query,
        'count' => count($formattedUsers)
    ]);
    
} catch (Exception $e) {
    error_log("Error in test_search.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'error' => 'Internal server error',
        'message' => $e->getMessage()
    ]);
}
?> 