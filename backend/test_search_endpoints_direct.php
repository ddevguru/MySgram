<?php
header('Content-Type: text/plain; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo "🔍 Testing Search Endpoints Directly\n";
echo "===================================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n";
    
    // Test 1: Test search_users.php endpoint
    echo "\n1️⃣ Testing search_users.php endpoint:\n";
    try {
        // Simulate the search_users.php logic
        $searchQuery = "deepak";
        $searchQueryParam = "%$searchQuery%";
        
        $sql = "
            SELECT 
                u.id,
                u.username,
                u.full_name,
                u.profile_picture,
                u.is_private,
                CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END as is_following,
                (SELECT COUNT(*) FROM posts WHERE user_id = u.id AND is_public = 0) as public_posts_count,
                (SELECT COUNT(*) FROM follows WHERE following_id = u.id) as followers_count,
                (SELECT COUNT(*) FROM follows WHERE follower_id = u.id) as following_count
            FROM users u
            LEFT JOIN follows f ON f.follower_id = 1 AND f.following_id = u.id
            WHERE (u.username LIKE ? OR u.full_name LIKE ?)
            AND u.id != 1
            ORDER BY 
                CASE WHEN u.username LIKE ? THEN 1 ELSE 2 END,
                u.username ASC
            LIMIT 20
        ";
        
        $stmt = $db->prepare($sql);
        $stmt->execute([$searchQueryParam, $searchQueryParam, $searchQuery . '%']);
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "   🔍 Search for '$searchQuery': Found " . count($users) . " users\n";
        foreach ($users as $user) {
            echo "      - ID: {$user['id']}, Username: {$user['username']}, Name: {$user['full_name']}\n";
        }
    } catch (Exception $e) {
        echo "   ❌ search_users.php test failed: " . $e->getMessage() . "\n";
    }
    
    // Test 2: Test search_posts.php endpoint
    echo "\n2️⃣ Testing search_posts.php endpoint:\n";
    try {
        // Simulate the search_posts.php logic
        $searchQuery = "hello";
        $searchQueryParam = "%$searchQuery%";
        
        $sql = "
            SELECT 
                p.id,
                p.user_id,
                p.caption,
                p.media_url,
                p.media_type,
                p.created_at,
                p.likes_count,
                p.comments_count,
                u.username,
                u.full_name,
                u.profile_picture,
                CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END as is_following
            FROM posts p
            INNER JOIN users u ON p.user_id = u.id
            LEFT JOIN follows f ON f.follower_id = 1 AND f.following_id = p.user_id
            WHERE (p.caption LIKE ? OR u.username LIKE ?)
            AND (p.is_public = 0 OR p.user_id = 1 OR f.id IS NOT NULL)
            ORDER BY 
                CASE WHEN p.caption LIKE ? THEN 1 ELSE 2 END,
                p.created_at DESC
            LIMIT 20
        ";
        
        $stmt = $db->prepare($sql);
        $stmt->execute([$searchQueryParam, $searchQueryParam, $searchQuery . '%']);
        $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "   🔍 Search for '$searchQuery': Found " . count($posts) . " posts\n";
        foreach ($posts as $post) {
            echo "      - ID: {$post['id']}, User: {$post['username']}, Caption: {$post['caption']}\n";
        }
    } catch (Exception $e) {
        echo "   ❌ search_posts.php test failed: " . $e->getMessage() . "\n";
    }
    
    // Test 3: Test get_public_posts.php endpoint
    echo "\n3️⃣ Testing get_public_posts.php endpoint:\n";
    try {
        // Simulate the get_public_posts.php logic
        $sql = "
            SELECT 
                p.id,
                p.user_id,
                p.caption,
                p.media_url,
                p.media_type,
                p.created_at,
                p.likes_count,
                p.comments_count,
                u.username,
                u.full_name,
                u.profile_picture,
                CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END as is_following
            FROM posts p
            INNER JOIN users u ON p.user_id = u.id
            LEFT JOIN follows f ON f.follower_id = 1 AND f.following_id = p.user_id
            WHERE p.is_public = 1
            ORDER BY p.created_at DESC
            LIMIT 20
        ";
        
        $stmt = $db->prepare($sql);
        $stmt->execute();
        $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "   🔍 Public posts: Found " . count($posts) . " posts\n";
        foreach ($posts as $post) {
            echo "      - ID: {$post['id']}, User: {$post['username']}, Caption: {$post['caption']}\n";
        }
    } catch (Exception $e) {
        echo "   ❌ get_public_posts.php test failed: " . $e->getMessage() . "\n";
    }
    
    echo "\n✅ All search endpoint tests completed!\n";
    echo "🎯 If all tests pass, the search functionality should work in Flutter\n";
    
    // Show current backend configuration
    echo "\n📋 Backend Configuration:\n";
    echo "   - Server: " . $_SERVER['HTTP_HOST'] . "\n";
    echo "   - Search endpoints location: auth/ directory\n";
    echo "   - Database: Connected and working\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
?> 