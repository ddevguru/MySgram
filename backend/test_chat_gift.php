<?php
require_once 'config/database.php';

echo "Testing Chat and Gift System Setup...\n\n";

try {
    // Test database connection
    echo "1. Testing database connection... ";
    $pdo->query("SELECT 1");
    echo "✅ Connected successfully\n";
    
    // Check if tables exist
    echo "2. Checking required tables...\n";
    
    $tables = ['chat_rooms', 'chat_messages', 'gift_transactions', 'users'];
    foreach ($tables as $table) {
        $stmt = $pdo->query("SHOW TABLES LIKE '$table'");
        if ($stmt->rowCount() > 0) {
            echo "   ✅ $table table exists\n";
        } else {
            echo "   ❌ $table table missing\n";
        }
    }
    
    // Check if users table has coins column
    echo "3. Checking users table structure... ";
    $stmt = $pdo->query("SHOW COLUMNS FROM users LIKE 'coins'");
    if ($stmt->rowCount() > 0) {
        echo "✅ coins column exists\n";
    } else {
        echo "❌ coins column missing\n";
    }
    
    // Check sample data
    echo "4. Checking sample data...\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $userCount = $stmt->fetch()['count'];
    echo "   Users: $userCount\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM chat_rooms");
    $roomCount = $stmt->fetch()['count'];
    echo "   Chat rooms: $roomCount\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM chat_messages");
    $messageCount = $stmt->fetch()['count'];
    echo "   Chat messages: $messageCount\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM gift_transactions");
    $giftCount = $stmt->fetch()['count'];
    echo "   Gift transactions: $giftCount\n";
    
    // Test user coins
    echo "5. Testing user coins... ";
    $stmt = $pdo->query("SELECT id, username, coins FROM users LIMIT 3");
    $users = $stmt->fetchAll();
    
    if (count($users) > 0) {
        echo "✅ Sample users with coins:\n";
        foreach ($users as $user) {
            echo "   - {$user['username']}: {$user['coins']} coins\n";
        }
    } else {
        echo "❌ No users found\n";
    }
    
    echo "\n🎉 Chat and Gift System test completed!\n";
    
    if ($roomCount == 0) {
        echo "\n💡 Tip: Create some chat rooms to test the system:\n";
        echo "   - Use the create_room.php API endpoint\n";
        echo "   - Or insert directly into the database\n";
    }
    
    if ($messageCount == 0) {
        echo "\n💡 Tip: Send some messages to test chat functionality\n";
    }
    
    if ($giftCount == 0) {
        echo "\n💡 Tip: Send some gifts to test the gift system\n";
    }
    
} catch (Exception $e) {
    echo "❌ Error during testing: " . $e->getMessage() . "\n";
}
?> 