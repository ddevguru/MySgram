<?php
header('Content-Type: text/plain; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo "🔧 Fixing Existing Story URLs in Database\n";
echo "=========================================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n\n";
    
    // First, show current story URLs
    echo "📱 Current story URLs in database:\n";
    $stmt = $db->prepare("SELECT id, media_url FROM stories ORDER BY id LIMIT 10");
    $stmt->execute();
    $stories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($stories as $story) {
        echo "Story ID: {$story['id']} - URL: {$story['media_url']}\n";
    }
    
    echo "\n🔧 Fixing story URLs...\n";
    
    // Fix URLs that are missing 'backend' in the path
    $updateStmt = $db->prepare("
        UPDATE stories 
        SET media_url = REPLACE(media_url, 'https://mysgram.com/uploads/stories/', 'https://mysgram.com/backend/uploads/stories/')
        WHERE media_url LIKE '%mysgram.com/uploads/stories/%' 
        AND media_url NOT LIKE '%backend/uploads/stories/%'
    ");
    
    $result = $updateStmt->execute();
    
    if ($result) {
        $affectedRows = $updateStmt->rowCount();
        echo "✅ Updated $affectedRows story URLs\n";
    } else {
        echo "❌ Failed to update story URLs\n";
    }
    
    // Also fix any remaining old domain URLs
    $updateOldDomainStmt = $db->prepare("
        UPDATE stories 
        SET media_url = REPLACE(media_url, 'https://devloperwala.in/MySgram/backend/', 'https://mysgram.com/backend/')
        WHERE media_url LIKE '%devloperwala.in%'
    ");
    
    $result2 = $updateOldDomainStmt->execute();
    
    if ($result2) {
        $affectedRows2 = $updateOldDomainStmt->rowCount();
        echo "✅ Updated $affectedRows2 old domain URLs\n";
    }
    
    // Show updated story URLs
    echo "\n📱 Updated story URLs:\n";
    $stmt = $db->prepare("SELECT id, media_url FROM stories ORDER BY id LIMIT 10");
    $stmt->execute();
    $updatedStories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($updatedStories as $story) {
        echo "Story ID: {$story['id']} - URL: {$story['media_url']}\n";
    }
    
    echo "\n🎉 Story URL fixing completed!\n";
    echo "Your stories should now display properly.\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?> 