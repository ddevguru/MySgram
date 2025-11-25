<?php
require_once '../config/database.php';

try {
    echo "🔧 Fixing chat tables...\n";
    
    // Add missing columns to users table
    $columns_to_add = [
        'is_online' => 'BOOLEAN DEFAULT FALSE',
        'last_seen' => 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
        'coins' => 'INT DEFAULT 1000'
    ];
    
    foreach ($columns_to_add as $column => $definition) {
        try {
            $sql = "ALTER TABLE users ADD COLUMN $column $definition";
            $pdo->exec($sql);
            echo "✅ Added column: $column\n";
        } catch (Exception $e) {
            if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
                echo "ℹ️ Column already exists: $column\n";
            } else {
                echo "⚠️ Error adding column $column: " . $e->getMessage() . "\n";
            }
        }
    }
    
    // Fix chat_rooms table structure
    try {
        $sql = "ALTER TABLE chat_rooms MODIFY COLUMN room_id VARCHAR(100) UNIQUE NOT NULL";
        $pdo->exec($sql);
        echo "✅ Fixed room_id column\n";
    } catch (Exception $e) {
        echo "ℹ️ Room ID column already correct\n";
    }
    
    // Add missing indexes
    $indexes = [
        'idx_chat_rooms_users' => 'chat_rooms(user_id_1, user_id_2)',
        'idx_messages_room' => 'messages(room_id)',
        'idx_messages_sender' => 'messages(sender_id)',
        'idx_gift_transactions_users' => 'gift_transactions(sender_id, recipient_id)'
    ];
    
    foreach ($indexes as $index_name => $columns) {
        try {
            $sql = "CREATE INDEX $index_name ON $columns";
            $pdo->exec($sql);
            echo "✅ Created index: $index_name\n";
        } catch (Exception $e) {
            if (strpos($e->getMessage(), 'Duplicate key name') !== false) {
                echo "ℹ️ Index already exists: $index_name\n";
            } else {
                echo "⚠️ Error creating index $index_name: " . $e->getMessage() . "\n";
            }
        }
    }
    
    // Update existing users to have default values
    try {
        $sql = "UPDATE users SET 
                is_online = FALSE, 
                last_seen = NOW(), 
                coins = 1000 
                WHERE is_online IS NULL OR last_seen IS NULL OR coins IS NULL";
        $pdo->exec($sql);
        echo "✅ Updated existing users with default values\n";
    } catch (Exception $e) {
        echo "⚠️ Error updating users: " . $e->getMessage() . "\n";
    }
    
    echo "\n🎉 Chat tables fixed successfully!\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 