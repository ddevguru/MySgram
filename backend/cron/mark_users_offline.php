<?php
require_once '../config/database.php';

try {
    echo "🔄 Marking inactive users as offline...\n";
    
    // Mark users as offline if they haven't been active for more than 10 minutes
    $sql = "UPDATE users SET is_online = FALSE WHERE is_online = TRUE AND last_seen < DATE_SUB(NOW(), INTERVAL 10 MINUTE)";
    
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute();
    
    if ($result) {
        $affectedRows = $stmt->rowCount();
        echo "✅ Marked $affectedRows users as offline\n";
    } else {
        echo "❌ Error updating user status\n";
    }
    
    // Also clean up expired stories (older than 24 hours)
    $sql = "DELETE FROM stories WHERE created_at < DATE_SUB(NOW(), INTERVAL 24 HOUR)";
    
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute();
    
    if ($result) {
        $affectedRows = $stmt->rowCount();
        if ($affectedRows > 0) {
            echo "✅ Deleted $affectedRows expired stories\n";
        } else {
            echo "ℹ️ No expired stories to delete\n";
        }
    } else {
        echo "❌ Error deleting expired stories\n";
    }
    
    echo "🎉 Cron job completed successfully!\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 