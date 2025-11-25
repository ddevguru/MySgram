<?php
header('Content-Type: text/plain; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo "🔧 Fixing Story URLs in Database\n";
echo "================================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n\n";
    
    // Check current story URLs
    echo "🔍 Checking current story URLs...\n";
    $stmt = $db->prepare("SELECT id, media_url, media_type, caption FROM stories LIMIT 10");
    $stmt->execute();
    $stories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($stories)) {
        echo "⚠️ No stories found in database\n";
        exit;
    }
    
    echo "📱 Found " . count($stories) . " stories\n\n";
    
    // Show current URLs
    foreach ($stories as $story) {
        echo "Story ID: {$story['id']}\n";
        echo "  Media URL: {$story['media_url']}\n";
        echo "  Media Type: {$story['media_type']}\n";
        echo "  Caption: {$story['caption']}\n";
        echo "\n";
    }
    
    // Check if URLs need fixing
    $needsFixing = false;
    foreach ($stories as $story) {
        if (strpos($story['media_url'], 'devloperwala.in') !== false) {
            $needsFixing = true;
            break;
        }
    }
    
    if (!$needsFixing) {
        echo "✅ All story URLs are correct\n";
        exit;
    }
    
    echo "🔧 Fixing story URLs...\n";
    
    // Update URLs from old domain to new domain
    $updateStmt = $db->prepare("
        UPDATE stories 
        SET media_url = REPLACE(media_url, 'https://devloperwala.in/MySgram/backend/', 'https://mysgram.com/')
        WHERE media_url LIKE '%devloperwala.in%'
    ");
    
    $result = $updateStmt->execute();
    
    if ($result) {
        $affectedRows = $updateStmt->rowCount();
        echo "✅ Updated $affectedRows story URLs\n";
        
        // Show updated URLs
        echo "\n🔍 Updated story URLs:\n";
        $stmt = $db->prepare("SELECT id, media_url, media_type FROM stories LIMIT 5");
        $stmt->execute();
        $updatedStories = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($updatedStories as $story) {
            echo "Story ID: {$story['id']}\n";
            echo "  New URL: {$story['media_url']}\n";
            echo "  Type: {$story['media_type']}\n\n";
        }
        
    } else {
        echo "❌ Failed to update story URLs\n";
    }
    
    // Add some sample stories with working URLs if needed
    echo "📝 Adding sample stories with working URLs...\n";
    
    $sampleStories = [
        [
            'user_id' => 2, // deepakmishra744
            'media_url' => 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&h=500&fit=crop',
            'media_type' => 'image',
            'caption' => 'Beautiful mountain view! 🏔️'
        ],
        [
            'user_id' => 2,
            'media_url' => 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500&h=500&fit=crop',
            'media_type' => 'image',
            'caption' => 'Peaceful forest walk 🌲'
        ]
    ];
    
    $insertStmt = $db->prepare("
        INSERT INTO stories (user_id, media_url, media_type, caption, created_at)
        VALUES (:user_id, :media_url, :media_type, :caption, NOW())
    ");
    
    foreach ($sampleStories as $story) {
        $insertStmt->execute($story);
        echo "✅ Added sample story for user {$story['user_id']}\n";
    }
    
    echo "\n🎉 Story URL fixing completed!\n";
    echo "Your stories should now display properly.\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
?> 