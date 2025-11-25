<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../config/database.php';
require_once '../utils/JWT.php';

try {
    // Test database connection
    echo "Testing notification system...\n";
    
    // Check if notifications table exists
    $checkTable = $pdo->query("SHOW TABLES LIKE 'notifications'");
    $tableExists = $checkTable->rowCount() > 0;
    
    if (!$tableExists) {
        echo "❌ Notifications table does not exist\n";
        
        // Create notifications table
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS notifications (
                id INT AUTO_INCREMENT PRIMARY KEY,
                recipient_id INT NOT NULL,
                sender_id INT NOT NULL,
                type ENUM('follow', 'like', 'comment', 'follow_request', 'mention', 'message', 'unfollow', 'unlike') NOT NULL,
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
            )
        ");
        echo "✅ Notifications table created\n";
    } else {
        echo "✅ Notifications table exists\n";
    }
    
    // Check table structure
    $columns = $pdo->query("DESCRIBE notifications")->fetchAll(PDO::FETCH_ASSOC);
    echo "📋 Table structure:\n";
    foreach ($columns as $column) {
        echo "  - {$column['Field']}: {$column['Type']}\n";
    }
    
    // Check if there are any notifications
    $notificationCount = $pdo->query("SELECT COUNT(*) FROM notifications")->fetchColumn();
    echo "📊 Total notifications: $notificationCount\n";
    
    // Check if there are any users
    $userCount = $pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
    echo "👥 Total users: $userCount\n";
    
    if ($userCount > 0) {
        // Get sample user
        $sampleUser = $pdo->query("SELECT id, username FROM users LIMIT 1")->fetch(PDO::FETCH_ASSOC);
        echo "👤 Sample user: {$sampleUser['username']} (ID: {$sampleUser['id']})\n";
        
        // Test creating a notification
        $stmt = $pdo->prepare("
            INSERT INTO notifications (recipient_id, sender_id, type, message)
            VALUES (?, ?, 'test', 'This is a test notification')
        ");
        
        $stmt->execute([$sampleUser['id'], $sampleUser['id']]);
        $testNotificationId = $pdo->lastInsertId();
        echo "✅ Test notification created with ID: $testNotificationId\n";
        
        // Test reading notifications
        $stmt = $pdo->prepare("
            SELECT * FROM notifications WHERE recipient_id = ?
        ");
        $stmt->execute([$sampleUser['id']]);
        $userNotifications = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "📱 User has " . count($userNotifications) . " notifications\n";
        
        // Clean up test notification
        $pdo->exec("DELETE FROM notifications WHERE id = $testNotificationId");
        echo "🧹 Test notification cleaned up\n";
    }
    
    echo "✅ Notification system test completed successfully\n";
    
} catch (Exception $e) {
    echo "❌ Error testing notification system: " . $e->getMessage() . "\n";
}
?> 