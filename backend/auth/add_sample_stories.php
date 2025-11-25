<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Check if stories table exists
    $checkTable = $db->query("SHOW TABLES LIKE 'stories'");
    $tableExists = $checkTable->rowCount() > 0;
    
    if (!$tableExists) {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Stories table does not exist. Please create it first."
        ));
        exit();
    }
    
    // Get users to create stories for
    $users = $db->query("SELECT id, username FROM users LIMIT 3")->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($users)) {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "No users found to create stories for"
        ));
        exit();
    }
    
    // Clear existing stories
    $db->query("DELETE FROM stories");
    
    // Add sample stories
    $sampleStories = [
        [
            'user_id' => $users[0]['id'],
            'media_url' => 'https://devloperwala.in/MySgram/backend/uploads/stories/story_1.jpg',
            'media_type' => 'image',
            'caption' => 'My first story! 📸'
        ],
        [
            'user_id' => $users[0]['id'],
            'media_url' => 'https://devloperwala.in/MySgram/backend/uploads/stories/story_2.jpg',
            'media_type' => 'image',
            'caption' => 'Beautiful day! ☀️'
        ],
        [
            'user_id' => isset($users[1]) ? $users[1]['id'] : $users[0]['id'],
            'media_url' => 'https://devloperwala.in/MySgram/backend/uploads/stories/story_3.jpg',
            'media_type' => 'image',
            'caption' => 'Amazing view! 🌅'
        ],
        [
            'user_id' => isset($users[2]) ? $users[2]['id'] : $users[0]['id'],
            'media_url' => 'https://devloperwala.in/MySgram/backend/uploads/stories/story_4.jpg',
            'media_type' => 'image',
            'caption' => 'Great food! 🍕'
        ]
    ];
    
    $insertQuery = "INSERT INTO stories (user_id, media_url, media_type, caption) VALUES (?, ?, ?, ?)";
    $insertStmt = $db->prepare($insertQuery);
    
    $insertedCount = 0;
    foreach ($sampleStories as $story) {
        $insertStmt->execute([
            $story['user_id'],
            $story['media_url'],
            $story['media_type'],
            $story['caption']
        ]);
        $insertedCount++;
    }
    
    http_response_code(200);
    echo json_encode(array(
        "success" => true,
        "message" => "Added $insertedCount sample stories",
        "stories_added" => $insertedCount
    ));
    
} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array(
        "success" => false,
        "message" => "Database error: " . $e->getMessage()
    ));
}
?> 