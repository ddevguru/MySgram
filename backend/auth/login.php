<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Invalid JSON input');
    }
    
    $email = trim($input['email'] ?? '');
    $password = $input['password'] ?? '';
    
    // Validation
    if (empty($email) || empty($password)) {
        throw new Exception('Email and password are required');
    }
    
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        throw new Exception('Invalid email format');
    }
    
    // Get user by email
    $stmt = $pdo->prepare("
        SELECT id, username, email, password, full_name, profile_picture, coins, auth_provider, created_at 
        FROM users WHERE email = ?
    ");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        throw new Exception('User not found');
    }
    
    // Check if user has password (manual registration)
    if (empty($user['password'])) {
        throw new Exception('This account was created with social login. Please use social login.');
    }
    
    // Verify password
    if (!password_verify($password, $user['password'])) {
        throw new Exception('Invalid password');
    }
    
    // Update last seen
    $stmt = $pdo->prepare("UPDATE users SET last_seen = NOW(), is_online = TRUE WHERE id = ?");
    $stmt->execute([$user['id']]);
    
    // Remove password from response
    unset($user['password']);
    
    // Generate JWT token
    require_once '../utils/JWT.php';
    $jwt = new JWT();
    $token = $jwt->generate([
        'user_id' => $user['id'],
        'username' => $user['username'],
        'email' => $user['email']
    ]);
    
    echo json_encode([
        'success' => true,
        'message' => 'Login successful',
        'user' => $user,
        'token' => $token
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
