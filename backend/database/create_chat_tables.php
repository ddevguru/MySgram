<?php
require_once '../config/database.php';

try {
    // Create chat rooms table
    $sql = "CREATE TABLE IF NOT EXISTS chat_rooms (
        id INT AUTO_INCREMENT PRIMARY KEY,
        room_id VARCHAR(100) UNIQUE NOT NULL,
        user_id_1 INT NOT NULL,
        user_id_2 INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        last_message TEXT NULL,
        unread_count INT DEFAULT 0
    )";
    
    $pdo->exec($sql);
    echo "✅ Chat rooms table created successfully\n";
    
    // Create messages table
    $sql = "CREATE TABLE IF NOT EXISTS messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        message_id VARCHAR(100) UNIQUE NOT NULL,
        room_id VARCHAR(100) NOT NULL,
        sender_id INT NOT NULL,
        message TEXT NOT NULL,
        reply_to VARCHAR(100) NULL,
        message_type ENUM('text', 'image', 'video', 'audio', 'file', 'gift', 'location') DEFAULT 'text',
        metadata JSON NULL,
        is_seen BOOLEAN DEFAULT FALSE,
        seen_at TIMESTAMP NULL,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_room_id (room_id),
        INDEX idx_sender_id (sender_id),
        INDEX idx_is_seen (is_seen)
    )";
    
    $pdo->exec($sql);
    echo "✅ Messages table created successfully\n";
    
    // Create gift categories table
    $sql = "CREATE TABLE IF NOT EXISTS gift_categories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        icon VARCHAR(10) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    
    $pdo->exec($sql);
    echo "✅ Gift categories table created successfully\n";
    
    // Create gift items table
    $sql = "CREATE TABLE IF NOT EXISTS gift_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        category_id INT NOT NULL,
        name VARCHAR(50) NOT NULL,
        icon VARCHAR(10) NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        coins INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES gift_categories(id)
    )";
    
    $pdo->exec($sql);
    echo "✅ Gift items table created successfully\n";
    
    // Create gift transactions table
    $sql = "CREATE TABLE IF NOT EXISTS gift_transactions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        sender_id INT NOT NULL,
        recipient_id INT NOT NULL,
        gift_id INT NOT NULL,
        quantity INT DEFAULT 1,
        total_cost INT NOT NULL,
        message TEXT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_sender (sender_id),
        INDEX idx_recipient (recipient_id)
    )";
    
    $pdo->exec($sql);
    echo "✅ Gift transactions table created successfully\n";
    
    // Insert sample gift categories
    $sql = "INSERT IGNORE INTO gift_categories (name, icon) VALUES
        ('Love & Hearts', '❤️'),
        ('Celebration', '🎉'),
        ('Nature', '🌿'),
        ('Animals', '🐾'),
        ('Premium', '💎')";
    
    $pdo->exec($sql);
    echo "✅ Gift categories inserted successfully\n";
    
    // Insert sample gift items
    $sql = "INSERT IGNORE INTO gift_items (category_id, name, icon, price, coins) VALUES
        (1, 'Rose', '🌹', 0.99, 100),
        (1, 'Heart', '💖', 1.99, 200),
        (1, 'Kiss', '💋', 2.99, 300),
        (2, 'Cake', '🎂', 4.99, 500),
        (2, 'Balloon', '🎈', 2.49, 250),
        (2, 'Party', '🎊', 9.99, 1000),
        (3, 'Flower', '🌸', 1.49, 150),
        (3, 'Tree', '🌳', 3.99, 400),
        (3, 'Sun', '☀️', 3.49, 350),
        (4, 'Cat', '🐱', 4.49, 450),
        (4, 'Dog', '🐕', 5.49, 550),
        (4, 'Butterfly', '🦋', 2.99, 300),
        (5, 'Diamond', '💎', 19.99, 2000),
        (5, 'Crown', '👑', 49.99, 5000),
        (5, 'Star', '⭐', 14.99, 1500)";
    
    $pdo->exec($sql);
    echo "✅ Gift items inserted successfully\n";
    
    // Add coins column to users table if it doesn't exist
    try {
        $sql = "ALTER TABLE users ADD COLUMN coins INT DEFAULT 0";
        $pdo->exec($sql);
        echo "✅ Coins column added to users table\n";
    } catch (Exception $e) {
        echo "ℹ️ Coins column already exists or error: " . $e->getMessage() . "\n";
    }
    
    echo "\n🎉 All chat tables created successfully!\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 