<?php
// Test script for profile integration
require_once 'config/database.php';

echo "🔍 Testing Profile Integration\n";
echo "============================\n\n";

try {
    // Test with user ID 2 (deepakmishra744)
    $currentUserId = 2;
    
    echo "Testing for user ID: $currentUserId\n";
    echo "Username: deepakmishra744\n\n";
    
    // Test user profile data
    echo "=== USER PROFILE DATA ===\n";
    $stmt = $pdo->prepare("
        SELECT 
            id,
            username,
            full_name,
            profile_picture,
            bio,
            website,
            location,
            followers_count,
            following_count,
            posts_count
        FROM users 
        WHERE id = ?
    ");
    
    $stmt->execute([$currentUserId]);
    $userProfile = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($userProfile) {
        echo "User Profile Found:\n";
        echo "- ID: {$userProfile['id']}\n";
        echo "- Username: {$userProfile['username']}\n";
        echo "- Full Name: {$userProfile['full_name']}\n";
        echo "- Profile Picture: {$userProfile['profile_picture']}\n";
        echo "- Bio: {$userProfile['bio']}\n";
        echo "- Website: {$userProfile['website']}\n";
        echo "- Location: {$userProfile['location']}\n";
        echo "- Followers Count: {$userProfile['followers_count']}\n";
        echo "- Following Count: {$userProfile['following_count']}\n";
        echo "- Posts Count: {$userProfile['posts_count']}\n";
    } else {
        echo "❌ User profile not found\n";
    }
    
    echo "\n=== FOLLOWERS TEST ===\n";
    // Test followers (users who follow this user)
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
    
    echo "\n=== SEARCH USERS TEST ===\n";
    // Test search functionality
    $searchTerm = 'deepak';
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
        WHERE u.username LIKE ? OR u.full_name LIKE ?
        ORDER BY u.username ASC
    ");
    
    $searchPattern = "%$searchTerm%";
    $stmt->execute([$currentUserId, $searchPattern, $searchPattern]);
    $searchResults = $stmt->fetchAll();
    
    echo "Search results for '$searchTerm':\n";
    if (count($searchResults) > 0) {
        foreach ($searchResults as $user) {
            $followStatus = $user['is_following'] ? 'Following' : 'Not Following';
            echo "- ID: {$user['id']}, Username: {$user['username']}, Name: {$user['full_name']}, Status: $followStatus\n";
        }
    } else {
        echo "No search results found\n";
    }
    
    echo "\n=== DATABASE STRUCTURE CHECK ===\n";
    // Check if required tables exist
    $tables = ['users', 'follows', 'posts'];
    foreach ($tables as $table) {
        $stmt = $pdo->prepare("SHOW TABLES LIKE ?");
        $stmt->execute([$table]);
        $exists = $stmt->rowCount() > 0;
        echo "- Table '$table': " . ($exists ? '✅ EXISTS' : '❌ MISSING') . "\n";
    }
    
    // Check users table structure
    echo "\nUsers table structure:\n";
    $stmt = $pdo->prepare("DESCRIBE users");
    $stmt->execute();
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($columns as $column) {
        echo "- {$column['Field']}: {$column['Type']} {$column['Null']} {$column['Key']}\n";
    }
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}
?> 