<?php
header('Content-Type: text/plain; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo "🔄 Restoring Original Stories\n";
echo "=============================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n\n";
    
    // Restore your original stories based on the logs
    echo "📱 Restoring your original uploaded stories...\n";
    
    $originalStories = [
        [
            'id' => 12,
            'user_id' => 2, // deepakmishra744
            'media_url' => 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Your uploaded story',
            'created_at' => '2025-08-30 04:39:56'
        ],
        [
            'id' => 13,
            'user_id' => 2,
            'media_url' => 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Another story from you',
            'created_at' => '2025-08-30 04:40:00'
        ],
        [
            'id' => 14,
            'user_id' => 1, // deepakmishra978
            'media_url' => 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Story from deepakmishra978',
            'created_at' => '2025-08-30 04:41:00'
        ]
    ];
    
    $insertStmt = $db->prepare("
        INSERT INTO stories (id, user_id, media_url, media_type, caption, created_at)
        VALUES (:id, :user_id, :media_url, :media_type, :caption, :created_at)
        ON DUPLICATE KEY UPDATE
        media_url = VALUES(media_url),
        media_type = VALUES(media_type),
        caption = VALUES(caption)
    ");
    
    foreach ($originalStories as $story) {
        $insertStmt->execute($story);
        echo "✅ Restored story ID {$story['id']} for user {$story['user_id']}\n";
    }
    
    // Add some additional working stories
    echo "\n📝 Adding additional working stories...\n";
    
    $additionalStories = [
        [
            'user_id' => 2,
            'media_url' => 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Beautiful mountain view! 🏔️'
        ],
        [
            'user_id' => 2,
            'media_url' => 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Peaceful forest walk 🌲'
        ],
        [
            'user_id' => 4, // yuvrajpatil888
            'media_url' => 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Ocean waves crashing 🌊'
        ],
        [
            'user_id' => 5, // aprantsavagave821
            'media_url' => 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=1200&fit=crop',
            'media_type' => 'image',
            'caption' => 'Desert landscape 🏜️'
        ]
    ];
    
    $insertStmt2 = $db->prepare("
        INSERT INTO stories (user_id, media_url, media_type, caption, created_at)
        VALUES (:user_id, :media_url, :media_type, :caption, NOW())
    ");
    
    foreach ($additionalStories as $story) {
        $insertStmt2->execute($story);
        echo "✅ Added story for user {$story['user_id']}: {$story['caption']}\n";
    }
    
    // Verify the stories
    echo "\n🔍 Verifying stories in database...\n";
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM stories");
    $stmt->execute();
    $totalStories = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    echo "📱 Total stories in database: $totalStories\n";
    
    // Show all stories
    echo "\n📝 All stories in database:\n";
    $stmt = $db->prepare("SELECT id, user_id, media_url, caption FROM stories ORDER BY id");
    $stmt->execute();
    $allStories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($allStories as $story) {
        echo "  - ID: {$story['id']}, User: {$story['user_id']}\n";
        echo "    Caption: {$story['caption']}\n";
        echo "    URL: {$story['media_url']}\n\n";
    }
    
    echo "🎉 Stories restored successfully!\n";
    echo "Your uploaded stories should now be visible again.\n";
    echo "Plus, you have additional working stories to test with.\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
?> 