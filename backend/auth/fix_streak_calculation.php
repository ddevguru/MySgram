<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../config/database.php';
include_once '../utils/JWT.php';

$database = new Database();
$db = $database->getConnection();

try {
    // Get all users with posts
    $users_query = "SELECT u.id, u.username, u.posts_count, u.streak_count, u.last_post_date,
                           COUNT(p.id) as actual_posts_count,
                           MIN(p.created_at) as first_post_date,
                           MAX(p.created_at) as last_post_date_actual
                    FROM users u 
                    LEFT JOIN posts p ON u.id = p.user_id 
                    WHERE u.posts_count > 0 
                    GROUP BY u.id";
    
    $users_stmt = $db->prepare($users_query);
    $users_stmt->execute();
    $users = $users_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $fixes = [];
    
    foreach ($users as $user) {
        $user_id = $user['id'];
        $username = $user['username'];
        $posts_count = $user['posts_count'];
        $current_streak = $user['streak_count'];
        $actual_posts_count = $user['actual_posts_count'];
        $last_post_date = $user['last_post_date_actual'];
        
        // If user has posts but zero streak, calculate proper streak
        if ($actual_posts_count > 0 && $current_streak == 0) {
            // Calculate streak based on consecutive days with posts
            $streak_query = "SELECT DATE(created_at) as post_date 
                           FROM posts 
                           WHERE user_id = ? 
                           GROUP BY DATE(created_at) 
                           ORDER BY post_date DESC";
            
            $streak_stmt = $db->prepare($streak_query);
            $streak_stmt->bindParam(1, $user_id);
            $streak_stmt->execute();
            $post_dates = $streak_stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $calculated_streak = 0;
            $today = date('Y-m-d');
            $yesterday = date('Y-m-d', strtotime('-1 day'));
            
            // Check if user posted today
            $posted_today = false;
            $posted_yesterday = false;
            
            foreach ($post_dates as $date_row) {
                $post_date = $date_row['post_date'];
                if ($post_date == $today) {
                    $posted_today = true;
                }
                if ($post_date == $yesterday) {
                    $posted_yesterday = true;
                }
            }
            
            // Calculate streak
            if ($posted_today) {
                $calculated_streak = 1;
                // Count consecutive days backwards
                $current_date = $yesterday;
                while (true) {
                    $found = false;
                    foreach ($post_dates as $date_row) {
                        if ($date_row['post_date'] == $current_date) {
                            $calculated_streak++;
                            $found = true;
                            break;
                        }
                    }
                    if (!$found) break;
                    $current_date = date('Y-m-d', strtotime($current_date . ' -1 day'));
                }
            } elseif ($posted_yesterday) {
                $calculated_streak = 1;
                // Count consecutive days backwards from yesterday
                $current_date = date('Y-m-d', strtotime('-2 day'));
                while (true) {
                    $found = false;
                    foreach ($post_dates as $date_row) {
                        if ($date_row['post_date'] == $current_date) {
                            $calculated_streak++;
                            $found = true;
                            break;
                        }
                    }
                    if (!$found) break;
                    $current_date = date('Y-m-d', strtotime($current_date . ' -1 day'));
                }
            } else {
                // User hasn't posted today or yesterday, streak is 0
                $calculated_streak = 0;
            }
            
            // Update user's streak and last_post_date
            $update_query = "UPDATE users SET streak_count = ?, last_post_date = ? WHERE id = ?";
            $update_stmt = $db->prepare($update_query);
            $update_stmt->bindParam(1, $calculated_streak);
            $update_stmt->bindParam(2, $last_post_date);
            $update_stmt->bindParam(3, $user_id);
            $update_stmt->execute();
            
            $fixes[] = array(
                "user" => $username,
                "old_streak" => $current_streak,
                "new_streak" => $calculated_streak,
                "posts_count" => $actual_posts_count,
                "last_post_date" => $last_post_date
            );
        }
    }
    
    http_response_code(200);
    echo json_encode(array(
        "message" => "Streak calculation completed",
        "fixes_applied" => $fixes,
        "total_users_checked" => count($users)
    ));
    
} catch(Exception $e) {
    http_response_code(500);
    echo json_encode(array("message" => "Database error: " . $e->getMessage()));
}
?> 