<?php
require_once '../config/database.php';

class User {
    private $conn;
    private $table_name = "users";

    // User properties
    public $id;
    public $username;
    public $email;
    public $password;
    public $full_name;
    public $profile_picture;
    public $bio;
    public $website;
    public $location;
    public $phone;
    public $gender;
    public $date_of_birth;
    public $followers_count;
    public $following_count;
    public $posts_count;
    public $is_private;
    public $is_verified;
    public $auth_provider;
    public $auth_provider_id;
    public $created_at;
    public $updated_at;

    public function __construct($db) {
        $this->conn = $db;
    }

    // Create user
    public function create() {
        $query = "INSERT INTO " . $this->table_name . "
                (username, email, password, full_name, profile_picture, bio, website, location, phone, gender, date_of_birth, auth_provider, auth_provider_id, is_verified)
                VALUES
                (:username, :email, :password, :full_name, :profile_picture, :bio, :website, :location, :phone, :gender, :date_of_birth, :auth_provider, :auth_provider_id, :is_verified)";

        $stmt = $this->conn->prepare($query);

        // Sanitize inputs
        $this->username = htmlspecialchars(strip_tags($this->username));
        $this->email = htmlspecialchars(strip_tags($this->email));
        $this->password = htmlspecialchars(strip_tags($this->password));
        $this->full_name = htmlspecialchars(strip_tags($this->full_name));
        $this->profile_picture = htmlspecialchars(strip_tags($this->profile_picture));
        $this->bio = htmlspecialchars(strip_tags($this->bio ?? ''));
        $this->website = htmlspecialchars(strip_tags($this->website ?? ''));
        $this->location = htmlspecialchars(strip_tags($this->location ?? ''));
        $this->phone = htmlspecialchars(strip_tags($this->phone ?? ''));
        $this->gender = htmlspecialchars(strip_tags($this->gender ?? ''));
        $this->date_of_birth = htmlspecialchars(strip_tags($this->date_of_birth ?? ''));
        $this->auth_provider = htmlspecialchars(strip_tags($this->auth_provider ?? ''));
        $this->auth_provider_id = htmlspecialchars(strip_tags($this->auth_provider_id ?? ''));

        // Bind parameters
        $stmt->bindParam(":username", $this->username);
        $stmt->bindParam(":email", $this->email);
        $stmt->bindParam(":password", $this->password);
        $stmt->bindParam(":full_name", $this->full_name);
        $stmt->bindParam(":profile_picture", $this->profile_picture);
        $stmt->bindParam(":bio", $this->bio);
        $stmt->bindParam(":website", $this->website);
        $stmt->bindParam(":location", $this->location);
        $stmt->bindParam(":phone", $this->phone);
        $stmt->bindParam(":gender", $this->gender);
        $stmt->bindParam(":date_of_birth", $this->date_of_birth);
        $stmt->bindParam(":auth_provider", $this->auth_provider);
        $stmt->bindParam(":auth_provider_id", $this->auth_provider_id);
        $stmt->bindParam(":is_verified", $this->is_verified);

        if($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        return false;
    }

    // Update user
    public function update() {
        $query = "UPDATE " . $this->table_name . "
                SET username = :username, email = :email, full_name = :full_name, 
                    profile_picture = :profile_picture, bio = :bio, website = :website, 
                    location = :location, phone = :phone, gender = :gender, 
                    date_of_birth = :date_of_birth, is_private = :is_private, 
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        // Sanitize inputs
        $this->username = htmlspecialchars(strip_tags($this->username));
        $this->email = htmlspecialchars(strip_tags($this->email));
        $this->full_name = htmlspecialchars(strip_tags($this->full_name));
        $this->profile_picture = htmlspecialchars(strip_tags($this->profile_picture));
        $this->bio = htmlspecialchars(strip_tags($this->bio ?? ''));
        $this->website = htmlspecialchars(strip_tags($this->website ?? ''));
        $this->location = htmlspecialchars(strip_tags($this->location ?? ''));
        $this->phone = htmlspecialchars(strip_tags($this->phone ?? ''));
        $this->gender = htmlspecialchars(strip_tags($this->gender ?? ''));
        $this->date_of_birth = htmlspecialchars(strip_tags($this->date_of_birth ?? ''));

        // Bind parameters
        $stmt->bindParam(":username", $this->username);
        $stmt->bindParam(":email", $this->email);
        $stmt->bindParam(":full_name", $this->full_name);
        $stmt->bindParam(":profile_picture", $this->profile_picture);
        $stmt->bindParam(":bio", $this->bio);
        $stmt->bindParam(":website", $this->website);
        $stmt->bindParam(":location", $this->location);
        $stmt->bindParam(":phone", $this->phone);
        $stmt->bindParam(":gender", $this->gender);
        $stmt->bindParam(":date_of_birth", $this->date_of_birth);
        $stmt->bindParam(":is_private", $this->is_private);
        $stmt->bindParam(":id", $this->id);

        return $stmt->execute();
    }

    // Update specific fields
    public function updateFields($fields) {
        $set_clause = "";
        $params = array();

        foreach($fields as $field => $value) {
            if($set_clause != "") {
                $set_clause .= ", ";
            }
            $set_clause .= "$field = :$field";
            $params[":$field"] = htmlspecialchars(strip_tags($value));
        }

        $set_clause .= ", updated_at = CURRENT_TIMESTAMP";

        $query = "UPDATE " . $this->table_name . " SET $set_clause WHERE id = :id";
        $stmt = $this->conn->prepare($query);

        $params[":id"] = $this->id;

        foreach($params as $param => $value) {
            $stmt->bindValue($param, $value);
        }

        return $stmt->execute();
    }

    // Check if email exists
    public function emailExists() {
        $query = "SELECT id FROM " . $this->table_name . " WHERE email = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->email);
        $stmt->execute();
        return $stmt->rowCount() > 0;
    }

    // Check if username exists
    public function usernameExists() {
        $query = "SELECT id FROM " . $this->table_name . " WHERE username = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->username);
        $stmt->execute();
        return $stmt->rowCount() > 0;
    }

    // Get user by auth provider
    public function getByAuthProviderId($provider, $provider_id) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE auth_provider = ? AND auth_provider_id = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $provider);
        $stmt->bindParam(2, $provider_id);
        $stmt->execute();

        if($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $this->id = $row['id'];
            $this->username = $row['username'];
            $this->email = $row['email'];
            $this->full_name = $row['full_name'];
            $this->profile_picture = $row['profile_picture'];
            $this->bio = $row['bio'];
            $this->website = $row['website'];
            $this->location = $row['location'];
            $this->phone = $row['phone'];
            $this->gender = $row['gender'];
            $this->date_of_birth = $row['date_of_birth'];
            $this->followers_count = $row['followers_count'];
            $this->following_count = $row['following_count'];
            $this->posts_count = $row['posts_count'];
            $this->is_private = $row['is_private'];
            $this->is_verified = $row['is_verified'];
            $this->auth_provider = $row['auth_provider'];
            $this->auth_provider_id = $row['auth_provider_id'];
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];
            return true;
        }
        return false;
    }

    // Get user by ID
    public function getById($id) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE id = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $id);
        $stmt->execute();

        if($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Update counts before returning (only update, don't fetch again)
            $this->id = $row['id'];
            $this->updateCounts();
            
            // Fetch updated counts
            $countsQuery = "SELECT followers_count, following_count, posts_count, streak_count FROM " . $this->table_name . " WHERE id = ?";
            $countsStmt = $this->conn->prepare($countsQuery);
            $countsStmt->bindParam(1, $id);
            $countsStmt->execute();
            $countsRow = $countsStmt->fetch(PDO::FETCH_ASSOC);
            
            return array(
                'id' => $row['id'],
                'username' => $row['username'],
                'email' => $row['email'],
                'full_name' => $row['full_name'],
                'profile_picture' => $row['profile_picture'],
                'bio' => $row['bio'],
                'website' => $row['website'],
                'location' => $row['location'],
                'phone' => $row['phone'],
                'gender' => $row['gender'],
                'date_of_birth' => $row['date_of_birth'],
                'followers_count' => (int)($countsRow['followers_count'] ?? $row['followers_count'] ?? 0),
                'following_count' => (int)($countsRow['following_count'] ?? $row['following_count'] ?? 0),
                'posts_count' => (int)($countsRow['posts_count'] ?? $row['posts_count'] ?? 0),
                'streak_count' => (int)($countsRow['streak_count'] ?? $row['streak_count'] ?? 0),
                'is_private' => $row['is_private'],
                'is_verified' => $row['is_verified'],
                'auth_provider' => $row['auth_provider'],
                'auth_provider_id' => $row['auth_provider_id'],
                'created_at' => $row['created_at'],
                'updated_at' => $row['updated_at']
            );
        }
        return null;
    }

    // Get user by email
    public function getByEmail($email) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE email = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $email);
        $stmt->execute();

        if($stmt->rowCount() > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $this->id = $row['id'];
            $this->username = $row['username'];
            $this->email = $row['email'];
            $this->password = $row['password'];
            $this->full_name = $row['full_name'];
            $this->profile_picture = $row['profile_picture'];
            $this->bio = $row['bio'];
            $this->website = $row['website'];
            $this->location = $row['location'];
            $this->phone = $row['phone'];
            $this->gender = $row['gender'];
            $this->date_of_birth = $row['date_of_birth'];
            $this->followers_count = $row['followers_count'];
            $this->following_count = $row['following_count'];
            $this->posts_count = $row['posts_count'];
            $this->is_private = $row['is_private'];
            $this->is_verified = $row['is_verified'];
            $this->auth_provider = $row['auth_provider'];
            $this->auth_provider_id = $row['auth_provider_id'];
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];
            return true;
        }
        return false;
    }

    // Update user counts
    public function updateCounts() {
        // Update followers count
        $query = "UPDATE " . $this->table_name . " 
                SET followers_count = (SELECT COUNT(*) FROM follows WHERE following_id = ?)
                WHERE id = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->id);
        $stmt->bindParam(2, $this->id);
        $stmt->execute();

        // Update following count
        $query = "UPDATE " . $this->table_name . " 
                SET following_count = (SELECT COUNT(*) FROM follows WHERE follower_id = ?)
                WHERE id = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->id);
        $stmt->bindParam(2, $this->id);
        $stmt->execute();

        // Update posts count
        $query = "UPDATE " . $this->table_name . " 
                SET posts_count = (SELECT COUNT(*) FROM posts WHERE user_id = ?)
                WHERE id = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->id);
        $stmt->bindParam(2, $this->id);
        $stmt->execute();
    }
}
?> 