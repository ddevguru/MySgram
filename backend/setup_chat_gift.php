<?php
require_once 'config/database.php';

echo "Setting up Chat and Gift System...\n";

try {
    // Create chat_rooms table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS chat_rooms (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id_1 INT NOT NULL,
            user_id_2 INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY unique_room (user_id_1, user_id_2)
        )
    ");
    echo "✅ chat_rooms table created/verified\n";
    
    // Create chat_messages table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS chat_messages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            room_id INT NOT NULL,
            sender_id INT NOT NULL,
            message TEXT NOT NULL,
            message_type ENUM('text', 'image', 'video', 'audio', 'file', 'gift', 'location') DEFAULT 'text',
            reply_to INT NULL,
            metadata JSON NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_room_id (room_id),
            INDEX idx_sender_id (sender_id),
            INDEX idx_created_at (created_at)
        )
    ");
    echo "✅ chat_messages table created/verified\n";
    
    // Create gift_transactions table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS gift_transactions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            sender_id INT NOT NULL,
            recipient_id INT NOT NULL,
            gift_id VARCHAR(50) NOT NULL,
            gift_name VARCHAR(100) NOT NULL,
            gift_icon VARCHAR(10) NOT NULL,
            quantity INT DEFAULT 1,
            total_cost INT NOT NULL,
            message TEXT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_sender_id (sender_id),
            INDEX idx_recipient_id (recipient_id),
            INDEX idx_created_at (created_at)
        )
    ");
    echo "✅ gift_transactions table created/verified\n";
    
    // Add coins column to users table if it doesn't exist
    try {
        $pdo->exec("ALTER TABLE users ADD COLUMN coins INT DEFAULT 0");
        echo "✅ coins column added to users table\n";
    } catch (Exception $e) {
        // Column might already exist, check if it exists
        $stmt = $pdo->query("SHOW COLUMNS FROM users LIKE 'coins'");
        if ($stmt->rowCount() == 0) {
            echo "❌ Failed to add coins column: " . $e->getMessage() . "\n";
        } else {
            echo "✅ coins column already exists in users table\n";
        }
    }
    
    // Create indexes for better performance
    try {
        $pdo->exec("CREATE INDEX idx_chat_rooms_users ON chat_rooms(user_id_1, user_id_2)");
        echo "✅ Index idx_chat_rooms_users created\n";
    } catch (Exception $e) {
        echo "⚠️ Index idx_chat_rooms_users already exists or failed: " . $e->getMessage() . "\n";
    }
    
    try {
        $pdo->exec("CREATE INDEX idx_chat_messages_room_time ON chat_messages(room_id, created_at)");
        echo "✅ Index idx_chat_messages_room_time created\n";
    } catch (Exception $e) {
        echo "⚠️ Index idx_chat_messages_room_time already exists or failed: " . $e->getMessage() . "\n";
    }
    
    try {
        $pdo->exec("CREATE INDEX idx_gift_transactions_users ON gift_transactions(sender_id, recipient_id)");
        echo "✅ Index idx_gift_transactions_users created\n";
    } catch (Exception $e) {
        echo "⚠️ Index idx_gift_transactions_users already exists or failed: " . $e->getMessage() . "\n";
    }
    
    // Insert sample data if tables are empty
    $stmt = $pdo->query("SELECT COUNT(*) FROM gift_transactions");
    $giftCount = $stmt->fetchColumn();
    
    if ($giftCount == 0) {
        // Insert sample gift data
        $pdo->exec("
            INSERT INTO gift_transactions (sender_id, recipient_id, gift_id, gift_name, gift_icon, quantity, total_cost, message) VALUES
            (1, 2, '1', 'Rose', '🌹', 1, 100, 'Welcome to MySgram!'),
            (2, 1, '2', 'Heart', '💖', 1, 200, 'Thanks for the follow!'),
            (1, 3, '4', 'Cake', '🎂', 1, 500, 'Happy Birthday!')
        ");
        echo "✅ Sample gift data inserted\n";
    }
    
    // Update sample users with some coins
    $pdo->exec("UPDATE users SET coins = 1000 WHERE id IN (1, 2, 3)");
    echo "✅ Sample users updated with coins\n";
    
    echo "\n🎉 Chat and Gift System setup completed successfully!\n";
    
} catch (Exception $e) {
    echo "❌ Error setting up Chat and Gift System: " . $e->getMessage() . "\n";
}
?> 