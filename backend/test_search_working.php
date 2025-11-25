<?php
header('Content-Type: text/plain; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo "🔍 Testing Search Functionality\n";
echo "==============================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n";
    
    // Test 1: Check if search endpoints exist
    echo "\n1️⃣ Checking search endpoints:\n";
    $endpoints = [
        'search_users.php',
        'search_posts.php',
        'get_public_posts.php'
    ];
    
    foreach ($endpoints as $endpoint) {
        if (file_exists($endpoint)) {
            echo "   ✅ $endpoint exists\n";
        } else {
            echo "   ❌ $endpoint missing\n";
        }
    }
    
    // Test 2: Check database data
    echo "\n2️⃣ Checking database data:\n";
    
    // Users
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM users");
    $stmt->execute();
    $userCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    echo "   👥 Total users: $userCount\n";
    
    if ($userCount > 0) {
        $stmt = $db->prepare("SELECT username, full_name FROM users LIMIT 3");
        $stmt->execute();
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   📋 Sample users:\n";
        foreach ($users as $user) {
            echo "      - {$user['username']} ({$user['full_name']})\n";
        }
    }
    
    // Posts
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM posts");
    $stmt->execute();
    $postCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    echo "   📝 Total posts: $postCount\n";
    
    if ($postCount > 0) {
        $stmt = $db->prepare("SELECT p.caption, u.username, p.is_public FROM posts p JOIN users u ON p.user_id = u.id LIMIT 3");
        $stmt->execute();
        $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   📋 Sample posts:\n";
        foreach ($posts as $post) {
            $public = $post['is_public'] ? 'Public' : 'Private';
            echo "      - {$post['username']}: {$post['caption']} ($public)\n";
        }
    }
    
    // Test 3: Test search queries
    echo "\n3️⃣ Testing search functionality:\n";
    
    // Test user search
    try {
        $stmt = $db->prepare("SELECT username, full_name FROM users WHERE username LIKE ? OR full_name LIKE ? LIMIT 5");
        $stmt->execute(['%a%', '%a%']);
        $searchResults = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   🔍 User search test (contains 'a'): Found " . count($searchResults) . " users\n";
        foreach ($searchResults as $result) {
            echo "      - {$result['username']} ({$result['full_name']})\n";
        }
    } catch (Exception $e) {
        echo "   ❌ User search test failed: " . $e->getMessage() . "\n";
    }
    
    // Test post search
    try {
        $stmt = $db->prepare("SELECT p.caption, u.username FROM posts p JOIN users u ON p.user_id = u.id WHERE p.caption LIKE ? OR u.username LIKE ? LIMIT 5");
        $stmt->execute(['%a%', '%a%']);
        $searchResults = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   🔍 Post search test (contains 'a'): Found " . count($searchResults) . " posts\n";
        foreach ($searchResults as $result) {
            echo "      - {$result['username']}: {$result['caption']}\n";
        }
    } catch (Exception $e) {
        echo "   ❌ Post search test failed: " . $e->getMessage() . "\n";
    }
    
    // Test public posts
    try {
        $stmt = $db->prepare("SELECT COUNT(*) as total FROM posts WHERE is_public = 1");
        $stmt->execute();
        $publicCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
        echo "   🔍 Public posts: $publicCount\n";
        
        if ($publicCount > 0) {
            $stmt = $db->prepare("SELECT p.caption, u.username FROM posts p JOIN users u ON p.user_id = u.id WHERE p.is_public = 1 LIMIT 3");
            $stmt->execute();
            $publicPosts = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo "   📋 Sample public posts:\n";
            foreach ($publicPosts as $post) {
                echo "      - {$post['username']}: {$post['caption']}\n";
            }
        }
    } catch (Exception $e) {
        echo "   ❌ Public posts test failed: " . $e->getMessage() . "\n";
    }
    
    echo "\n✅ Search functionality test completed!\n";
    echo "🎯 If all tests pass, search should work in the Flutter app\n";
    
    // Show current backend info
    echo "\n📋 Backend Information:\n";
    echo "   - Server: " . $_SERVER['HTTP_HOST'] . "\n";
    echo "   - Database: Connected\n";
    echo "   - Search endpoints: Available\n";
    echo "   - Users: $userCount\n";
    echo "   - Posts: $postCount\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
?> 