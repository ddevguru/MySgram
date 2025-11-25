<?php
// Database migration script to add Google login support
require_once '../config/database.php';

try {
    echo " Adding Google login support to users table...\n";
    
    // Add google_id column if it doesn't exist
    $sql = "ALTER TABLE users ADD COLUMN google_id VARCHAR(100) NULL";
    try {
        $pdo->exec($sql);
        echo " Added google_id column\n";
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
            echo "? google_id column already exists\n";
        } else {
            throw $e;
        }
    }
    
    // Add auth_provider column if it doesn't exist
    $sql = "ALTER TABLE users ADD COLUMN auth_provider ENUM('email', 'google', 'facebook') DEFAULT 'email'";
    try {
        $pdo->exec($sql);
        echo " Added auth_provider column\n";
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
            echo "? auth_provider column already exists\n";
        } else {
            throw $e;
        }
    }
    
    // Add index for google_id
    $sql = "ALTER TABLE users ADD INDEX idx_google_id (google_id)";
    try {
        $pdo->exec($sql);
        echo " Added google_id index\n";
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Duplicate key name') !== false) {
            echo "? google_id index already exists\n";
        } else {
            throw $e;
        }
    }
    
    // Add index for auth_provider
    $sql = "ALTER TABLE users ADD INDEX idx_auth_provider (auth_provider)";
    try {
        $pdo->exec($sql);
        echo " Added auth_provider index\n";
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Duplicate key name') !== false) {
            echo "? auth_provider index already exists\n";
        } else {
            throw $e;
        }
    }
    
    // Update existing users to have 'email' as auth_provider
    $sql = "UPDATE users SET auth_provider = 'email' WHERE auth_provider IS NULL";
    $pdo->exec($sql);
    echo " Updated existing users with email auth_provider\n";
    
    // Verify the changes
    echo "\n Current users table structure:\n";
    $stmt = $pdo->query("DESCRIBE users");
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "- {$row['Field']}: {$row['Type']} {$row['Null']} {$row['Key']} {$row['Default']}\n";
    }
    
    echo "\n Google login support added successfully!\n";
    
} catch (Exception $e) {
    echo " Error: " . $e->getMessage() . "\n";
}
?>
