<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

try {
    // Check if posts table exists
    $query = "SHOW TABLES LIKE 'posts'";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $table_exists = $stmt->rowCount() > 0;
    
    $response = array(
        'posts_table_exists' => $table_exists,
        'database_connected' => true
    );
    
    if ($table_exists) {
        // Get table structure
        $structure_query = "DESCRIBE posts";
        $structure_stmt = $db->prepare($structure_query);
        $structure_stmt->execute();
        $columns = $structure_stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $response['table_structure'] = $columns;
        
        // Get post count
        $count_query = "SELECT COUNT(*) as total FROM posts";
        $count_stmt = $db->prepare($count_query);
        $count_stmt->execute();
        $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
        
        $response['total_posts'] = $count['total'];
    }
    
    echo json_encode($response, JSON_PRETTY_PRINT);
    
} catch(Exception $e) {
    echo json_encode(array(
        'error' => $e->getMessage(),
        'database_connected' => false
    ));
}
?> 