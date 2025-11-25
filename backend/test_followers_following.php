<?php
// Test script for followers and following APIs
require_once 'config/database.php';

echo "🔍 Testing Followers and Following APIs\n";
echo "=====================================\n\n";

try {
    // Test with user ID 2 (deepakmishra744)
    $currentUserId = 2;
    
    echo "Testing for user ID: $currentUserId\n";
    echo "Username: deepakmishra744\n\n";
    
    // Test followers (users who follow this user)
    echo "=== FOLLOWERS TEST ===\n";
    $stmt = $pdo->prepare("
        SELECT 
            u.id,
            u.username,
            u.full_name,
            u.profile_picture,
            u.created_at
        FROM users u
        INNER JOIN follows f ON f.follower_id = u.id AND f.following_id = ?
        ORDER BY u.username ASC
    ");
    
    $stmt->execute([$currentUserId]);
    $followers = $stmt->fetchAll();
    
    echo "Users who follow user $currentUserId:\n";
    if (count($followers) > 0) {
        foreach ($followers as $follower) {
            echo "- ID: {$follower['id']}, Username: {$follower['username']}, Name: {$follower['full_name']}\n";
        }
    } else {
        echo "No followers found\n";
    }
    
    echo "\n=== FOLLOWING TEST ===\n";
    // Test following (users this user follows)
    $stmt = $pdo->prepare("
        SELECT 
            u.id,
            u.username,
            u.full_name,
            u.profile_picture,
            u.created_at
        FROM users u
        INNER JOIN follows f ON f.following_id = u.id AND f.follower_id = ?
        ORDER BY u.username ASC
    ");
    
    $stmt->execute([$currentUserId]);
    $following = $stmt->fetchAll();
    
    echo "Users that user $currentUserId follows:\n";
    if (count($following) > 0) {
        foreach ($following as $followedUser) {
            echo "- ID: {$followedUser['id']}, Username: {$followedUser['username']}, Name: {$followedUser['full_name']}\n";
        }
    } else {
        echo "No following users found\n";
    }
    
    echo "\n=== RAW FOLLOWS DATA ===\n";
    // Show raw follows data
    $stmt = $pdo->prepare("SELECT * FROM follows WHERE follower_id = ? OR following_id = ?");
    $stmt->execute([$currentUserId, $currentUserId]);
    $allFollows = $stmt->fetchAll();
    
    echo "All follow relationships involving user $currentUserId:\n";
    foreach ($allFollows as $follow) {
        $relation = $follow['follower_id'] == $currentUserId ? 'FOLLOWS' : 'FOLLOWED BY';
        $otherUser = $follow['follower_id'] == $currentUserId ? $follow['following_id'] : $follow['follower_id'];
        echo "- User $currentUserId $relation user $otherUser\n";
    }
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 