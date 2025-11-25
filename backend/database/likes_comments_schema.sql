-- Database schema for likes and comments functionality

-- Likes table
CREATE TABLE IF NOT EXISTS likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    UNIQUE KEY unique_like (user_id, post_id)
);

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

-- Sample data for testing
INSERT INTO likes (user_id, post_id) VALUES (1, 1) ON DUPLICATE KEY UPDATE created_at = CURRENT_TIMESTAMP;
INSERT INTO likes (user_id, post_id) VALUES (1, 2) ON DUPLICATE KEY UPDATE created_at = CURRENT_TIMESTAMP;

INSERT INTO comments (user_id, post_id, comment_text) VALUES 
(1, 1, 'Amazing post! 🔥'),
(1, 1, 'Love this! ❤️'),
(1, 2, 'Great content! 👍'); 