<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'config/database.php';
require_once 'utils/JWT.php';

try {
    echo "🧪 Testing All Notification Types\n";
    echo "================================\n\n";
    
    // Check if notifications table exists
    $checkTable = $pdo->query("SHOW TABLES LIKE 'notifications'");
    $tableExists = $checkTable->rowCount() > 0;
    
    if (!$tableExists) {
        echo "❌ Notifications table does not exist\n";
        exit;
    }
    
    echo "✅ Notifications table exists\n";
    
    // Check table structure
    $columns = $pdo->query("DESCRIBE notifications")->fetchAll(PDO::FETCH_ASSOC);
    echo "📋 Table structure:\n";
    foreach ($columns as $column) {
        echo "   - {$column['Field']}: {$column['Type']}\n";
    }
    
    // Get some sample users for testing
    $users = $pdo->query("SELECT id, username FROM users LIMIT 3")->fetchAll(PDO::FETCH_ASSOC);
    
    if (count($users) < 2) {
        echo "❌ Need at least 2 users for testing\n";
        exit;
    }
    
    echo "\n👥 Testing with users:\n";
    foreach ($users as $user) {
        echo "   - User {$user['id']}: {$user['username']}\n";
    }
    
    $user1 = $users[0];
    $user2 = $users[1];
    
    echo "\n🔔 Testing notification creation...\n";
    
    // Test 1: Follow notification
    echo "1️⃣ Testing follow notification...\n";
    try {
        $stmt = $pdo->prepare("INSERT INTO notifications (recipient_id, sender_id, type, message) VALUES (?, ?, 'follow', 'started following you')");
        $stmt->execute([$user2['id'], $user1['id']]);
        echo "   ✅ Follow notification created\n";
    } catch (Exception $e) {
        echo "   ❌ Follow notification failed: " . $e->getMessage() . "\n";
    }
    
    // Test 2: Like notification
    echo "2️⃣ Testing like notification...\n";
    try {
        $stmt = $pdo->prepare("INSERT INTO notifications (recipient_id, sender_id, type, message, post_id) VALUES (?, ?, 'like', 'liked your post', 1)");
        $stmt->execute([$user2['id'], $user1['id']]);
        echo "   ✅ Like notification created\n";
    } catch (Exception $e) {
        echo "   ❌ Like notification failed: " . $e->getMessage() . "\n";
    }
    
    // Test 3: Comment notification
    echo "3️⃣ Testing comment notification...\n";
    try {
        $stmt = $pdo->prepare("INSERT INTO notifications (recipient_id, sender_id, type, message, post_id) VALUES (?, ?, 'comment', 'commented on your post', 1)");
        $stmt->execute([$user2['id'], $user1['id']]);
        echo "   ✅ Comment notification created\n";
    } catch (Exception $e) {
        echo "   ❌ Comment notification failed: " . $e->getMessage() . "\n";
    }
    
    // Test 4: Message notification
    echo "4️⃣ Testing message notification...\n";
    try {
        $stmt = $pdo->prepare("INSERT INTO notifications (recipient_id, sender_id, type, message) VALUES (?, ?, 'message', 'Hello! How are you?')");
        $stmt->execute([$user2['id'], $user1['id']]);
        echo "   ✅ Message notification created\n";
    } catch (Exception $e) {
        echo "   ❌ Message notification failed: " . $e->getMessage() . "\n";
    }
    
    // Test 5: Post notification
    echo "5️⃣ Testing post notification...\n";
    try {
        $stmt = $pdo->prepare("INSERT INTO notifications (recipient_id, sender_id, type, message, post_id) VALUES (?, ?, 'post', 'posted something new', 1)");
        $stmt->execute([$user2['id'], $user1['id']]);
        echo "   ✅ Post notification created\n";
    } catch (Exception $e) {
        echo "   ❌ Post notification failed: " . $e->getMessage() . "\n";
    }
    
    // Test 6: Story notification
    echo "6️⃣ Testing story notification...\n";
    try {
        $stmt = $pdo->prepare("INSERT INTO notifications (recipient_id, sender_id, type, message, post_id) VALUES (?, ?, 'story', 'posted a new story', 1)");
        $stmt->execute([$user2['id'], $user1['id']]);
        echo "   ✅ Story notification created\n";
    } catch (Exception $e) {
        echo "   ❌ Story notification failed: " . $e->getMessage() . "\n";
    }
    
    // Check total notifications
    $count = $pdo->query("SELECT COUNT(*) FROM notifications")->fetchColumn();
    echo "\n📊 Total notifications in database: $count\n";
    
    // Show recent notifications
    echo "\n📋 Recent notifications:\n";
    $recent = $pdo->query("SELECT * FROM notifications ORDER BY created_at DESC LIMIT 5")->fetchAll(PDO::FETCH_ASSOC);
    foreach ($recent as $notification) {
        echo "   - ID {$notification['id']}: {$notification['type']} from user {$notification['sender_id']} to user {$notification['recipient_id']}\n";
        echo "     Message: {$notification['message']}\n";
        echo "     Created: {$notification['created_at']}\n";
    }
    
    echo "\n✅ All notification tests completed!\n";
    
    echo json_encode([
        'success' => true,
        'message' => 'All notification tests completed',
        'total_notifications' => $count,
        'recent_notifications' => $recent
    ]);
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 