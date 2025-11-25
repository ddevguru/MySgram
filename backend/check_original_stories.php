<?php
header('Content-Type: text/plain; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo "🔍 Checking Original Stories in Database\n";
echo "=======================================\n\n";

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Failed to connect to database");
    }
    
    echo "✅ Database connection successful\n\n";
    
    // Check current stories
    echo "📱 Current stories in database:\n";
    $stmt = $db->prepare("SELECT id, user_id, media_url, media_type, caption, created_at FROM stories ORDER BY id");
    $stmt->execute();
    $currentStories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($currentStories)) {
        echo "⚠️ No stories found in database\n";
    } else {
        echo "📊 Total stories: " . count($currentStories) . "\n\n";
        
        foreach ($currentStories as $story) {
            echo "Story ID: {$story['id']}\n";
            echo "  User ID: {$story['user_id']}\n";
            echo "  Media URL: {$story['media_url']}\n";
            echo "  Media Type: {$story['media_type']}\n";
            echo "  Caption: {$story['caption']}\n";
            echo "  Created: {$story['created_at']}\n";
            echo "\n";
        }
    }
    
    // Check if there are any story files in uploads directory
    echo "📁 Checking for story files...\n";
    
    // Try to find story files that might exist
    $uploadDir = '../uploads/stories/';
    if (is_dir($uploadDir)) {
        $files = scandir($uploadDir);
        $storyFiles = array_filter($files, function($file) {
            return !in_array($file, ['.', '..']) && (strpos($file, 'story_') === 0);
        });
        
        if (!empty($storyFiles)) {
            echo "📸 Found story files in uploads directory:\n";
            foreach ($storyFiles as $file) {
                echo "  - $file\n";
            }
        } else {
            echo "⚠️ No story files found in uploads directory\n";
        }
    } else {
        echo "⚠️ Uploads directory not found\n";
    }
    
    // Check users who might have stories
    echo "\n👥 Users who might have stories:\n";
    $stmt = $db->prepare("SELECT id, username, full_name FROM users ORDER BY id");
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($users as $user) {
        echo "  - User ID: {$user['id']}, Username: {$user['username']}, Name: {$user['full_name']}\n";
    }
    
    echo "\n💡 To restore your uploaded stories:\n";
    echo "1. Check if story files exist in your uploads folder\n";
    echo "2. We can recreate the story records with correct URLs\n";
    echo "3. Or upload new stories through your app\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
?> 