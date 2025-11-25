<?php
// Local Database Configuration for Testing
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'database_error.log');

class Database {
    private System.Management.Automation.Internal.Host.InternalHost = "localhost";
    private  = "mysgram_local";
    private  = "root";
    private  = "";
    public ;

    public function getConnection() {
        ->conn = null;

        try {
            ->conn = new PDO("mysql:host=" . ->host . ";dbname=" . ->db_name, ->username, ->password);
            ->conn->exec("set names utf8");
            ->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch(PDOException ) {
            error_log("Database connection error: " . ->getMessage());
            echo "Connection error: " . ->getMessage();
        }

        return ->conn;
    }
    
    public function getDatabaseName() {
        return ->db_name;
    }
}

// Create global PDO connection for direct use
try {
     = new Database();
     = ->getConnection();
    
    if (!) {
        error_log("Failed to create PDO connection");
        throw new Exception("Database connection failed");
    }
    
    error_log("Global PDO connection created successfully");
} catch (Exception ) {
    error_log("Error creating global PDO connection: " . ->getMessage());
     = null;
}
?>
