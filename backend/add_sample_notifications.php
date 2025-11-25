<?php
header('Content-Type: text/plain; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo "🔔 Adding Sample Notifications to Database\n";
echo "==========================================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n";
    
    // Check if notifications table exists
    $stmt = $db->prepare("SHOW TABLES LIKE 'notifications'");
    $stmt->execute();
    $tableExists = $stmt->fetch();
    
    if (!$tableExists) {
        echo "❌ Notifications table does not exist. Creating it...\n";
        
        $createTableSQL = "CREATE TABLE IF NOT EXISTS notifications (
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
            FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;";
        
        $db->exec($createTableSQL);
        echo "✅ Notifications table created\n\n";
    }
    
    // Check if there are any users
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM users");
    $stmt->execute();
    $userCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    if ($userCount == 0) {
        echo "❌ No users found. Please create users first.\n";
        exit;
    }
    
    echo "👥 Found $userCount users in database\n";
    
    // Get first few users for sample notifications
    $stmt = $db->prepare("SELECT id, username, full_name FROM users LIMIT 5");
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($users)) {
        echo "❌ No users found for notifications\n";
        exit;
    }
    
    echo "👤 Using users:\n";
    foreach ($users as $user) {
        echo "   - User {$user['id']}: {$user['username']} ({$user['full_name']})\n";
    }
    
    // Clear existing notifications
    $db->exec("DELETE FROM notifications");
    echo "\n🧹 Cleared existing notifications\n";
    
    // Create sample notifications
    $sampleNotifications = [
        // Follow notifications
        ['type' => 'follow', 'message' => 'started following you'],
        ['type' => 'follow', 'message' => 'started following you'],
        
        // Like notifications
        ['type' => 'like', 'message' => 'liked your post', 'post_id' => 1],
        ['type' => 'like', 'message' => 'liked your post', 'post_id' => 2],
        
        // Comment notifications
        ['type' => 'comment', 'message' => 'commented: "Great post!"', 'post_id' => 1],
        ['type' => 'comment', 'message' => 'commented: "Amazing!"', 'post_id' => 2],
        
        // Message notifications
        ['type' => 'message', 'message' => 'Hello! How are you?'],
        ['type' => 'message', 'message' => 'Check out this new feature!'],
        
        // Post notifications
        ['type' => 'post', 'message' => 'posted something new', 'post_id' => 3],
        ['type' => 'post', 'message' => 'posted something new', 'post_id' => 4],
        
        // Story notifications
        ['type' => 'story', 'message' => 'posted a new story', 'post_id' => 5],
        ['type' => 'story', 'message' => 'posted a new story', 'post_id' => 6],
    ];
    
    echo "\n🔔 Creating sample notifications...\n";
    $createdCount = 0;
    
    foreach ($sampleNotifications as $index => $notification) {
        $senderId = $users[$index % count($users)]['id'];
        $recipientId = $users[($index + 1) % count($users)]['id'];
        
        // Skip if sender and recipient are the same
        if ($senderId == $recipientId) {
            $recipientId = $users[($index + 2) % count($users)]['id'];
        }
        
        $insertQuery = "INSERT INTO notifications (recipient_id, sender_id, type, message, post_id, created_at) VALUES (?, ?, ?, ?, ?, NOW())";
        $insertStmt = $db->prepare($insertQuery);
        
        $postId = isset($notification['post_id']) ? $notification['post_id'] : null;
        
        if ($insertStmt->execute([$recipientId, $senderId, $notification['type'], $notification['message'], $postId])) {
            echo "   ✅ Created {$notification['type']} notification\n";
            $createdCount++;
        } else {
            echo "   ❌ Failed to create {$notification['type']} notification\n";
        }
    }
    
    // Get final count
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM notifications");
    $stmt->execute();
    $finalCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    echo "\n📊 Summary:\n";
    echo "   - Sample notifications created: $createdCount\n";
    echo "   - Total notifications in database: $finalCount\n";
    
    // Show some recent notifications
    echo "\n📋 Recent notifications:\n";
    $stmt = $db->prepare("SELECT * FROM notifications ORDER BY created_at DESC LIMIT 5");
    $stmt->execute();
    $recentNotifications = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($recentNotifications as $notification) {
        $sender = $users[array_search($notification['sender_id'], array_column($users, 'id'))]['username'] ?? 'Unknown';
        $recipient = $users[array_search($notification['recipient_id'], array_column($users, 'id'))]['username'] ?? 'Unknown';
        
        echo "   - {$sender} → {$recipient}: {$notification['type']} - {$notification['message']}\n";
    }
    
    echo "\n✅ Sample notifications added successfully!\n";
    echo "🎯 You can now test the notification system in your app\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
?> 