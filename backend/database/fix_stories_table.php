<?php
require_once '../config/database.php';

try {
    echo "🔧 Fixing stories table...\n";
    
    // Check if is_active column exists
    $check_column = $pdo->query("SHOW COLUMNS FROM stories LIKE 'is_active'");
    
    if ($check_column->rowCount() == 0) {
        // Add the missing is_active column
        $pdo->exec("ALTER TABLE stories ADD COLUMN is_active BOOLEAN DEFAULT TRUE");
        echo "✅ Added is_active column to stories table\n";
        
        // Update existing stories to be active
        $pdo->exec("UPDATE stories SET is_active = TRUE WHERE is_active IS NULL");
        echo "✅ Updated existing stories to be active\n";
    } else {
        echo "✅ is_active column already exists\n";
    }
    
    // Ensure story_views table exists
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS story_views (
            id INT AUTO_INCREMENT PRIMARY KEY,
            story_id INT NOT NULL,
            viewer_id INT NOT NULL,
            viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY unique_view (story_id, viewer_id),
            INDEX idx_story (story_id),
            INDEX idx_viewer (viewer_id)
        )
    ");
    echo "✅ Ensured story_views table exists\n";
    
    echo "✅ Database fix completed successfully\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 