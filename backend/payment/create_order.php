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
    
    $amount = intval($input['amount'] ?? 0);
    $currency = $input['currency'] ?? 'INR';
    
    if ($amount <= 0) {
        throw new Exception('Invalid amount');
    }
    
    // Razorpay configuration - PRODUCTION KEYS
    $razorpayKeyId = 'rzp_live_Nb4qh9syPEKkss';
    $razorpayKeySecret = 'Ao03v6uv5H0DpcP9ZAMnmY5c';
    
    // Create order data
    $orderData = [
        'receipt' => 'order_' . time() . '_' . $userId,
        'amount' => $amount * 100, // Convert to paise
        'currency' => $currency,
        'notes' => [
            'user_id' => $userId,
            'purpose' => 'coin_purchase'
        ]
    ];
    
    // Initialize Razorpay using cURL
    $razorpay = new Razorpay($razorpayKeyId, $razorpayKeySecret);
    
    // Create order
    $razorpayOrder = $razorpay->createOrder($orderData);
    
    // Save order to database
    try {
        $stmt = $pdo->prepare("
            INSERT INTO payment_orders (
                order_id, user_id, amount, currency, status, created_at
            ) VALUES (?, ?, ?, ?, 'created', NOW())
        ");
        
        $stmt->execute([
            $razorpayOrder['id'],
            $userId,
            $amount,
            $currency
        ]);
        
        // Order saved successfully
    } catch (Exception $dbError) {
        throw new Exception('Database error: ' . $dbError->getMessage());
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Order created successfully',
        'order_id' => $razorpayOrder['id'],
        'amount' => $amount,
        'currency' => $currency
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}

// Custom Razorpay class using cURL
class Razorpay {
    private $keyId;
    private $keySecret;
    private $baseUrl = 'https://api.razorpay.com/v1';
    
    public function __construct($keyId, $keySecret) {
        $this->keyId = $keyId;
        $this->keySecret = $keySecret;
    }
    
    public function createOrder($orderData) {
        $url = $this->baseUrl . '/orders';
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($orderData));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Authorization: Basic ' . base64_encode($this->keyId . ':' . $this->keySecret)
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode === 200) {
            return json_decode($response, true);
        } else {
            throw new Exception('Failed to create Razorpay order: ' . $response);
        }
    }
}
?> 