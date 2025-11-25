<?php
// Test script for follow users API
require_once 'config/database.php';

echo "🔍 Testing Follow Users API\n";
echo "==========================\n\n";

try {
    // Test with user ID 2 (deepakmishra744)
    $currentUserId = 2;
    
    echo "Testing for user ID: $currentUserId\n";
    echo "Username: deepakmishra744\n\n";
    
    // Get users that current user follows OR who follow current user
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
        ORDER BY 
            CASE 
                WHEN f1.follower_id IS NOT NULL AND f2.following_id IS NOT NULL THEN 1
                WHEN f1.follower_id IS NOT NULL THEN 2
                ELSE 3
            END,
            u.username ASC
    ");
    
    $stmt->execute([$currentUserId, $currentUserId, $currentUserId]);
    $users = $stmt->fetchAll();
    
    echo "Found " . count($users) . " users:\n";
    echo "----------------------------------------\n";
    
    foreach ($users as $user) {
        echo "ID: " . $user['id'] . "\n";
        echo "Username: " . $user['username'] . "\n";
        echo "Full Name: " . $user['full_name'] . "\n";
        echo "Relationship: " . $user['relationship_type'] . "\n";
        echo "Is Following: " . ($user['is_following'] ? 'Yes' : 'No') . "\n";
        echo "Is Followed By: " . ($user['is_followed_by'] ? 'Yes' : 'No') . "\n";
        echo "----------------------------------------\n";
    }
    
    // Also show raw follows data
    echo "\n🔍 Raw follows data for user $currentUserId:\n";
    echo "==========================================\n";
    
    // Users this user follows
    $stmt = $pdo->prepare("SELECT * FROM follows WHERE follower_id = ?");
    $stmt->execute([$currentUserId]);
    $following = $stmt->fetchAll();
    
    echo "Users this user follows:\n";
    foreach ($following as $follow) {
        echo "- Following user ID: " . $follow['following_id'] . "\n";
    }
    
    // Users who follow this user
    $stmt = $pdo->prepare("SELECT * FROM follows WHERE following_id = ?");
    $stmt->execute([$currentUserId]);
    $followers = $stmt->fetchAll();
    
    echo "\nUsers who follow this user:\n";
    foreach ($followers as $follow) {
        echo "- Follower user ID: " . $follow['follower_id'] . "\n";
    }
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 