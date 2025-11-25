<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $response = array();
    
    // Check if file was uploaded
    if (isset($_FILES['media'])) {
        $file = $_FILES['media'];
        $response['file_info'] = array(
            'name' => $file['name'],
            'type' => $file['type'],
            'size' => $file['size'],
            'error' => $file['error'],
            'tmp_name' => $file['tmp_name']
        );
        
        // Get file extension
        $file_extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        $response['file_extension'] = $file_extension;
        
        // Check MIME type
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime_type = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);
        $response['mime_type'] = $mime_type;
        
        // Check if it's an image
        $allowed_image_extensions = ['jpg', 'jpeg', 'png', 'gif'];
        $allowed_image_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
        
        $is_image_by_extension = in_array($file_extension, $allowed_image_extensions);
        $is_image_by_mime = in_array($mime_type, $allowed_image_types);
        
        $response['validation'] = array(
            'is_image_by_extension' => $is_image_by_extension,
            'is_image_by_mime' => $is_image_by_mime,
            'is_valid_image' => $is_image_by_extension || $is_image_by_mime
        );
        
    } else {
        $response['error'] = 'No file uploaded';
    }
    
    echo json_encode($response, JSON_PRETTY_PRINT);
} else {
    echo json_encode(array("message" => "Use POST method to test file upload"));
}
?> 