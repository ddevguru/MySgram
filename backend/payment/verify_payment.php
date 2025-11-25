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
    
    $userId = $payload['user_id'];
    
    // Get input data
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Invalid JSON input');
    }
    
    $paymentId = $input['payment_id'] ?? '';
    $orderId = $input['order_id'] ?? '';
    $signature = $input['signature'] ?? '';
    
    if (empty($paymentId) || empty($orderId) || empty($signature)) {
        throw new Exception('Missing payment details');
    }
    
    // Verify payment signature - PRODUCTION KEY
    $expectedSignature = hash_hmac('sha256', $orderId . '|' . $paymentId, 'Ao03v6uv5H0DpcP9ZAMnmY5c');
    
    if (!hash_equals($expectedSignature, $signature)) {
        throw new Exception('Invalid payment signature');
    }
    
    // Get order details from database
    $stmt = $pdo->prepare("
        SELECT * FROM payment_orders 
        WHERE order_id = ? AND user_id = ? AND status = 'created'
    ");
    $stmt->execute([$orderId, $userId]);
    $order = $stmt->fetch();
    
    if (!$order) {
        throw new Exception('Order not found or already processed');
    }
    
    // Calculate coins based on amount
    $coinsToAdd = _calculateCoinsFromAmount($order['amount']);
    
    // Start transaction
    $pdo->beginTransaction();
    
    try {
        // Update order status
        $stmt = $pdo->prepare("
            UPDATE payment_orders 
            SET status = 'completed', payment_id = ?, updated_at = NOW()
            WHERE order_id = ?
        ");
        $stmt->execute([$paymentId, $orderId]);
        
        // Add coins to user account
        $stmt = $pdo->prepare("
            UPDATE users 
            SET coins = coins + ? 
            WHERE id = ?
        ");
        $stmt->execute([$coinsToAdd, $userId]);
        
        // Record coin transaction
        $stmt = $pdo->prepare("
            INSERT INTO coin_transactions (
                user_id, order_id, payment_id, coins_added, amount_paid, 
                transaction_type, status, created_at
            ) VALUES (?, ?, ?, ?, ?, 'purchase', 'completed', NOW())
        ");
        $stmt->execute([
            $userId, $orderId, $paymentId, $coinsToAdd, $order['amount']
        ]);
        
        // Commit transaction
        $pdo->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Payment verified and coins added successfully',
            'coins_added' => $coinsToAdd,
            'total_coins' => _getUserTotalCoins($userId)
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

// Calculate coins based on amount paid
function _calculateCoinsFromAmount($amount) {
    $coinPackages = [
        100 => 100,   // ₹100 = 100 coins
        450 => 500,   // ₹450 = 500 coins
        800 => 1000,  // ₹800 = 1000 coins
        1500 => 2000, // ₹1500 = 2000 coins
        3000 => 5000, // ₹3000 = 5000 coins
    ];
    
    // Find the closest package
    foreach ($coinPackages as $price => $coins) {
        if ($amount >= $price) {
            return $coins;
        }
    }
    
    // Default: 1 coin per ₹1
    return $amount;
}

// Get user's total coins
function _getUserTotalCoins($userId) {
    global $pdo;
    
    $stmt = $pdo->prepare("SELECT coins FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    
    return $user ? $user['coins'] : 0;
}
?> 