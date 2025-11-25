-- Chat and Gift System Database Schema

-- Chat Rooms Table
CREATE TABLE IF NOT EXISTS chat_rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id_1 INT NOT NULL,
    user_id_2 INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id_1) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id_2) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_room (user_id_1, user_id_2)
);

-- Chat Messages Table
CREATE TABLE IF NOT EXISTS chat_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    sender_id INT NOT NULL,
    message TEXT NOT NULL,
    message_type ENUM('text', 'image', 'video', 'audio', 'file', 'gift', 'location') DEFAULT 'text',
    reply_to INT NULL,
    metadata JSON NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reply_to) REFERENCES chat_messages(id) ON DELETE SET NULL,
    INDEX idx_room_id (room_id),
    INDEX idx_sender_id (sender_id),
    INDEX idx_created_at (created_at)
);

-- Gift Transactions Table
CREATE TABLE IF NOT EXISTS gift_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    recipient_id INT NOT NULL,
    gift_id VARCHAR(50) NOT NULL,
    gift_name VARCHAR(100) NOT NULL,
    gift_icon VARCHAR(10) NOT NULL,
    quantity INT DEFAULT 1,
    total_cost INT NOT NULL,
    message TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_sender_id (sender_id),
    INDEX idx_recipient_id (recipient_id),
    INDEX idx_created_at (created_at)
);

-- Add coins column to users table if it doesn't exist
-- Note: MySQL doesn't support IF NOT EXISTS for ADD COLUMN, so we'll handle this in PHP
-- ALTER TABLE users ADD COLUMN coins INT DEFAULT 0;

-- Create indexes for better performance
-- Note: MySQL doesn't support IF NOT EXISTS for CREATE INDEX, so we'll handle this in PHP
-- CREATE INDEX idx_chat_rooms_users ON chat_rooms(user_id_1, user_id_2);
-- CREATE INDEX idx_chat_messages_room_time ON chat_messages(room_id, created_at);
-- CREATE INDEX idx_gift_transactions_users ON gift_transactions(sender_id, recipient_id);

-- Insert sample gift data (optional)
INSERT IGNORE INTO gift_transactions (sender_id, recipient_id, gift_id, gift_name, gift_icon, quantity, total_cost, message) VALUES
(1, 2, '1', 'Rose', '🌹', 1, 100, 'Welcome to MySgram!'),
(2, 1, '2', 'Heart', '💖', 1, 200, 'Thanks for the follow!'),
(1, 3, '4', 'Cake', '🎂', 1, 500, 'Happy Birthday!');

-- Update sample users with some coins
UPDATE users SET coins = 1000 WHERE id IN (1, 2, 3); 