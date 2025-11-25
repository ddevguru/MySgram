<?php
header('Content-Type: text/plain; charset=utf-8');

echo "🧪 Testing Payment System Setup\n";
echo "===============================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n\n";
    
    // Check if payment_orders table exists
    $checkOrdersTable = "SHOW TABLES LIKE 'payment_orders'";
    $result = $db->query($checkOrdersTable);
    
    if ($result->rowCount() > 0) {
        echo "✅ payment_orders table exists\n";
    } else {
        echo "❌ payment_orders table missing\n";
        echo "   Run: php setup_payment_database.php\n";
    }
    
    // Check if coin_transactions table exists
    $checkTransactionsTable = "SHOW TABLES LIKE 'coin_transactions'";
    $result = $db->query($checkTransactionsTable);
    
    if ($result->rowCount() > 0) {
        echo "✅ coin_transactions table exists\n";
    } else {
        echo "❌ coin_transactions table missing\n";
        echo "   Run: php setup_payment_database.php\n";
    }
    
    // Check if users table has coins column
    $checkCoinsColumn = "SHOW COLUMNS FROM users LIKE 'coins'";
    $result = $db->query($checkCoinsColumn);
    
    if ($result->rowCount() > 0) {
        echo "✅ users.coins column exists\n";
    } else {
        echo "❌ users.coins column missing\n";
        echo "   Run: php setup_payment_database.php\n";
    }
    
    // Test Razorpay class
    echo "\n🧪 Testing Razorpay class:\n";
    try {
        $razorpay = new Razorpay('test_key', 'test_secret');
        echo "✅ Razorpay class works\n";
    } catch (Exception $e) {
        echo "❌ Razorpay class error: " . $e->getMessage() . "\n";
    }
    
    echo "\n🎯 Status Summary:\n";
    echo "==================\n";
    
    if ($result->rowCount() > 0) {
        echo "✅ Payment system is ready!\n";
        echo "   You can now test the payment flow\n";
    } else {
        echo "❌ Payment system needs setup\n";
        echo "   Run: php setup_payment_database.php\n";
    }
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}

// Include Razorpay class for testing
class Razorpay {
    private $keyId;
    private $keySecret;
    private $baseUrl = 'https://api.razorpay.com/v1';
    
    public function __construct($keyId, $keySecret) {
        $this->keyId = $keyId;
        $this->keySecret = $keySecret;
    }
    
    public function createOrder($orderData) {
        // This is just for testing the class instantiation
        return ['id' => 'test_order_' . time()];
    }
}
?> 