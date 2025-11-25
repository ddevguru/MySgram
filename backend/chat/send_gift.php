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
    // Get authorization header
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? '';
    
    if (empty($authHeader) || !str_starts_with($authHeader, 'Bearer ')) {
        throw new Exception('Authorization token required');
    }
    
    $token = substr($authHeader, 7);
    
    // Verify JWT token
    $jwt = new JWT();
    $payload = $jwt->verify($token);
    
    if (!$payload) {
        throw new Exception('Invalid token');
    }
    
    $senderId = $payload['user_id'];
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Invalid JSON input');
    }
    
    $recipientId = $input['recipient_id'] ?? '';
    $giftId = $input['gift_id'] ?? '';
    $quantity = intval($input['quantity'] ?? 1);
    $message = $input['message'] ?? '';
    
    // Validation
    if (empty($recipientId) || empty($giftId)) {
        throw new Exception('Recipient ID and gift ID are required');
    }
    
    if ($quantity < 1 || $quantity > 10) {
        throw new Exception('Quantity must be between 1 and 10');
    }
    
    // Get gift details
    $stmt = $pdo->prepare("
        SELECT id, name, icon, coins FROM gift_items WHERE id = ?
    ");
    $stmt->execute([$giftId]);
    $gift = $stmt->fetch();
    
    if (!$gift) {
        throw new Exception('Gift not found');
    }
    
    $totalCost = $gift['coins'] * $quantity;
    
    // Check if sender has enough coins
    $stmt = $pdo->prepare("SELECT coins FROM users WHERE id = ?");
    $stmt->execute([$senderId]);
    $sender = $stmt->fetch();
    
    if (!$sender) {
        throw new Exception('Sender not found');
    }
    
    if ($sender['coins'] < $totalCost) {
        throw new Exception('Insufficient coins');
    }
    
    // Start transaction
    $pdo->beginTransaction();
    
    try {
        // Deduct coins from sender
        $stmt = $pdo->prepare("UPDATE users SET coins = coins - ? WHERE id = ?");
        $stmt->execute([$totalCost, $senderId]);
        
        // Add coins to recipient
        $stmt = $pdo->prepare("UPDATE users SET coins = coins + ? WHERE id = ?");
        $stmt->execute([$totalCost, $recipientId]);
        
        // Record gift transaction
        $stmt = $pdo->prepare("
            INSERT INTO gift_transactions (sender_id, recipient_id, gift_id, quantity, total_cost, message) 
            VALUES (?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([$senderId, $recipientId, $giftId, $quantity, $totalCost, $message]);
        
        // Create or get chat room
        $stmt = $pdo->prepare("
            SELECT room_id FROM chat_rooms 
            WHERE (user_id_1 = ? AND user_id_2 = ?) OR (user_id_1 = ? AND user_id_2 = ?)
        ");
        $stmt->execute([$senderId, $recipientId, $recipientId, $senderId]);
        $existingRoom = $stmt->fetch();
        
        $roomId = null;
        if ($existingRoom) {
            $roomId = $existingRoom['room_id'];
        } else {
            // Create new room
            $roomId = uniqid('room_', true);
            $stmt = $pdo->prepare("
                INSERT INTO chat_rooms (room_id, user_id_1, user_id_2, created_at) 
                VALUES (?, ?, ?, NOW())
            ");
            $stmt->execute([$roomId, $senderId, $recipientId]);
        }
        
        // Add gift message to chat
        $messageId = uniqid('msg_', true);
        $giftMessage = "Sent {$gift['icon']} {$gift['name']} x{$quantity}";
        
        $stmt = $pdo->prepare("
            INSERT INTO messages (message_id, room_id, sender_id, message, message_type, metadata, timestamp) 
            VALUES (?, ?, ?, ?, 'gift', ?, NOW())
        ");
        
        $metadata = json_encode([
            'gift_id' => $giftId,
            'gift_name' => $gift['name'],
            'gift_icon' => $gift['icon'],
            'quantity' => $quantity,
            'total_cost' => $totalCost
        ]);
        
        $stmt->execute([$messageId, $roomId, $senderId, $giftMessage, $metadata]);
        
        // Update room last message
        $stmt = $pdo->prepare("
            UPDATE chat_rooms 
            SET last_message = ?, updated_at = NOW() 
            WHERE room_id = ?
        ");
        $stmt->execute([$giftMessage, $roomId]);
        
        $pdo->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Gift sent successfully',
            'gift' => [
                'id' => $giftId,
                'name' => $gift['name'],
                'icon' => $gift['icon'],
                'quantity' => $quantity,
                'total_cost' => $totalCost
            ],
            'room_id' => $roomId,
            'message_id' => $messageId
        ]);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 