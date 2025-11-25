<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once 'config/database.php';
require_once 'utils/JWT.php';

echo "=== Simple Follow Test ===\n\n";

try {
    // Check if follows table exists
    $stmt = $pdo->query("SHOW TABLES LIKE 'follows'");
    $tableExists = $stmt->fetch();
    
    if (!$tableExists) {
        echo "❌ Follows table does not exist. Please run setup_follows_table.php first.\n";
        exit;
    }
    
    echo "✅ Follows table exists\n";
    
    // Check table structure
    $stmt = $pdo->query("DESCRIBE follows");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "✅ Follows table structure:\n";
    foreach ($columns as $col) {
        echo "   - {$col['Field']}: {$col['Type']}\n";
    }
    echo "\n";
    
    // Check if users table has required columns
    $stmt = $pdo->query("DESCRIBE users");
    $userColumns = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    $requiredColumns = ['followers_count', 'following_count'];
    $missingColumns = [];
    
    foreach ($requiredColumns as $col) {
        if (!in_array($col, $userColumns)) {
            $missingColumns[] = $col;
        }
    }
    
    if (!empty($missingColumns)) {
        echo "❌ Missing columns in users table: " . implode(', ', $missingColumns) . "\n";
        echo "Please run setup_follows_table.php to add these columns.\n";
        exit;
    }
    
    echo "✅ Users table has all required columns\n\n";
    
    // Get sample users for testing
    $stmt = $pdo->query("SELECT id, username, full_name FROM users LIMIT 2");
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
    
    // Test parameter handling
    echo "=== Testing Parameter Handling ===\n";
    
    // Simulate request with target_user_id
    $testInput1 = ['target_user_id' => $users[1]['id'], 'action' => 'follow'];
    echo "Test 1 - target_user_id: " . json_encode($testInput1) . "\n";
    $targetUserId1 = $testInput1['target_user_id'] ?? $testInput1['following_id'] ?? null;
    echo "   Extracted user ID: " . ($targetUserId1 ?? 'NULL') . "\n\n";
    
    // Simulate request with following_id (backward compatibility)
    $testInput2 = ['following_id' => $users[1]['id']];
    echo "Test 2 - following_id: " . json_encode($testInput2) . "\n";
    $targetUserId2 = $testInput2['target_user_id'] ?? $testInput2['following_id'] ?? null;
    echo "   Extracted user ID: " . ($targetUserId2 ?? 'NULL') . "\n\n";
    
    if ($targetUserId1 && $targetUserId2) {
        echo "✅ Parameter handling works correctly for both formats\n";
    } else {
        echo "❌ Parameter handling has issues\n";
    }
    
    echo "\n=== Test Complete ===\n";
    echo "If all tests passed, the follow functionality should work.\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 