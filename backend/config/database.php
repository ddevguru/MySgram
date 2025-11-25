<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'database_error.log');

class Database {
    private $host = "103.120.179.212";
    private $db_name = "mysgram_db";
    private $username = "sources";
    private $password = "Sources@123";
    public $conn;

    public function getConnection() {
        $this->conn = null;

        try {
            $this->conn = new PDO("mysql:host=" . $this->host . ";dbname=" . $this->db_name, $this->username, $this->password);
            $this->conn->exec("set names utf8");
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch(PDOException $exception) {
            error_log("Database connection error: " . $exception->getMessage());
            echo "Connection error: " . $exception->getMessage();
        }

        return $this->conn;
    }
    
    public function getDatabaseName() {
        return $this->db_name;
    }
}

// Create global PDO connection for direct use
try {
    $database = new Database();
    $pdo = $database->getConnection();
    
    if (!$pdo) {
        error_log("Failed to create PDO connection");
        throw new Exception("Database connection failed");
    }
    
    error_log("Global PDO connection created successfully");
} catch (Exception $e) {
    error_log("Error creating global PDO connection: " . $e->getMessage());
    $pdo = null;
}
?> 