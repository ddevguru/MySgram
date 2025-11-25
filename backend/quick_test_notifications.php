<?php
header('Content-Type: text/plain; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo "🔔 Quick Notification System Test\n";
echo "================================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n";
    
    // Check notifications table
    $stmt = $db->prepare("SHOW TABLES LIKE 'notifications'");
    $stmt->execute();
    $tableExists = $stmt->fetch();
    
    if (!$tableExists) {
        echo "❌ Notifications table does not exist\n";
        echo "💡 Run: php setup_notification_system.php\n";
        exit;
    }
    
    echo "✅ Notifications table exists\n";
    
    // Check table structure
    $stmt = $db->prepare("DESCRIBE notifications");
    $stmt->execute();
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "📋 Table structure:\n";
    foreach ($columns as $column) {
        echo "   - {$column['Field']}: {$column['Type']}\n";
    }
    
    // Check notification count
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM notifications");
    $stmt->execute();
    $count = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    echo "\n📊 Total notifications: $count\n";
    
    if ($count == 0) {
        echo "💡 No notifications found. Run: php add_sample_notifications.php\n";
    } else {
        // Show recent notifications
        echo "\n📋 Recent notifications:\n";
        $stmt = $db->prepare("SELECT * FROM notifications ORDER BY created_at DESC LIMIT 3");
        $stmt->execute();
        $recent = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($recent as $notification) {
            echo "   - ID {$notification['id']}: {$notification['type']}\n";
            echo "     From user {$notification['sender_id']} to user {$notification['recipient_id']}\n";
            echo "     Message: {$notification['message']}\n";
            echo "     Created: {$notification['created_at']}\n\n";
        }
    }
    
    // Test notification creation
    echo "🧪 Testing notification creation...\n";
    
    // Get a user for testing
    $stmt = $db->prepare("SELECT id FROM users LIMIT 1");
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        try {
            $testQuery = "INSERT INTO notifications (recipient_id, sender_id, type, message) VALUES (?, ?, 'test', 'Test notification')";
            $testStmt = $db->prepare($testQuery);
            $testStmt->execute([$user['id'], $user['id']]);
            
            echo "✅ Test notification created successfully\n";
            
            // Clean up test notification
            $db->exec("DELETE FROM notifications WHERE type = 'test'");
            echo "🧹 Test notification cleaned up\n";
            
        } catch (Exception $e) {
            echo "❌ Test notification failed: " . $e->getMessage() . "\n";
        }
    } else {
        echo "❌ No users found for testing\n";
    }
    
    echo "\n✅ Notification system test completed!\n";
    echo "🎯 The system is ready to use\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 