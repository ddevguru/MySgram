<?php
require_once '../config/config.php';
require_once '../config/database.php';
require_once '../models/User.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Initialize user object
$user = new User($db);

// Get posted data
$data = json_decode(file_get_contents("php://input"));

if(!empty($data->email)) {
    
    $user->email = $data->email;
    
    // Check if email exists
    if($user->emailExists()) {
        
        // Generate reset token
        $reset_token = bin2hex(random_bytes(32));
        $expires_at = date('Y-m-d H:i:s', strtotime('+1 hour'));
        
        // Store reset token in database
        $query = "INSERT INTO password_reset_tokens (email, token, expires_at) VALUES (?, ?, ?)";
        $stmt = $db->prepare($query);
        
        if($stmt->execute([$user->email, $reset_token, $expires_at])) {
            
            // Send email with reset link (you'll need to implement email sending)
            $reset_link = "https://devloperwala.in/MySgram/reset_password.html?token=" . $reset_token;
            
            // For now, just return the token (in production, send via email)
            http_response_code(200);
            echo json_encode(array(
                "message" => "Password reset link sent to your email.",
                "reset_token" => $reset_token, // Remove this in production
                "reset_link" => $reset_link // Remove this in production
            ));
        } else {
            http_response_code(503);
            echo json_encode(array("message" => "Unable to process password reset."));
        }
    } else {
        http_response_code(404);
        echo json_encode(array("message" => "Email not found."));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Email is required."));
}
?> 