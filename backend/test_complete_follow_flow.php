<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once 'config/database.php';
require_once 'utils/JWT.php';

echo "=== Complete Follow Flow Test ===\n\n";

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
    
    // Test 1: Check initial state
    echo "=== Test 1: Initial State ===\n";
    
    $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM follows WHERE follower_id = ? AND following_id = ?");
    $stmt->execute([$user1['id'], $user2['id']]);
    $initialFollowCount = $stmt->fetch()['count'];
    
    echo "Initial follow count: $initialFollowCount\n";
    
    // Test 2: Simulate follow API call
    echo "\n=== Test 2: Simulating Follow API Call ===\n";
    
    // Simulate the request data that would be sent
    $requestData = [
        'target_user_id' => $user2['id'],
        'action' => 'follow'
    ];
    
    echo "Request data: " . json_encode($requestData) . "\n";
    
    // Simulate the database operations that the API would perform
    if ($initialFollowCount == 0) {
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
        echo "Follow relationship already exists\n";
    }
    
    // Test 3: Check updated state
    echo "\n=== Test 3: Updated State ===\n";
    
    $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM follows WHERE follower_id = ? AND following_id = ?");
    $stmt->execute([$user1['id'], $user2['id']]);
    $updatedFollowCount = $stmt->fetch()['count'];
    
    echo "Updated follow count: $updatedFollowCount\n";
    
    // Test 4: Simulate getFollowUsers API response
    echo "\n=== Test 4: Simulating getFollowUsers API Response ===\n";
    
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
        echo "   - {$apiUser['username']}: {$status} (is_following: {$apiUser['is_following']}, relationship_type: {$apiUser['relationship_type']})\n";
    }
    
    // Test 5: Simulate getAllUsers API response
    echo "\n=== Test 5: Simulating getAllUsers API Response ===\n";
    
    $stmt = $pdo->prepare("
        SELECT 
            u.id,
            u.username,
            u.full_name,
            u.profile_picture,
            u.created_at,
            CASE 
                WHEN f.follower_id IS NOT NULL THEN 1
                ELSE 0
            END as is_following
        FROM users u
        LEFT JOIN follows f ON f.following_id = u.id AND f.follower_id = ?
        WHERE u.id != ?
        ORDER BY u.username ASC
    ");
    
    $stmt->execute([$user1['id'], $user1['id']]);
    $allUsers = $stmt->fetchAll();
    
    echo "getAllUsers API returned " . count($allUsers) . " users:\n";
    foreach ($allUsers as $allUser) {
        $status = $allUser['is_following'] ? 'following' : 'not following';
        echo "   - {$allUser['username']}: {$status} (is_following: {$allUser['is_following']})\n";
    }
    
    echo "\n=== Test Complete ===\n";
    echo "If all tests passed, the backend is working correctly.\n";
    echo "The issue might be in the frontend UI refresh.\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}
?> 