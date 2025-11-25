<?php
// This script should be run via cron job every hour
// Example cron job: 0 * * * * /usr/bin/php /path/to/your/project/backend/cron/delete_expired_stories_cron.php

// Set error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', '../logs/cron_errors.log');

// Include database configuration
include_once '../config/database.php';

// Create logs directory if it doesn't exist
if (!file_exists('../logs')) {
    mkdir('../logs', 0777, true);
}

try {
    $database = new Database();
    $db = $database->getConnection();

    // Log the start of the process
    error_log("=== STORY CLEANUP CRON STARTED ===");
    error_log("Time: " . date('Y-m-d H:i:s'));

    // Delete stories older than 24 hours
    $twenty_four_hours_ago = date('Y-m-d H:i:s', strtotime('-24 hours'));
    
    // First, get the list of expired stories to delete their files
    $get_expired_stories_query = "
        SELECT media_url FROM stories 
        WHERE created_at < ?
    ";
    
    $get_stmt = $db->prepare($get_expired_stories_query);
    $get_stmt->bindParam(1, $twenty_four_hours_ago);
    $get_stmt->execute();
    $expired_stories = $get_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $deleted_files_count = 0;
    
    // Delete the actual files
    foreach ($expired_stories as $story) {
        $file_path = str_replace('https://devloperwala.in/MySgram/backend/', '../', $story['media_url']);
        if (file_exists($file_path)) {
            if (unlink($file_path)) {
                $deleted_files_count++;
                error_log("Deleted file: " . $file_path);
            } else {
                error_log("Failed to delete file: " . $file_path);
            }
        }
    }
    
    // Delete expired stories from database
    $delete_stories_query = "
        DELETE FROM stories 
        WHERE created_at < ?
    ";
    
    $delete_stmt = $db->prepare($delete_stories_query);
    $delete_stmt->bindParam(1, $twenty_four_hours_ago);
    $delete_stmt->execute();
    
    $deleted_stories_count = $delete_stmt->rowCount();
    
    // Also delete related story views
    $delete_views_query = "
        DELETE sv FROM story_views sv
        INNER JOIN stories s ON sv.story_id = s.id
        WHERE s.created_at < ?
    ";
    
    $delete_views_stmt = $db->prepare($delete_views_query);
    $delete_views_stmt->bindParam(1, $twenty_four_hours_ago);
    $delete_views_stmt->execute();
    
    $deleted_views_count = $delete_views_stmt->rowCount();
    
    // Log the results
    error_log("Cleanup completed:");
    error_log("- Deleted files: " . $deleted_files_count);
    error_log("- Deleted stories: " . $deleted_stories_count);
    error_log("- Deleted views: " . $deleted_views_count);
    error_log("- Deleted before: " . $twenty_four_hours_ago);
    error_log("=== STORY CLEANUP CRON ENDED ===");

    // Output for cron job logging
    echo "Story cleanup completed at " . date('Y-m-d H:i:s') . "\n";
    echo "Deleted files: $deleted_files_count\n";
    echo "Deleted stories: $deleted_stories_count\n";
    echo "Deleted views: $deleted_views_count\n";

} catch(Exception $e) {
    error_log("Cron job error: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    echo "Error: " . $e->getMessage() . "\n";
}
?> 