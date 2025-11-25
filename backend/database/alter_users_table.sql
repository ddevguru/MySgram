-- ALTER queries to add streak functionality to existing users table
-- Run these queries on your existing database

-- Add streak_count column (default 0 for existing users)
ALTER TABLE users ADD COLUMN streak_count INT DEFAULT 0;

-- Add last_post_date column (NULL for existing users)
ALTER TABLE users ADD COLUMN last_post_date DATE;

-- Verify the changes
DESCRIBE users; 