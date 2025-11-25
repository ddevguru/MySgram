<?php
// Test script for signup and login functionality
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

echo "Testing Signup and Login Functionality\n";
echo "=====================================\n\n";

// Test data
$testUser = [
    'username' => 'testuser' . rand(1000, 9999),
    'email' => 'test' . rand(1000, 9999) . '@example.com',
    'password' => 'password123',
    'full_name' => 'Test User'
];

echo "Test User Data:\n";
echo "Username: " . $testUser['username'] . "\n";
echo "Email: " . $testUser['email'] . "\n";
echo "Password: " . $testUser['password'] . "\n\n";

// Test signup
echo "1. Testing Signup...\n";
$signupData = json_encode($testUser);

// Simulate POST request to signup.php
$_SERVER['REQUEST_METHOD'] = 'POST';
$GLOBALS['HTTP_RAW_POST_DATA'] = $signupData;

// Capture output
ob_start();
include 'signup.php';
$signupResponse = ob_get_clean();

echo "Signup Response: " . $signupResponse . "\n\n";

// Parse response
$signupResult = json_decode($signupResponse, true);

if ($signupResult && $signupResult['success']) {
    echo " Signup successful!\n";
    echo "User ID: " . $signupResult['user']['id'] . "\n";
    echo "Token: " . substr($signupResult['token'], 0, 50) . "...\n\n";
    
    // Test login
    echo "2. Testing Login...\n";
    $loginData = json_encode([
        'email' => $testUser['email'],
        'password' => $testUser['password']
    ]);
    
    $GLOBALS['HTTP_RAW_POST_DATA'] = $loginData;
    
    ob_start();
    include 'login.php';
    $loginResponse = ob_get_clean();
    
    echo "Login Response: " . $loginResponse . "\n\n";
    
    $loginResult = json_decode($loginResponse, true);
    
    if ($loginResult && $loginResult['success']) {
        echo " Login successful!\n";
        echo "User ID: " . $loginResult['user']['id'] . "\n";
        echo "Username: " . $loginResult['user']['username'] . "\n";
        echo "Token: " . substr($loginResult['token'], 0, 50) . "...\n\n";
        echo " Both signup and login are working correctly!\n";
    } else {
        echo " Login failed: " . ($loginResult['message'] ?? 'Unknown error') . "\n";
    }
} else {
    echo " Signup failed: " . ($signupResult['message'] ?? 'Unknown error') . "\n";
}

echo "\nTest completed.\n";
?>
