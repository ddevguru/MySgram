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
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['recipient_id']) || !isset($input['gift_id']) || !isset($input['total_cost'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing required fields']);
        exit;
    }
    
    $recipient_id = intval($input['recipient_id']);
    $gift_id = $input['gift_id'];
    $quantity = intval($input['quantity'] ?? 1);
    $total_cost = intval($input['total_cost']);
    
    // Get sender ID from token
    $headers = getallheaders();
    $token = null;
    
    if (isset($headers['Authorization'])) {
        $token = str_replace('Bearer ', '', $headers['Authorization']);
    }
    
    if (!$token) {
        http_response_code(401);
        echo json_encode(['error' => 'No token provided']);
        exit;
    }
    
    $jwt = new JWT();
    $payload = $jwt->decode($token);
    
    if (!$payload || !isset($payload['user_id'])) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid token']);
        exit;
    }
    
    $sender_id = intval($payload['user_id']);
    
    // Check if sender has enough coins
    $stmt = $pdo->prepare("SELECT coins FROM users WHERE id = ?");
    $stmt->execute([$sender_id]);
    $sender = $stmt->fetch();
    
    if (!$sender) {
        http_response_code(404);
        echo json_encode(['error' => 'Sender not found']);
        exit;
    }
    
    if ($sender['coins'] < $total_cost) {
        http_response_code(400);
        echo json_encode(['error' => 'Insufficient coins']);
        exit;
    }
    
    // Get gift details
    $gift_details = [
        '1' => ['name' => 'Rose', 'icon' => '🌹'],
        '2' => ['name' => 'Heart', 'icon' => '💖'],
        '3' => ['name' => 'Kiss', 'icon' => '💋'],
        '4' => ['name' => 'Cake', 'icon' => '🎂'],
        '5' => ['name' => 'Balloon', 'icon' => '🎈'],
        '6' => ['name' => 'Party', 'icon' => '🎊'],
        '7' => ['name' => 'Flower', 'icon' => '🌸'],
        '8' => ['name' => 'Tree', 'icon' => '🌳'],
        '9' => ['name' => 'Sun', 'icon' => '☀️'],
        '10' => ['name' => 'Cat', 'icon' => '🐱'],
        '11' => ['name' => 'Dog', 'icon' => '🐕'],
        '12' => ['name' => 'Butterfly', 'icon' => '🦋'],
        '13' => ['name' => 'Diamond', 'icon' => '💎'],
        '14' => ['name' => 'Crown', 'icon' => '👑'],
        '15' => ['name' => 'Star', 'icon' => '⭐'],
    ];
    
    if (!isset($gift_details[$gift_id])) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid gift ID']);
        exit;
    }
    
    $gift_name = $gift_details[$gift_id]['name'];
    $gift_icon = $gift_details[$gift_id]['icon'];
    
    // Start transaction
    $pdo->beginTransaction();
    
    try {
        // Deduct coins from sender
        $stmt = $pdo->prepare("UPDATE users SET coins = coins - ? WHERE id = ?");
        $stmt->execute([$total_cost, $sender_id]);
        
        // Add coins to recipient
        $stmt = $pdo->prepare("UPDATE users SET coins = coins + ? WHERE id = ?");
        $stmt->execute([$total_cost, $recipient_id]);
        
        // Record gift transaction
        $stmt = $pdo->prepare("
            INSERT INTO gift_transactions (
                sender_id, recipient_id, gift_id, gift_name, gift_icon, 
                quantity, total_cost, message, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ");
        $stmt->execute([
            $sender_id, $recipient_id, $gift_id, $gift_name, $gift_icon,
            $quantity, $total_cost, $input['message'] ?? '', 
        ]);
        
        $transaction_id = $pdo->lastInsertId();
        
        // Commit transaction
        $pdo->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Gift sent successfully',
            'transaction_id' => $transaction_id,
            'gift_name' => $gift_name,
            'gift_icon' => $gift_icon,
            'quantity' => $quantity,
            'total_cost' => $total_cost
        ]);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error: ' . $e->getMessage()]);
}
?> 