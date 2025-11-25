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

if(!empty($data->token) && !empty($data->new_password)) {
    
    $token = $data->token;
    $new_password = $data->new_password;
    
    // Validate password strength
    if (strlen($new_password) < 6) {
        http_response_code(400);
        echo json_encode(array("message" => "Password must be at least 6 characters long."));
        exit();
    }
    
    // Check if token exists and is valid
    $query = "SELECT email, expires_at FROM password_reset_tokens WHERE token = ? AND expires_at > NOW()";
    $stmt = $db->prepare($query);
    $stmt->execute([$token]);
    
    if($stmt->rowCount() > 0) {
        $token_data = $stmt->fetch(PDO::FETCH_ASSOC);
        $email = $token_data['email'];
        
        // Get user by email
        $user->email = $email;
        if($user->emailExists()) {
            
            // Update password
            $user->password = $new_password;
            if($user->updatePassword()) {
                
                // Delete the used token
                $delete_query = "DELETE FROM password_reset_tokens WHERE token = ?";
                $delete_stmt = $db->prepare($delete_query);
                $delete_stmt->execute([$token]);
                
                http_response_code(200);
                echo json_encode(array("message" => "Password reset successfully."));
            } else {
                http_response_code(503);
                echo json_encode(array("message" => "Unable to reset password."));
            }
        } else {
            http_response_code(404);
            echo json_encode(array("message" => "User not found."));
        }
    } else {
        http_response_code(400);
        echo json_encode(array("message" => "Invalid or expired token."));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Token and new password are required."));
}
?> 