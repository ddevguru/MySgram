-- Simple Chat System Database Schema
-- Run this in your MySQL/phpMyAdmin

-- Users table for manual registration and Google login
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NULL, -- NULL for Google users
    google_id VARCHAR(100) NULL, -- Google user ID
    profile_picture VARCHAR(255) NULL,
    coins INT DEFAULT 1000, -- Starting coins
    is_online BOOLEAN DEFAULT FALSE,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Chat rooms table
CREATE TABLE IF NOT EXISTS chat_rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id VARCHAR(100) UNIQUE NOT NULL,
    user_id_1 INT NOT NULL,
    user_id_2 INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_message TEXT NULL,
    unread_count INT DEFAULT 0,
    FOREIGN KEY (user_id_1) REFERENCES users(id),
    FOREIGN KEY (user_id_2) REFERENCES users(id)
);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message_id VARCHAR(100) UNIQUE NOT NULL,
    room_id VARCHAR(100) NOT NULL,
    sender_id INT NOT NULL,
    message TEXT NOT NULL,
    reply_to VARCHAR(100) NULL,
    message_type ENUM('text', 'image', 'video', 'audio', 'file', 'gift', 'location') DEFAULT 'text',
    metadata JSON NULL,
    is_seen BOOLEAN DEFAULT FALSE,
    seen_at TIMESTAMP NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES chat_rooms(room_id),
    FOREIGN KEY (sender_id) REFERENCES users(id)
);

-- Gift categories table
CREATE TABLE IF NOT EXISTS gift_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    icon VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Gift items table
CREATE TABLE IF NOT EXISTS gift_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    icon VARCHAR(10) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    coins INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES gift_categories(id)
);

-- Gift transactions table
CREATE TABLE IF NOT EXISTS gift_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    recipient_id INT NOT NULL,
    gift_id INT NOT NULL,
    quantity INT DEFAULT 1,
    total_cost INT NOT NULL,
    message TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (recipient_id) REFERENCES users(id),
    FOREIGN KEY (gift_id) REFERENCES gift_items(id)
);

-- Insert sample gift categories
INSERT INTO gift_categories (name, icon) VALUES
('Love & Hearts', '❤️'),
('Celebration', '🎉'),
('Nature', '🌿'),
('Animals', '🐾'),
('Premium', '💎');

-- Insert sample gift items
INSERT INTO gift_items (category_id, name, icon, price, coins) VALUES
(1, 'Rose', '🌹', 0.99, 100),
(1, 'Heart', '💖', 1.99, 200),
(1, 'Kiss', '💋', 2.99, 300),
(2, 'Cake', '🎂', 4.99, 500),
(2, 'Balloon', '🎈', 2.49, 250),
(2, 'Party', '🎊', 9.99, 1000),
(3, 'Flower', '🌸', 1.49, 150),
(3, 'Tree', '🌳', 3.99, 400),
(3, 'Sun', '☀️', 3.49, 350),
(4, 'Cat', '🐱', 4.49, 450),
(4, 'Dog', '🐕', 5.49, 550),
(4, 'Butterfly', '🦋', 2.99, 300),
(5, 'Diamond', '💎', 19.99, 2000),
(5, 'Crown', '👑', 49.99, 5000),
(5, 'Star', '⭐', 14.99, 1500);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_google_id ON users(google_id);
CREATE INDEX idx_chat_rooms_users ON chat_rooms(user_id_1, user_id_2);
CREATE INDEX idx_messages_room ON messages(room_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_gift_transactions_users ON gift_transactions(sender_id, recipient_id); 