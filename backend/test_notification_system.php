<?php
header('Content-Type: text/plain; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo "🧪 Testing Notification System\n";
echo "==============================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n\n";
    
    // Test 1: Check notifications table
    echo "📋 Test 1: Checking notifications table...\n";
    $stmt = $db->prepare("SHOW TABLES LIKE 'notifications'");
    $stmt->execute();
    $tableExists = $stmt->fetch();
    
    if ($tableExists) {
        echo "✅ Notifications table exists\n";
    } else {
        echo "❌ Notifications table does not exist\n";
        exit;
    }
    
    // Test 2: Count notifications
    echo "\n📊 Test 2: Counting notifications...\n";
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM notifications");
    $stmt->execute();
    $notificationCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    echo "📈 Total notifications: $notificationCount\n";
    
    if ($notificationCount == 0) {
        echo "⚠️ No notifications found. Run add_sample_notifications.php first.\n";
    } else {
        echo "✅ Notifications found\n";
    }
    
    // Test 3: Check notification structure
    echo "\n🔍 Test 3: Checking notification structure...\n";
    $stmt = $db->prepare("DESCRIBE notifications");
    $stmt->execute();
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "📋 Table columns:\n";
    foreach ($columns as $column) {
        echo "  - {$column['Field']}: {$column['Type']}\n";
    }
    
    // Test 4: Sample notifications
    if ($notificationCount > 0) {
        echo "\n📝 Test 4: Sample notifications...\n";
        $stmt = $db->prepare("SELECT id, type, message, recipient_id, sender_id, post_id, comment_id, created_at FROM notifications LIMIT 3");
        $stmt->execute();
        $notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($notifications as $notif) {
            echo "  - ID: {$notif['id']}, Type: {$notif['type']}\n";
            echo "    Message: {$notif['message']}\n";
            echo "    From: {$notif['sender_id']}, To: {$notif['recipient_id']}\n";
            echo "    Post ID: " . ($notif['post_id'] ?? 'N/A') . ", Comment ID: " . ($notif['comment_id'] ?? 'N/A') . "\n";
            echo "    Time: {$notif['created_at']}\n\n";
        }
    }
    
    // Test 5: Test notification creation
    echo "🧪 Test 5: Testing notification creation...\n";
    
    // Get a user ID for testing
    $stmt = $db->prepare("SELECT id FROM users LIMIT 1");
    $stmt->execute();
    $testUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($testUser) {
        $testNotification = [
            'recipient_id' => $testUser['id'],
            'sender_id' => $testUser['id'],
            'type' => 'follow',
            'post_id' => null,
            'comment_id' => null,
            'message' => 'This is a test notification'
        ];
        
        $insertStmt = $db->prepare("
            INSERT INTO notifications (recipient_id, sender_id, type, post_id, comment_id, message)
            VALUES (:recipient_id, :sender_id, :type, :post_id, :comment_id, :message)
        ");
        
        if ($insertStmt->execute($testNotification)) {
            echo "✅ Test notification created successfully\n";
            
            // Clean up test notification
            $db->prepare("DELETE FROM notifications WHERE message = 'This is a test notification'")->execute();
            echo "🧹 Test notification cleaned up\n";
        } else {
            echo "❌ Failed to create test notification\n";
        }
    } else {
        echo "⚠️ No users found for testing\n";
    }
    
    echo "\n🎉 Notification system test completed!\n";
    
    if ($notificationCount == 0) {
        echo "\n📝 Next steps:\n";
        echo "1. Run: https://mysgram.com/add_sample_notifications.php\n";
        echo "2. This will add sample notifications to test with\n";
        echo "3. Then test your Flutter app notification features\n";
    }
    
} catch (Exception $e) {
    echo "❌ Test failed: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
?> 