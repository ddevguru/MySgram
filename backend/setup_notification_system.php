<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once 'config/database.php';

try {
    echo "Setting up notification system...\n";
    
    // Create notifications table with proper schema
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS notifications (
            id INT AUTO_INCREMENT PRIMARY KEY,
            recipient_id INT NOT NULL,
            sender_id INT NOT NULL,
            type ENUM('follow', 'like', 'comment', 'follow_request', 'mention', 'message', 'unfollow', 'unlike', 'post', 'story') NOT NULL,
            post_id INT NULL,
            comment_id INT NULL,
            message TEXT,
            is_read BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
            INDEX idx_recipient_id (recipient_id),
            INDEX idx_sender_id (sender_id),
            INDEX idx_type (type),
            INDEX idx_is_read (is_read),
            INDEX idx_created_at (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    
    echo "✅ Notifications table created/verified\n";
    
    // Check if table was created successfully
    $checkTable = $pdo->query("SHOW TABLES LIKE 'notifications'");
    if ($checkTable->rowCount() > 0) {
        echo "✅ Notifications table exists\n";
        
        // Check table structure
        $columns = $pdo->query("DESCRIBE notifications")->fetchAll(PDO::FETCH_ASSOC);
        echo "📋 Table has " . count($columns) . " columns\n";
        
        // Check if there are any existing notifications
        $notificationCount = $pdo->query("SELECT COUNT(*) FROM notifications")->fetchColumn();
        echo "📊 Current notifications: $notificationCount\n";
        
        echo json_encode([
            'success' => true,
            'message' => 'Notification system setup completed',
            'table_exists' => true,
            'columns_count' => count($columns),
            'notifications_count' => $notificationCount
        ]);
    } else {
        throw new Exception('Failed to create notifications table');
    }
    
} catch (Exception $e) {
    echo "❌ Error setting up notification system: " . $e->getMessage() . "\n";
    echo json_encode([
        'success' => false,
        'message' => 'Failed to setup notification system: ' . $e->getMessage()
    ]);
}
?> 