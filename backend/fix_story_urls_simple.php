<?php
header('Content-Type: text/plain; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo "🔧 Fixing Story URLs - Simple Version\n";
echo "=====================================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n\n";
    
    // Update story URLs to use correct domain
    echo "🔧 Updating story URLs...\n";
    
    $updateStmt = $db->prepare("
        UPDATE stories 
        SET media_url = REPLACE(media_url, 'https://devloperwala.in/MySgram/backend/', 'https://mysgram.com/')
        WHERE media_url LIKE '%devloperwala.in%'
    ");
    
    $result = $updateStmt->execute();
    
    if ($result) {
        $affectedRows = $updateStmt->rowCount();
        echo "✅ Updated $affectedRows story URLs\n";
    } else {
        echo "❌ Failed to update story URLs\n";
    }
    
    // Show current stories
    echo "\n📱 Current stories in database:\n";
    $stmt = $db->prepare("SELECT id, user_id, media_url, caption FROM stories ORDER BY id LIMIT 5");
    $stmt->execute();
    $stories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($stories as $story) {
        echo "Story ID: {$story['id']}, User: {$story['user_id']}\n";
        echo "  URL: {$story['media_url']}\n";
        echo "  Caption: {$story['caption']}\n\n";
    }
    
    echo "🎉 Story URL fixing completed!\n";
    echo "Your stories should now display properly.\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 