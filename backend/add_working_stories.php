<?php
header('Content-Type: text/plain; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo "📱 Adding Working Sample Stories\n";
echo "================================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n\n";
    
    // Clear old broken stories
    echo "🧹 Clearing old broken stories...\n";
    $deleteStmt = $db->prepare("DELETE FROM stories WHERE media_url LIKE '%mysgram.com/uploads/stories%'");
    $deleteStmt->execute();
    $deletedCount = $deleteStmt->rowCount();
    echo "✅ Deleted $deletedCount old broken stories\n\n";
    
    // Add working sample stories with real image URLs
    echo "➕ Adding working sample stories...\n";
    
    $workingStories = [
        [
            'user_id' => 2, // deepakmishra744
            'media_url' => 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Beautiful mountain landscape! 🏔️'
        ],
        [
            'user_id' => 2,
            'media_url' => 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Peaceful forest walk 🌲'
        ],
        [
            'user_id' => 2,
            'media_url' => 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Amazing sunset view 🌅'
        ],
        [
            'user_id' => 1, // deepakmishra978
            'media_url' => 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'City skyline at night 🌃'
        ],
        [
            'user_id' => 1,
            'media_url' => 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Adventure awaits! 🚀'
        ],
        [
            'user_id' => 4, // yuvrajpatil888
            'media_url' => 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Ocean waves crashing 🌊'
        ],
        [
            'user_id' => 5, // aprantsavagave821
            'media_url' => 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Desert landscape 🏜️'
        ]
    ];
    
    $insertStmt = $db->prepare("
        INSERT INTO stories (user_id, media_url, media_type, caption, created_at)
        VALUES (:user_id, :media_url, :media_type, :caption, NOW())
    ");
    
    foreach ($workingStories as $story) {
        $insertStmt->execute($story);
        echo "✅ Added story for user {$story['user_id']}: {$story['caption']}\n";
    }
    
    echo "\n📊 Total stories added: " . count($workingStories) . "\n";
    
    // Verify the stories
    echo "\n🔍 Verifying stories in database...\n";
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM stories");
    $stmt->execute();
    $totalStories = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    echo "📱 Total stories in database: $totalStories\n";
    
    // Show sample of what was added
    echo "\n📝 Sample stories added:\n";
    $stmt = $db->prepare("SELECT id, user_id, media_url, caption FROM stories ORDER BY id DESC LIMIT 5");
    $stmt->execute();
    $newStories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($newStories as $story) {
        echo "  - ID: {$story['id']}, User: {$story['user_id']}\n";
        echo "    Caption: {$story['caption']}\n";
        echo "    URL: {$story['media_url']}\n\n";
    }
    
    echo "🎉 Working stories added successfully!\n";
    echo "Your app should now display stories properly.\n";
    echo "These stories use real Unsplash images that will load correctly.\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
?> 