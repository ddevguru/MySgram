<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Include database and object files
include_once '../config/database.php';
include_once '../models/User.php';
include_once '../utils/JWT.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Prepare user object
$user = new User($db);

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Check if data is not empty
if(!empty($data->token)) {
    try {
        // Debug: Log the token
        error_log("Update Profile - Token received: " . substr($data->token, 0, 50) . "...");
        
        // Verify JWT token
        $decoded = JWT::verify($data->token);
        if (!$decoded) {
            error_log("Update Profile - Token verification failed");
            http_response_code(401);
            echo json_encode(array("message" => "Invalid token."));
            exit();
        }
        
        $user_id = $decoded['user_id'];
        error_log("Update Profile - User ID from token: " . $user_id);
        
        // Get user by ID
        $user_data = $user->getById($user_id);
        if(!$user_data) {
            error_log("Update Profile - User not found for ID: " . $user_id);
            http_response_code(404);
            echo json_encode(array("message" => "User not found."));
            exit();
        }
        error_log("Update Profile - User found: " . $user_data['username']);
        
        // Set user ID
        $user->id = $user_id;
        
        // Update fields if provided
        $update_fields = array();
        
        if(isset($data->username) && !empty($data->username)) {
            // Check if username is already taken by another user
            $user->username = $data->username;
            if($user->usernameExists() && $user_data['username'] !== $data->username) {
                http_response_code(400);
                echo json_encode(array("message" => "Username already taken."));
                exit();
            }
            $update_fields['username'] = $data->username;
        }
        
        if(isset($data->full_name)) {
            $update_fields['full_name'] = $data->full_name;
        }
        
        if(isset($data->bio)) {
            $update_fields['bio'] = $data->bio;
        }
        
        if(isset($data->website)) {
            $update_fields['website'] = $data->website;
        }
        
        if(isset($data->location)) {
            $update_fields['location'] = $data->location;
        }
        
        if(isset($data->phone)) {
            $update_fields['phone'] = $data->phone;
        }
        
        if(isset($data->gender)) {
            $update_fields['gender'] = $data->gender;
        }
        
        if(isset($data->date_of_birth)) {
            $update_fields['date_of_birth'] = $data->date_of_birth;
        }
        
        if(isset($data->is_private)) {
            $update_fields['is_private'] = $data->is_private ? 1 : 0;
        }
        
        if(isset($data->profile_picture)) {
            $update_fields['profile_picture'] = $data->profile_picture;
        }
        
        // Update user if there are fields to update
        if(!empty($update_fields)) {
            if($user->updateFields($update_fields)) {
                // Get updated user data
                $updated_user = $user->getById($user_id);
                
                http_response_code(200);
                echo json_encode(array(
                    "message" => "Profile updated successfully.",
                    "user" => $updated_user
                ));
            } else {
                http_response_code(503);
                echo json_encode(array("message" => "Unable to update profile."));
            }
        } else {
            http_response_code(400);
            echo json_encode(array("message" => "No fields to update."));
        }
        
    } catch(Exception $e) {
        http_response_code(401);
        echo json_encode(array("message" => "Invalid token."));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Token is required."));
}
?> 