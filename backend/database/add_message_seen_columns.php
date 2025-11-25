<?php
require_once '../config/database.php';

try {
    echo "🔧 Adding missing columns to messages table...\n";
    
    // Check if columns already exist
    $stmt = $pdo->prepare("SHOW COLUMNS FROM messages LIKE 'is_seen'");
    $stmt->execute();
    $isSeenExists = $stmt->fetch();
    
    if (!$isSeenExists) {
        echo "➕ Adding is_seen column...\n";
        $pdo->exec("ALTER TABLE messages ADD COLUMN is_seen BOOLEAN DEFAULT FALSE");
        echo "✅ is_seen column added successfully\n";
    } else {
        echo "ℹ️ is_seen column already exists\n";
    }
    
    $stmt = $pdo->prepare("SHOW COLUMNS FROM messages LIKE 'seen_at'");
    $stmt->execute();
    $seenAtExists = $stmt->fetch();
    
    if (!$seenAtExists) {
        echo "➕ Adding seen_at column...\n";
        $pdo->exec("ALTER TABLE messages ADD COLUMN seen_at TIMESTAMP NULL");
        echo "✅ seen_at column added successfully\n";
    } else {
        echo "ℹ️ seen_at column already exists\n";
    }
    
    echo "🎉 All required columns are now present in messages table\n";
    
    // Now add missing indexes safely
    echo "\n🔧 Adding missing indexes for better performance...\n";
    
    // Check and add index on is_seen column
    $stmt = $pdo->prepare("SHOW INDEX FROM messages WHERE Key_name = 'idx_is_seen'");
    $stmt->execute();
    $isSeenIndexExists = $stmt->fetch();
    
    if (!$isSeenIndexExists) {
        echo "➕ Adding index on is_seen column...\n";
        $pdo->exec("ALTER TABLE messages ADD INDEX idx_is_seen (is_seen)");
        echo "✅ Index on is_seen column added successfully\n";
    } else {
        echo "ℹ️ Index on is_seen column already exists\n";
    }
    
    // Check and add index on seen_at column
    $stmt = $pdo->prepare("SHOW INDEX FROM messages WHERE Key_name = 'idx_seen_at'");
    $stmt->execute();
    $seenAtIndexExists = $stmt->fetch();
    
    if (!$seenAtIndexExists) {
        echo "➕ Adding index on seen_at column...\n";
        $pdo->exec("ALTER TABLE messages ADD INDEX idx_seen_at (seen_at)");
        echo "✅ Index on seen_at column added successfully\n";
    } else {
        echo "ℹ️ Index on seen_at column already exists\n";
    }
    
    echo "🎉 All required indexes are now present\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 