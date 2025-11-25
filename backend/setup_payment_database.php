<?php
header('Content-Type: text/plain; charset=utf-8');

echo "🔧 Setting up Payment Database Tables\n";
echo "=====================================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n\n";
    
    // Create payment_orders table
    $createOrdersTable = "
        CREATE TABLE IF NOT EXISTS payment_orders (
            id INT AUTO_INCREMENT PRIMARY KEY,
            order_id VARCHAR(255) UNIQUE NOT NULL,
            user_id INT NOT NULL,
            amount DECIMAL(10,2) NOT NULL,
            currency VARCHAR(10) DEFAULT 'INR',
            status ENUM('created', 'pending', 'completed', 'failed', 'cancelled') DEFAULT 'created',
            payment_id VARCHAR(255) NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_user_id (user_id),
            INDEX idx_order_id (order_id),
            INDEX idx_status (status)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ";
    
    $db->exec($createOrdersTable);
    echo "✅ payment_orders table created/verified\n";
    
    // Create coin_transactions table
    $createTransactionsTable = "
        CREATE TABLE IF NOT EXISTS coin_transactions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            order_id VARCHAR(255) NULL,
            payment_id VARCHAR(255) NULL,
            coins_added INT NOT NULL DEFAULT 0,
            coins_deducted INT NOT NULL DEFAULT 0,
            amount_paid DECIMAL(10,2) NULL,
            transaction_type ENUM('purchase', 'gift_sent', 'gift_received', 'bonus', 'refund') NOT NULL,
            status ENUM('pending', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
            description TEXT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_user_id (user_id),
            INDEX idx_order_id (order_id),
            INDEX idx_transaction_type (transaction_type),
            INDEX idx_status (status)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ";
    
    $db->exec($createTransactionsTable);
    echo "✅ coin_transactions table created/verified\n";
    
    // Add coins column to users table if it doesn't exist
    $checkCoinsColumn = "SHOW COLUMNS FROM users LIKE 'coins'";
    $result = $db->query($checkCoinsColumn);
    
    if ($result->rowCount() == 0) {
        $addCoinsColumn = "ALTER TABLE users ADD COLUMN coins INT NOT NULL DEFAULT 0";
        $db->exec($addCoinsColumn);
        echo "✅ coins column added to users table\n";
    } else {
        echo "✅ coins column already exists in users table\n";
    }
    
    echo "\n🎉 Payment system setup completed successfully!\n";
    echo "\n📋 Tables created:\n";
    echo "   - payment_orders (stores Razorpay orders)\n";
    echo "   - coin_transactions (stores all coin transactions)\n";
    echo "   - users.coins column (stores user coin balance)\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 