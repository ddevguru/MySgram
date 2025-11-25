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

    // Change from 'access_token' to 'id_token' to match Flutter
    $idToken = $input['id_token'] ?? '';

    if (empty($idToken)) {
        throw new Exception('Google ID token is required');
    }

    // Verify and decode Google ID token
    $googleUserInfo = verifyGoogleIdToken($idToken);

    if (!$googleUserInfo) {
        throw new Exception('Invalid Google ID token');
    }

    $email = $googleUserInfo['email'];
    $name = $googleUserInfo['name'] ?? '';
    $profilePicture = $googleUserInfo['picture'] ?? '';
    $googleId = $googleUserInfo['sub'] ?? '';

    // Check if user already exists
    $stmt = $pdo->prepare("
        SELECT id, username, email, full_name, profile_picture, coins, auth_provider, created_at
        FROM users WHERE email = ? OR google_id = ?
    ");
    $stmt->execute([$email, $googleId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        // User exists, update Google ID if not set and last seen
        if (empty($user['google_id'])) {
            $stmt = $pdo->prepare("UPDATE users SET google_id = ?, last_seen = NOW(), is_online = TRUE WHERE id = ?");
            $stmt->execute([$googleId, $user['id']]);
        } else {
            $stmt = $pdo->prepare("UPDATE users SET last_seen = NOW(), is_online = TRUE WHERE id = ?");
            $stmt->execute([$user['id']]);
        }

        // Update profile picture if it's different and not the default
        if (!empty($profilePicture) && $profilePicture !== $user['profile_picture'] && $user['profile_picture'] === 'assets/proimage.png') {
            $stmt = $pdo->prepare("UPDATE users SET profile_picture = ? WHERE id = ?");
            $stmt->execute([$profilePicture, $user['id']]);
            $user['profile_picture'] = $profilePicture;
        }

    } else {
        // User doesn't exist, create new account
        $username = generateUniqueUsername($name, $email);

        $stmt = $pdo->prepare("
            INSERT INTO users (username, email, password, full_name, profile_picture, google_id, auth_provider, coins, created_at)
            VALUES (?, ?, '', ?, ?, ?, 'google', 0, NOW())
        ");

        $stmt->execute([$username, $email, $name, $profilePicture, $googleId]);
        $userId = $pdo->lastInsertId();

        // Get the created user
        $stmt = $pdo->prepare("
            SELECT id, username, email, full_name, profile_picture, coins, auth_provider, created_at
            FROM users WHERE id = ?
        ");
        $stmt->execute([$userId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Generate JWT token
    $jwt = new JWT();
    $token = $jwt->generate([
        'user_id' => $user['id'],
        'username' => $user['username'],
        'email' => $user['email']
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Google login successful',
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

function verifyGoogleIdToken($idToken) {
    try {
        // Decode JWT token (basic verification)
        $parts = explode('.', $idToken);
        if (count($parts) !== 3) {
            return false;
        }

        $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $parts[1])), true);

        // Check if token is expired
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return false;
        }

        // Verify it's from Google
        if (!isset($payload['iss']) || !in_array($payload['iss'], [
            'https://accounts.google.com',
            'accounts.google.com'
        ])) {
            return false;
        }

        // Verify audience (your client ID)
        if (!isset($payload['aud']) || $payload['aud'] !== '1028002440504-ft3ono2iier6oceh5che9e8u1j5o8d9m.apps.googleusercontent.com') {
            return false;
        }

        return [
            'sub' => $payload['sub'] ?? '',
            'email' => $payload['email'] ?? '',
            'name' => $payload['name'] ?? '',
            'picture' => $payload['picture'] ?? ''
        ];

    } catch (Exception $e) {
        error_log('Google token verification error: ' . $e->getMessage());
        return false;
    }
}

function generateUniqueUsername($name, $email) {
    global $pdo;

    // Try to create username from name
    $baseUsername = '';
    if (!empty($name)) {
        $baseUsername = strtolower(preg_replace('/[^a-zA-Z0-9]/', '', $name));
    } else {
        // Use email prefix if no name
        $emailParts = explode('@', $email);
        $baseUsername = strtolower(preg_replace('/[^a-zA-Z0-9]/', '', $emailParts[0]));
    }

    // Ensure minimum length
    if (strlen($baseUsername) < 3) {
        $baseUsername = 'user' . substr($baseUsername, 0, 3);
    }

    // Check if username exists and make it unique
    $username = $baseUsername;
    $counter = 1;

    while (true) {
        $stmt = $pdo->prepare("SELECT id FROM users WHERE username = ?");
        $stmt->execute([$username]);

        if (!$stmt->fetch()) {
            break; // Username is available
        }

        $username = $baseUsername . $counter;
        $counter++;
    }

    return $username;
}
?>
