<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    require_once 'config/database.php';
    
    echo "🔍 Testing database connection and tables...\n\n";
    
    // Test database connection
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n";
    echo "📊 Database name: mysgram_db\n\n";
    
    // Get all tables
    $stmt = $db->prepare("SHOW TABLES");
    $stmt->execute();
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    echo "📋 Tables found (" . count($tables) . "):\n";
    foreach ($tables as $table) {
        echo "  - $table\n";
    }
    echo "\n";
    
    // Check specific tables
    $requiredTables = ['users', 'posts', 'stories', 'follows', 'notifications'];
    
    foreach ($requiredTables as $table) {
        if (in_array($table, $tables)) {
            // Count records
            $stmt = $db->prepare("SELECT COUNT(*) as total FROM $table");
            $stmt->execute();
            $count = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
            echo "✅ Table '$table' exists with $count records\n";
        } else {
            echo "❌ Table '$table' does not exist\n";
        }
    }
    
    echo "\n🎯 Summary:\n";
    if (count($tables) == 0) {
        echo "❌ No tables found - database is empty\n";
    } elseif (count(array_intersect($requiredTables, $tables)) == 0) {
        echo "❌ None of the required tables exist\n";
    } elseif (count(array_intersect($requiredTables, $tables)) < count($requiredTables)) {
        echo "⚠️ Some required tables are missing\n";
    } else {
        echo "✅ All required tables exist\n";
    }
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
?> 