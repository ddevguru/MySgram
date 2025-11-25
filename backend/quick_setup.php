<?php
header('Content-Type: text/plain; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo "🚀 Quick Database Setup for Mysgram\n";
echo "=====================================\n\n";

try {
    // Connect to MySQL server
    $host = "103.120.179.212";
    $username = "sources";
    $password = "Sources@123";
    
    $pdo = new PDO("mysql:host=$host", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "✅ Connected to MySQL server\n";
    
    // Create database if it doesn't exist
    $pdo->exec("CREATE DATABASE IF NOT EXISTS mysgram_db");
    $pdo->exec("USE mysgram_db");
    echo "✅ Database 'mysgram_db' ready\n\n";
    
    // Create users table
    echo "👥 Creating users table...\n";
    $usersTable = "
    CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        full_name VARCHAR(100) NOT NULL,
        profile_picture TEXT,
        bio TEXT,
        website VARCHAR(255),
        location VARCHAR(255),
        phone VARCHAR(20),
        gender ENUM('male', 'female', 'other', 'prefer_not_to_say'),
        date_of_birth DATE,
        followers_count INT DEFAULT 0,
        following_count INT DEFAULT 0,
        posts_count INT DEFAULT 0,
        is_private BOOLEAN DEFAULT FALSE,
        is_verified BOOLEAN DEFAULT FALSE,
        auth_provider ENUM('email', 'google', 'facebook') DEFAULT 'email',
        auth_provider_id VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $pdo->exec($usersTable);
    echo "✅ Users table created\n";
    
    // Create posts table
    echo "📸 Creating posts table...\n";
    $postsTable = "
    CREATE TABLE IF NOT EXISTS posts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        caption TEXT,
        media_url TEXT NOT NULL,
        media_type ENUM('image', 'video', 'reel') NOT NULL,
        thumbnail_url TEXT,
        duration INT,
        likes_count INT DEFAULT 0,
        comments_count INT DEFAULT 0,
        shares_count INT DEFAULT 0,
        is_public BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $pdo->exec($postsTable);
    echo "✅ Posts table created\n";
    
    // Create stories table
    echo "📱 Creating stories table...\n";
    $storiesTable = "
    CREATE TABLE IF NOT EXISTS stories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        media_url TEXT NOT NULL,
        media_type ENUM('image', 'video') NOT NULL,
        caption TEXT,
        duration INT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL 24 HOUR)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $pdo->exec($storiesTable);
    echo "✅ Stories table created\n";
    
    // Create follows table
    echo "👥 Creating follows table...\n";
    $followsTable = "
    CREATE TABLE IF NOT EXISTS follows (
        id INT AUTO_INCREMENT PRIMARY KEY,
        follower_id INT NOT NULL,
        following_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_follow (follower_id, following_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $pdo->exec($followsTable);
    echo "✅ Follows table created\n";
    
    // Create notifications table
    echo "🔔 Creating notifications table...\n";
    $notificationsTable = "
    CREATE TABLE IF NOT EXISTS notifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        recipient_id INT NOT NULL,
        sender_id INT NOT NULL,
        type VARCHAR(50) NOT NULL,
        title VARCHAR(255),
        message TEXT,
        target_id VARCHAR(100),
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $pdo->exec($notificationsTable);
    echo "✅ Notifications table created\n\n";
    
    // Add a test user
    echo "👤 Adding test user...\n";
    $testUser = "
    INSERT IGNORE INTO users (id, username, email, password, full_name, is_verified, auth_provider)
    VALUES (2, 'deepakmishra744', 'deepak@example.com', 'hashed_password_here', 'Deepak Mishra', 1, 'google')
    ";
    
    $pdo->exec($testUser);
    echo "✅ Test user added\n";
    
    // Add sample posts
    echo "📸 Adding sample posts...\n";
    $samplePosts = [
        "INSERT IGNORE INTO posts (id, user_id, media_url, media_type, caption, is_public) VALUES (1, 2, 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&h=500&fit=crop', 'image', 'Beautiful mountain landscape! 🏔️', 1)",
        "INSERT IGNORE INTO posts (id, user_id, media_url, media_type, caption, is_public) VALUES (2, 2, 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500&h=500&fit=crop', 'image', 'Peaceful forest walk 🌲', 1)",
        "INSERT IGNORE INTO posts (id, user_id, media_url, media_type, caption, is_public) VALUES (3, 2, 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&h=500&fit=crop', 'image', 'Amazing sunset view 🌅', 1)"
    ];
    
    foreach ($samplePosts as $post) {
        $pdo->exec($post);
    }
    echo "✅ Sample posts added\n\n";
    
    // Test the setup
    echo "🧪 Testing the setup...\n";
    $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM users");
    $stmt->execute();
    $userCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM posts");
    $stmt->execute();
    $postCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    echo "✅ Users count: $userCount\n";
    echo "✅ Posts count: $postCount\n\n";
    
    echo "🎉 Setup completed successfully!\n";
    echo "Your explore page should now work and show the sample posts.\n";
    
} catch (Exception $e) {
    echo "❌ Setup failed: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
?> 