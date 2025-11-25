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
        throw new Exception('No valid authorization header found');
    }
    
    $token = $matches[1];
    
    // Verify JWT token
    $jwt = new JWT();
    $decoded = $jwt->verify($token);
    
    if (!$decoded || !isset($decoded['user_id'])) {
        throw new Exception('Invalid or expired token');
    }
    
    $currentUserId = $decoded['user_id'];
    error_log("Current user ID: " . $currentUserId);
    
    $query = isset($_GET['q']) ? trim($_GET['q']) : '';
    error_log("Search query: '" . $query . "'");
    
    if (empty($query)) {
        error_log("Empty search query, returning empty results");
        echo json_encode([
            'success' => true,
            'message' => 'No search query provided',
            'posts' => []
        ]);
        exit;
    }
    
    // Search query with post visibility check
    $searchQuery = "%$query%";
    $sql = "
        SELECT 
            p.id,
            p.user_id,
            p.caption,
            p.media_url,
            p.media_type,
            p.created_at,
            p.likes_count,
            p.comments_count,
            u.username,
            u.full_name,
            u.profile_picture,
            CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END as is_following
        FROM posts p
        INNER JOIN users u ON p.user_id = u.id
        LEFT JOIN follows f ON f.follower_id = ? AND f.following_id = p.user_id
        WHERE (p.caption LIKE ? OR u.username LIKE ?)
        AND (p.is_private = 0 OR p.user_id = ? OR f.id IS NOT NULL)
        ORDER BY 
            CASE WHEN p.caption LIKE ? THEN 1 ELSE 2 END,
            p.created_at DESC
        LIMIT 20
    ";
    
    error_log("=== EXECUTING POST SEARCH QUERY ===");
    error_log("SQL Query: " . $sql);
    error_log("Parameters: " . print_r([$currentUserId, $searchQuery, $searchQuery, $currentUserId, $query . '%'], true));
    
    $stmt = $pdo->prepare($sql);
    if (!$stmt) {
        $error = "Database prepare error: " . implode(", ", $pdo->errorInfo());
        error_log($error);
        throw new Exception($error);
    }
    
    error_log("Statement prepared successfully");
    
    $result = $stmt->execute([
        $currentUserId, // For follow status check
        $searchQuery,   // Caption search
        $searchQuery,   // Username search
        $currentUserId, // For private post access
        $query . '%'    // Exact caption match gets priority
    ]);
    
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
            'caption' => $post['caption'],
            'media_url' => $post['media_url'],
            'media_type' => $post['media_type'],
            'created_at' => $post['created_at'],
            'likes_count' => (int)$post['likes_count'],
            'comments_count' => (int)$post['comments_count'],
            'username' => $post['username'],
            'full_name' => $post['full_name'],
            'profile_picture' => $post['profile_picture'],
            'is_following' => (bool)$post['is_following']
        ];
    }
    
    error_log("=== SENDING POST SEARCH RESPONSE ===");
    $response = [
        'success' => true,
        'message' => 'Posts found successfully',
        'posts' => $formattedPosts
    ];
    
    error_log("Response: " . json_encode($response));
    echo json_encode($response);
    error_log("=== POST SEARCH REQUEST END ===");
    
} catch (Exception $e) {
    error_log("=== ERROR OCCURRED ===");
    error_log("Error: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Search failed: ' . $e->getMessage()
    ]);
}
?> 