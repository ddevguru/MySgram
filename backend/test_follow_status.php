<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once 'config/database.php';
require_once 'utils/JWT.php';

echo "=== Follow Status Test ===\n\n";

try {
    // Check if follows table exists
    $stmt = $pdo->query("SHOW TABLES LIKE 'follows'");
    $tableExists = $stmt->fetch();
    
    if (!$tableExists) {
        echo "❌ Follows table does not exist. Please run setup_follows_table.php first.\n";
        exit;
    }
    
    echo "✅ Follows table exists\n\n";
    
    // Get sample users
    $stmt = $pdo->query("SELECT id, username, full_name FROM users LIMIT 3");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (count($users) < 2) {
        echo "❌ Need at least 2 users for testing\n";
        exit;
    }
    
    echo "✅ Found users for testing:\n";
    foreach ($users as $user) {
        echo "   - ID: {$user['id']}, Username: {$user['username']}\n";
    }
    echo "\n";
    
    $user1 = $users[0];
    $user2 = $users[1];
    
    // Check current follow status
    echo "=== Current Follow Status ===\n";
    
    $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM follows WHERE follower_id = ? AND following_id = ?");
    $stmt->execute([$user1['id'], $user2['id']]);
    $followCount = $stmt->fetch()['count'];
    
    echo "User {$user1['username']} following {$user2['username']}: " . ($followCount > 0 ? 'YES' : 'NO') . "\n";
    
    // Check follower counts
    $stmt = $pdo->prepare("SELECT followers_count, following_count FROM users WHERE id = ?");
    $stmt->execute([$user1['id']]);
    $user1Counts = $stmt->fetch();
    
    $stmt = $pdo->prepare("SELECT followers_count, following_count FROM users WHERE id = ?");
    $stmt->execute([$user2['id']]);
    $user2Counts = $stmt->fetch();
    
    echo "User {$user1['username']}: following_count = {$user1Counts['following_count']}, followers_count = {$user1Counts['followers_count']}\n";
    echo "User {$user2['username']}: following_count = {$user2Counts['following_count']}, followers_count = {$user2Counts['followers_count']}\n\n";
    
    // Test follow relationship creation
    echo "=== Testing Follow Relationship ===\n";
    
    if ($followCount == 0) {
        echo "Creating follow relationship...\n";
        
        // Add follow relationship
        $stmt = $pdo->prepare("INSERT INTO follows (follower_id, following_id, created_at) VALUES (?, ?, NOW())");
        $stmt->execute([$user1['id'], $user2['id']]);
        
        echo "✅ Follow relationship created\n";
        
        // Update follower counts
        $stmt = $pdo->prepare("UPDATE users SET followers_count = followers_count + 1 WHERE id = ?");
        $stmt->execute([$user2['id']]);
        
        $stmt = $pdo->prepare("UPDATE users SET following_count = following_count + 1 WHERE id = ?");
        $stmt->execute([$user1['id']]);
        
        echo "✅ Follower counts updated\n";
        
    } else {
        echo "Follow relationship already exists, removing it...\n";
        
        // Remove follow relationship
        $stmt = $pdo->prepare("DELETE FROM follows WHERE follower_id = ? AND following_id = ?");
        $stmt->execute([$user1['id'], $user2['id']]);
        
        echo "✅ Follow relationship removed\n";
        
        // Update follower counts
        $stmt = $pdo->prepare("UPDATE users SET followers_count = GREATEST(followers_count - 1, 0) WHERE id = ?");
        $stmt->execute([$user2['id']]);
        
        $stmt = $pdo->prepare("UPDATE users SET following_count = GREATEST(following_count - 1, 0) WHERE id = ?");
        $stmt->execute([$user1['id']]);
        
        echo "✅ Follower counts updated\n";
    }
    
    // Check updated status
    echo "\n=== Updated Follow Status ===\n";
    
    $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM follows WHERE follower_id = ? AND following_id = ?");
    $stmt->execute([$user1['id'], $user2['id']]);
    $newFollowCount = $stmt->fetch()['count'];
    
    echo "User {$user1['username']} following {$user2['username']}: " . ($newFollowCount > 0 ? 'YES' : 'NO') . "\n";
    
    // Check updated follower counts
    $stmt = $pdo->prepare("SELECT followers_count, following_count FROM users WHERE id = ?");
    $stmt->execute([$user1['id']]);
    $newUser1Counts = $stmt->fetch();
    
    $stmt = $pdo->prepare("SELECT followers_count, following_count FROM users WHERE id = ?");
    $stmt->execute([$user2['id']]);
    $newUser2Counts = $stmt->fetch();
    
    echo "User {$user1['username']}: following_count = {$newUser1Counts['following_count']}, followers_count = {$newUser1Counts['followers_count']}\n";
    echo "User {$user2['username']}: following_count = {$newUser2Counts['following_count']}, followers_count = {$newUser2Counts['followers_count']}\n\n";
    
    // Test API response
    echo "=== Testing API Response ===\n";
    
    // Simulate getFollowUsers API response
    $stmt = $pdo->prepare("
        SELECT DISTINCT
            u.id,
            u.username,
            u.full_name,
            u.profile_picture,
            u.created_at,
            CASE 
                WHEN f1.follower_id IS NOT NULL THEN 'following'
                WHEN f2.following_id IS NOT NULL THEN 'follower'
                ELSE 'none'
            END as relationship_type,
            CASE 
                WHEN f1.follower_id IS NOT NULL THEN 1
                ELSE 0
            END as is_following,
            CASE 
                WHEN f2.following_id IS NOT NULL THEN 1
                ELSE 0
            END as is_followed_by
        FROM users u
        LEFT JOIN follows f1 ON f1.following_id = u.id AND f1.follower_id = ?
        LEFT JOIN follows f2 ON f2.follower_id = u.id AND f2.following_id = ?
        WHERE u.id != ? 
        AND (f1.follower_id IS NOT NULL OR f2.following_id IS NOT NULL)
        ORDER BY u.username ASC
    ");
    
    $stmt->execute([$user1['id'], $user1['id'], $user1['id']]);
    $apiUsers = $stmt->fetchAll();
    
    echo "API returned " . count($apiUsers) . " users:\n";
    foreach ($apiUsers as $apiUser) {
        $status = $apiUser['is_following'] ? 'following' : ($apiUser['is_followed_by'] ? 'follower' : 'none');
        echo "   - {$apiUser['username']}: {$status}\n";
    }
    
    echo "\n=== Test Complete ===\n";
    echo "If the follow status is being updated correctly in the database,\n";
    echo "the issue might be in the frontend UI refresh.\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}
?> 