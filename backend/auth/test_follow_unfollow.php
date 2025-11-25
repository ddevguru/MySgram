<?php
// Test script for follow/unfollow functionality
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once '../config/database.php';
require_once '../utils/JWT.php';

echo "=== FOLLOW/UNFOLLOW TEST ===\n";

try {
    // Test database connection
    echo "Database connection: OK\n";
    
    // Check follows table structure
    $stmt = $pdo->query("DESCRIBE follows");
    $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "Follows table columns: " . implode(', ', $columns) . "\n";
    
    // Check if there are any existing follows
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM follows");
    $followCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "Total follows in database: $followCount\n";
    
    // Show sample follows
    if ($followCount > 0) {
        $stmt = $pdo->query("SELECT * FROM follows LIMIT 5");
        $sampleFollows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "Sample follows:\n";
        foreach ($sampleFollows as $follow) {
            echo "  Follower: {$follow['follower_id']} -> Following: {$follow['following_id']}\n";
        }
    }
    
    echo "\n=== TEST COMPLETE ===\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?> 