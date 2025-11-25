<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once '../config/database.php';

echo "=== Setting up Follows Table ===\n\n";

try {
    // Check if follows table exists
    $stmt = $pdo->query("SHOW TABLES LIKE 'follows'");
    $tableExists = $stmt->fetch();
    
    if (!$tableExists) {
        echo "Creating follows table...\n";
        
        $sql = "CREATE TABLE follows (
            id INT AUTO_INCREMENT PRIMARY KEY,
            follower_id INT NOT NULL,
            following_id INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY unique_follow (follower_id, following_id),
            FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE
        )";
        
        $pdo->exec($sql);
        echo "✅ Follows table created successfully\n\n";
    } else {
        echo "✅ Follows table already exists\n\n";
    }
    
    // Check if users table has required columns
    $stmt = $pdo->query("DESCRIBE users");
    $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    $requiredColumns = ['followers_count', 'following_count'];
    $missingColumns = [];
    
    foreach ($requiredColumns as $col) {
        if (!in_array($col, $columns)) {
            $missingColumns[] = $col;
        }
    }
    
    if (!empty($missingColumns)) {
        echo "Adding missing columns to users table...\n";
        
        foreach ($missingColumns as $col) {
            if ($col === 'followers_count') {
                $sql = "ALTER TABLE users ADD COLUMN followers_count INT DEFAULT 0";
            } elseif ($col === 'following_count') {
                $sql = "ALTER TABLE users ADD COLUMN following_count INT DEFAULT 0";
            }
            
            $pdo->exec($sql);
            echo "✅ Added column: $col\n";
        }
        echo "\n";
    } else {
        echo "✅ Users table has all required columns\n\n";
    }
    
    // Update existing users to have correct counts
    echo "Updating follower counts for existing users...\n";
    
    // Update followers_count
    $sql = "UPDATE users u SET followers_count = (
        SELECT COUNT(*) FROM follows f WHERE f.following_id = u.id
    )";
    $pdo->exec($sql);
    
    // Update following_count
    $sql = "UPDATE users u SET following_count = (
        SELECT COUNT(*) FROM follows f WHERE f.follower_id = u.id
    )";
    $pdo->exec($sql);
    
    echo "✅ Follower counts updated\n\n";
    
    // Show current status
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM follows");
    $followsCount = $stmt->fetch()['count'];
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $usersCount = $stmt->fetch()['count'];
    
    echo "=== Current Status ===\n";
    echo "Users: $usersCount\n";
    echo "Follow relationships: $followsCount\n";
    echo "✅ Follows table setup complete!\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}
?> 