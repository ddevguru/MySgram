<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once 'config/database.php';
require_once 'utils/JWT.php';

echo "=== Follow User Backend Test ===\n\n";

// Test 1: Check if database connection works
try {
    echo "1. Testing database connection...\n";
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $result = $stmt->fetch();
    echo "   ✅ Database connected. Users count: {$result['count']}\n\n";
} catch (Exception $e) {
    echo "   ❌ Database error: " . $e->getMessage() . "\n\n";
    exit;
}

// Test 2: Check if follows table exists
try {
    echo "2. Checking follows table...\n";
    $stmt = $pdo->query("DESCRIBE follows");
    $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "   ✅ Follows table exists with columns: " . implode(', ', $columns) . "\n\n";
} catch (Exception $e) {
    echo "   ❌ Follows table error: " . $e->getMessage() . "\n\n";
    exit;
}

// Test 3: Check if users table has required columns
try {
    echo "3. Checking users table structure...\n";
    $stmt = $pdo->query("DESCRIBE users");
    $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
    $requiredColumns = ['id', 'followers_count', 'following_count'];
    $missingColumns = [];
    
    foreach ($requiredColumns as $col) {
        if (!in_array($col, $columns)) {
            $missingColumns[] = $col;
        }
    }
    
    if (empty($missingColumns)) {
        echo "   ✅ Users table has all required columns\n\n";
    } else {
        echo "   ❌ Missing columns: " . implode(', ', $missingColumns) . "\n\n";
    }
} catch (Exception $e) {
    echo "   ❌ Users table error: " . $e->getMessage() . "\n\n";
    exit;
}

// Test 4: Check sample users
try {
    echo "4. Checking sample users...\n";
    $stmt = $pdo->query("SELECT id, username, full_name FROM users LIMIT 3");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (count($users) >= 2) {
        echo "   ✅ Found users for testing:\n";
        foreach ($users as $user) {
            echo "      - ID: {$user['id']}, Username: {$user['username']}, Name: {$user['full_name']}\n";
        }
        echo "\n";
    } else {
        echo "   ❌ Need at least 2 users for testing\n\n";
        exit;
    }
} catch (Exception $e) {
    echo "   ❌ Users query error: " . $e->getMessage() . "\n\n";
    exit;
}

// Test 5: Check JWT utility
try {
    echo "5. Testing JWT utility...\n";
    $jwt = new JWT();
    echo "   ✅ JWT class loaded successfully\n\n";
} catch (Exception $e) {
    echo "   ❌ JWT error: " . $e->getMessage() . "\n\n";
    exit;
}

// Test 6: Check if follow_user.php is accessible
echo "6. Testing follow_user.php accessibility...\n";
$testUrl = 'http://localhost/MySgram/backend/auth/follow_user.php';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $testUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, true);
curl_setopt($ch, CURLOPT_NOBODY, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode == 405) {
    echo "   ✅ follow_user.php is accessible (Method Not Allowed for GET is expected)\n\n";
} else {
    echo "   ⚠️  follow_user.php returned HTTP $httpCode\n\n";
}

echo "=== Test Complete ===\n";
echo "If all tests passed, the backend should work correctly.\n";
echo "If you see any ❌ errors, those need to be fixed first.\n";
?> 