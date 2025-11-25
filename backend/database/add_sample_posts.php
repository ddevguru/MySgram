<?php
require_once '../config/database.php';

try {
    echo "🔍 Adding sample posts to database...\n\n";
    
    // Check if posts table exists
    $stmt = $pdo->prepare("SHOW TABLES LIKE 'posts'");
    $stmt->execute();
    $tableExists = $stmt->fetch();
    
    if (!$tableExists) {
        echo "❌ Posts table does not exist. Creating it first...\n";
        
        $createTableSQL = "CREATE TABLE IF NOT EXISTS posts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            media_url VARCHAR(500) NOT NULL,
            media_type VARCHAR(50) DEFAULT 'image',
            caption TEXT,
            likes_count INT DEFAULT 0,
            comments_count INT DEFAULT 0,
            shares_count INT DEFAULT 0,
            is_public BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )";
        
        $pdo->exec($createTableSQL);
        echo "✅ Posts table created successfully\n\n";
    }
    
    // Check if there are any users
    $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM users");
    $stmt->execute();
    $userCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    if ($userCount == 0) {
        echo "❌ No users found. Please create users first.\n";
        exit;
    }
    
    // Get first user ID
    $stmt = $pdo->prepare("SELECT id FROM users LIMIT 1");
    $stmt->execute();
    $firstUser = $stmt->fetch(PDO::FETCH_ASSOC);
    $userId = $firstUser['id'];
    
    echo "👤 Using user ID: $userId\n";
    
    // Check if posts already exist
    $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM posts");
    $stmt->execute();
    $postCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    if ($postCount > 0) {
        echo "ℹ️ Posts already exist ($postCount posts found)\n";
        echo "📝 Sample posts:\n";
        
        $stmt = $pdo->prepare("SELECT id, media_url, media_type, caption FROM posts LIMIT 3");
        $stmt->execute();
        $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($posts as $post) {
            echo "  - ID: {$post['id']}, Type: {$post['media_type']}, Caption: {$post['caption']}\n";
        }
        
        echo "\n✅ No need to add sample posts\n";
        exit;
    }
    
    // Add sample posts
    echo "➕ Adding sample posts...\n";
    
    $samplePosts = [
        [
            'media_url' => 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&h=500&fit=crop',
            'media_type' => 'image',
            'caption' => 'Beautiful mountain landscape! 🏔️'
        ],
        [
            'media_url' => 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500&h=500&fit=crop',
            'media_type' => 'image',
            'caption' => 'Peaceful forest walk 🌲'
        ],
        [
            'media_url' => 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&h=500&fit=crop',
            'media_type' => 'image',
            'caption' => 'Amazing sunset view 🌅'
        ],
        [
            'media_url' => 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500&h=500&fit=crop',
            'media_type' => 'image',
            'caption' => 'City skyline at night 🌃'
        ],
        [
            'media_url' => 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&h=500&fit=crop',
            'media_type' => 'image',
            'caption' => 'Adventure awaits! 🚀'
        ]
    ];
    
    $insertStmt = $pdo->prepare("
        INSERT INTO posts (user_id, media_url, media_type, caption, is_public, created_at) 
        VALUES (?, ?, ?, ?, TRUE, NOW())
    ");
    
    foreach ($samplePosts as $post) {
        $insertStmt->execute([
            $userId,
            $post['media_url'],
            $post['media_type'],
            $post['caption']
        ]);
        echo "  ✅ Added: {$post['caption']}\n";
    }
    
    echo "\n🎉 Sample posts added successfully!\n";
    echo "📊 Total posts now: " . ($postCount + count($samplePosts)) . "\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 