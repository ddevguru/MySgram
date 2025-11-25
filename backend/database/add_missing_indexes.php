<?php
require_once '../config/database.php';

try {
    echo "🔧 Adding missing indexes for better performance...\n\n";
    
    // Define all indexes that should exist
    $requiredIndexes = [
        'users' => [
            'idx_users_email' => 'email',
            'idx_users_google_id' => 'google_id',
        ],
        'chat_rooms' => [
            'idx_chat_rooms_users' => 'user_id_1, user_id_2',
        ],
        'messages' => [
            'idx_messages_room' => 'room_id',
            'idx_messages_sender' => 'sender_id',
            'idx_messages_timestamp' => 'timestamp',
            'idx_is_seen' => 'is_seen',
            'idx_seen_at' => 'seen_at',
        ],
        'gift_transactions' => [
            'idx_gift_transactions_users' => 'sender_id, recipient_id',
        ]
    ];
    
    foreach ($requiredIndexes as $table => $indexes) {
        echo "📋 Checking indexes for table: $table\n";
        
        foreach ($indexes as $indexName => $columns) {
            // Check if index already exists
            $stmt = $pdo->prepare("SHOW INDEX FROM $table WHERE Key_name = ?");
            $stmt->execute([$indexName]);
            $indexExists = $stmt->fetch();
            
            if (!$indexExists) {
                echo "➕ Adding index: $indexName on $columns...\n";
                try {
                    $pdo->exec("ALTER TABLE $table ADD INDEX $indexName ($columns)");
                    echo "✅ Index $indexName added successfully\n";
                } catch (Exception $e) {
                    echo "⚠️ Warning: Could not add index $indexName: " . $e->getMessage() . "\n";
                }
            } else {
                echo "ℹ️ Index $indexName already exists\n";
            }
        }
        echo "\n";
    }
    
    echo "🎉 Index setup complete!\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 