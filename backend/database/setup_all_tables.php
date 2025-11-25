<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    echo "🚀 Starting database setup...\n\n";
    
    // 1. Create stories table
    echo "📱 Setting up stories table...\n";
    $storiesTable = "
    CREATE TABLE IF NOT EXISTS stories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        media_type ENUM('image', 'video') NOT NULL,
        media_url TEXT NOT NULL,
        caption TEXT,
        duration INT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL 24 HOUR),
        INDEX idx_user_id (user_id),
        INDEX idx_created_at (created_at),
        INDEX idx_expires_at (expires_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $db->exec($storiesTable);
    echo "✅ Stories table ready\n";
    
    // 2. Create story_views table
    echo "👁️ Setting up story_views table...\n";
    $storyViewsTable = "
    CREATE TABLE IF NOT EXISTS story_views (
        id INT AUTO_INCREMENT PRIMARY KEY,
        story_id INT NOT NULL,
        viewer_id INT NOT NULL,
        viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_story_view (story_id, viewer_id),
        INDEX idx_story_id (story_id),
        INDEX idx_viewer_id (viewer_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $db->exec($storyViewsTable);
    echo "✅ Story views table ready\n";
    
    // 3. Create chat_rooms table
    echo "💬 Setting up chat_rooms table...\n";
    $chatRoomsTable = "
    CREATE TABLE IF NOT EXISTS chat_rooms (
        id INT AUTO_INCREMENT PRIMARY KEY,
        room_id VARCHAR(100) UNIQUE NOT NULL,
        user_id_1 INT NOT NULL,
        user_id_2 INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        last_message TEXT NULL,
        unread_count INT DEFAULT 0,
        INDEX idx_user_id_1 (user_id_1),
        INDEX idx_user_id_2 (user_id_2)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $db->exec($chatRoomsTable);
    echo "✅ Chat rooms table ready\n";
    
    // 4. Create messages table with seen status
    echo "💌 Setting up messages table...\n";
    $messagesTable = "
    CREATE TABLE IF NOT EXISTS messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        message_id VARCHAR(100) UNIQUE NOT NULL,
        room_id VARCHAR(100) NOT NULL,
        sender_id INT NOT NULL,
        message TEXT NOT NULL,
        reply_to VARCHAR(100) NULL,
        message_type ENUM('text', 'image', 'video', 'audio', 'file', 'gift', 'location') DEFAULT 'text',
        metadata JSON NULL,
        is_seen BOOLEAN DEFAULT FALSE,
        seen_at TIMESTAMP NULL,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_room_id (room_id),
        INDEX idx_sender_id (sender_id),
        INDEX idx_is_seen (is_seen)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $db->exec($messagesTable);
    echo "✅ Messages table ready\n";
    
    // 5. Create posts table
    echo "📸 Setting up posts table...\n";
    $postsTable = "
    CREATE TABLE IF NOT EXISTS posts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        caption TEXT,
        media_type ENUM('image', 'video') NOT NULL,
        media_url TEXT NOT NULL,
        thumbnail_url TEXT,
        duration INT NULL,
        likes_count INT DEFAULT 0,
        comments_count INT DEFAULT 0,
        shares_count INT DEFAULT 0,
        is_public BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id),
        INDEX idx_created_at (created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $db->exec($postsTable);
    echo "✅ Posts table ready\n";
    
    // 6. Create users table if it doesn't exist
    echo "👤 Setting up users table...\n";
    $usersTable = "
    CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password VARCHAR(255) NULL,
        google_id VARCHAR(100) NULL,
        full_name VARCHAR(100),
        profile_picture TEXT,
        bio TEXT,
        posts_count INT DEFAULT 0,
        followers_count INT DEFAULT 0,
        following_count INT DEFAULT 0,
        coins INT DEFAULT 1000,
        is_online BOOLEAN DEFAULT FALSE,
        last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_username (username),
        INDEX idx_email (email)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $db->exec($usersTable);
    echo "✅ Users table ready\n";
    
    // 7. Create follows table
    echo "👥 Setting up follows table...\n";
    $followsTable = "
    CREATE TABLE IF NOT EXISTS follows (
        id INT AUTO_INCREMENT PRIMARY KEY,
        follower_id INT NOT NULL,
        following_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_follow (follower_id, following_id),
        INDEX idx_follower_id (follower_id),
        INDEX idx_following_id (following_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $db->exec($followsTable);
    echo "✅ Follows table ready\n";
    
    // 8. Create likes table
    echo "❤️ Setting up likes table...\n";
    $likesTable = "
    CREATE TABLE IF NOT EXISTS likes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        post_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_like (user_id, post_id),
        INDEX idx_user_id (user_id),
        INDEX idx_post_id (post_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $db->exec($likesTable);
    echo "✅ Likes table ready\n";
    
    // 9. Create comments table
    echo "💬 Setting up comments table...\n";
    $commentsTable = "
    CREATE TABLE IF NOT EXISTS comments (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        post_id INT NOT NULL,
        comment TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id),
        INDEX idx_post_id (post_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    
    $db->exec($commentsTable);
    echo "✅ Comments table ready\n";
    
    echo "\n🎉 All database tables are ready!\n";
    echo "📋 Summary:\n";
    echo "   • Stories table ✓\n";
    echo "   • Story views table ✓\n";
    echo "   • Chat rooms table ✓\n";
    echo "   • Messages table ✓\n";
    echo "   • Posts table ✓\n";
    echo "   • Users table ✓\n";
    echo "   • Follows table ✓\n";
    echo "   • Likes table ✓\n";
    echo "   • Comments table ✓\n";
    
    http_response_code(200);
    echo json_encode(array(
        "success" => true,
        "message" => "All database tables created successfully",
        "tables_created" => [
            "stories", "story_views", "chat_rooms", "messages", 
            "posts", "users", "follows", "likes", "comments"
        ]
    ));
    
} catch(Exception $e) {
    echo "\n❌ Error: " . $e->getMessage() . "\n";
    http_response_code(500);
    echo json_encode(array(
        "success" => false,
        "message" => "Database setup failed: " . $e->getMessage()
    ));
}
?> 