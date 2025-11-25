<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Check if notifications table exists
    $checkTable = $db->query("SHOW TABLES LIKE 'notifications'");
    $tableExists = $checkTable->rowCount() > 0;
    
    if (!$tableExists) {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Notifications table does not exist. Please create it first."
        ));
        exit();
    }
    
    // Get a user to create notifications for (user ID 1)
    $recipientId = 1;
    
    // Check if user exists
    $userCheck = $db->prepare("SELECT id FROM users WHERE id = ?");
    $userCheck->execute([$recipientId]);
    if ($userCheck->rowCount() == 0) {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "User with ID $recipientId does not exist"
        ));
        exit();
    }
    
    // Get other users to create notifications from
    $otherUsers = $db->query("SELECT id FROM users WHERE id != $recipientId LIMIT 3")->fetchAll(PDO::FETCH_COLUMN);
    
    if (empty($otherUsers)) {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "No other users found to create notifications from"
        ));
        exit();
    }
    
    // Clear existing notifications for this user
    $db->prepare("DELETE FROM notifications WHERE recipient_id = ?")->execute([$recipientId]);
    
    // Get user names for notifications
    $userNames = $db->query("SELECT id, username FROM users WHERE id IN (" . implode(',', $otherUsers) . ")")->fetchAll(PDO::FETCH_KEY_PAIR);
    
    // Add sample notifications
    $notifications = [
        [
            'sender_id' => $otherUsers[0],
            'sender_name' => $userNames[$otherUsers[0]] ?? 'User',
            'type' => 'follow',
            'title' => 'New Follower',
            'message' => 'started following you',
            'created_at' => date('Y-m-d H:i:s', strtotime('-2 hours'))
        ],
        [
            'sender_id' => $otherUsers[0],
            'sender_name' => $userNames[$otherUsers[0]] ?? 'User',
            'type' => 'like',
            'title' => 'New Like',
            'message' => 'liked your post',
            'created_at' => date('Y-m-d H:i:s', strtotime('-1 hour'))
        ],
        [
            'sender_id' => isset($otherUsers[1]) ? $otherUsers[1] : $otherUsers[0],
            'sender_name' => isset($otherUsers[1]) ? ($userNames[$otherUsers[1]] ?? 'User') : ($userNames[$otherUsers[0]] ?? 'User'),
            'type' => 'comment',
            'title' => 'New Comment',
            'message' => 'commented: "Great post! 👍"',
            'created_at' => date('Y-m-d H:i:s', strtotime('-30 minutes'))
        ],
        [
            'sender_id' => isset($otherUsers[2]) ? $otherUsers[2] : $otherUsers[0],
            'sender_name' => isset($otherUsers[2]) ? ($userNames[$otherUsers[2]] ?? 'User') : ($userNames[$otherUsers[0]] ?? 'User'),
            'type' => 'follow',
            'title' => 'New Follower',
            'message' => 'started following you',
            'created_at' => date('Y-m-d H:i:s', strtotime('-15 minutes'))
        ]
    ];
    
    $insertQuery = "INSERT INTO notifications (recipient_id, sender_id, sender_name, type, title, message, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)";
    $insertStmt = $db->prepare($insertQuery);
    
    $insertedCount = 0;
    foreach ($notifications as $notification) {
        $insertStmt->execute([
            $recipientId,
            $notification['sender_id'],
            $notification['sender_name'],
            $notification['type'],
            $notification['title'],
            $notification['message'],
            $notification['created_at']
        ]);
        $insertedCount++;
    }
    
    http_response_code(200);
    echo json_encode(array(
        "success" => true,
        "message" => "Added $insertedCount sample notifications for user ID $recipientId",
        "notifications_added" => $insertedCount
    ));
    
} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array(
        "success" => false,
        "message" => "Database error: " . $e->getMessage()
    ));
}
?> 