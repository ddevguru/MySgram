<?php
// API Configuration
define('JWT_SECRET', 'your_jwt_secret_key_here_make_it_long_and_secure');
define('JWT_EXPIRE', 86400); // 24 hours

// Google OAuth Configuration
define('GOOGLE_CLIENT_ID', '1028002440504-728rfappe0p97dn0vqlljhh4btsd3bko.apps.googleusercontent.com');
define('GOOGLE_CLIENT_SECRET', ''); // Android doesn't need client secret
define('GOOGLE_REDIRECT_URI', 'http://localhost/mysgram/backend/auth/google_callback.php');

// Facebook OAuth Configuration
define('FACEBOOK_APP_ID', 'your_facebook_app_id_here');
define('FACEBOOK_APP_SECRET', 'your_facebook_app_secret_here');
define('FACEBOOK_REDIRECT_URI', 'http://localhost/mysgram/backend/auth/facebook_callback.php');

// Email Configuration (for password reset)
define('SMTP_HOST', 'smtp.gmail.com');
define('SMTP_PORT', 587);
define('SMTP_USERNAME', 'your_email@gmail.com');
define('SMTP_PASSWORD', 'your_app_password');

// CORS Headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
?> 