<?php
require_once '../config/database.php';

try {
    echo "🔍 Checking posts table structure and data...\n\n";
    
    // Check table structure
    echo "📋 Table structure:\n";
    $stmt = $pdo->prepare("DESCRIBE posts");
    $stmt->execute();
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($columns as $column) {
        echo "  - {$column['Field']}: {$column['Type']} {$column['Null']} {$column['Key']} {$column['Default']}\n";
    }
    
    echo "\n📊 Posts count:\n";
    $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM posts");
    $stmt->execute();
    $count = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    echo "  Total posts: $count\n";
    
    if ($count > 0) {
        echo "\n📝 Sample posts:\n";
        $stmt = $pdo->prepare("SELECT id, user_id, media_url, media_type, caption, created_at, is_public FROM posts LIMIT 5");
        $stmt->execute();
        $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($posts as $post) {
            echo "  - ID: {$post['id']}, User: {$post['user_id']}, Type: {$post['media_type']}, Public: {$post['is_public']}\n";
        }
    }
    
    echo "\n👥 Users count:\n";
    $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM users");
    $stmt->execute();
    $userCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    echo "  Total users: $userCount\n";
    
    if ($userCount > 0) {
        echo "\n👤 Sample users:\n";
        $stmt = $pdo->prepare("SELECT id, username, email FROM users LIMIT 3");
        $stmt->execute();
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($users as $user) {
            echo "  - ID: {$user['id']}, Username: {$user['username']}, Email: {$user['email']}\n";
        }
    }
    
    echo "\n✅ Database check complete!\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 