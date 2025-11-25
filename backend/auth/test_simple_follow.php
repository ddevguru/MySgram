<?php
// Simple test for follow/unfollow functionality
header('Content-Type: application/json');

require_once '../config/database.php';

echo "=== SIMPLE FOLLOW/UNFOLLOW TEST ===\n";

try {
    // Test 1: Check if follows table exists and has data
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM follows");
    $followCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "Total follows: $followCount\n";
    
    // Test 2: Show some sample follows
    if ($followCount > 0) {
        $stmt = $pdo->query("SELECT * FROM follows LIMIT 3");
        $follows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "Sample follows:\n";
        foreach ($follows as $follow) {
            echo "  {$follow['follower_id']} -> {$follow['following_id']}\n";
        }
    }
    
    // Test 3: Check users table
    $stmt = $pdo->query("SELECT id, username FROM users LIMIT 5");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Available users:\n";
    foreach ($users as $user) {
        echo "  ID: {$user['id']}, Username: {$user['username']}\n";
    }
    
    echo "\n=== TEST COMPLETE ===\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?> 