<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';
require_once '../utils/JWT.php';

try {
    // Generate a unique guest username
    $guestUsername = 'guest_' . uniqid() . '_' . time();
    $guestEmail = $guestUsername . '@guest.mysgram.com';
    
    // Create guest user in database
    $stmt = $pdo->prepare("
        INSERT INTO users (username, email, password, full_name, profile_picture, bio, auth_provider, is_verified, created_at) 
        VALUES (?, ?, '', 'Guest User', 'assets/proimage.png', 'Guest user account', 'guest', 0, NOW())
    ");
    
    $stmt->execute([$guestUsername, $guestEmail]);
    $guestUserId = $pdo->lastInsertId();
    
    // Generate JWT token for guest user
    $tokenPayload = [
        'user_id' => $guestUserId,
        'username' => $guestUsername,
        'email' => $guestEmail,
        'is_guest' => true,
        'exp' => time() + (7 * 24 * 60 * 60) // 7 days expiry for guest users
    ];
    
    $token = JWT::generate($tokenPayload);
    
    // Prepare user data
    $userData = [
        'id' => $guestUserId,
        'username' => $guestUsername,
        'email' => $guestEmail,
        'full_name' => 'Guest User',
        'profile_picture' => 'assets/proimage.png',
        'bio' => 'Guest user account',
        'is_guest' => true,
        'created_at' => date('Y-m-d H:i:s')
    ];
    
    echo json_encode([
        'success' => true,
        'message' => 'Guest login successful',
        'token' => $token,
        'user' => $userData
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Guest login failed: ' . $e->getMessage()
    ]);
}
?>
