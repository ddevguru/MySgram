-- Add Google login support to users table
-- Run this script to add necessary columns for Google authentication

-- Add google_id column if it doesn't exist
ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id VARCHAR(100) NULL;

-- Add auth_provider column if it doesn't exist  
ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_provider ENUM('email', 'google', 'facebook') DEFAULT 'email';

-- Add index for google_id for better performance
ALTER TABLE users ADD INDEX IF NOT EXISTS idx_google_id (google_id);

-- Add index for auth_provider for better performance
ALTER TABLE users ADD INDEX IF NOT EXISTS idx_auth_provider (auth_provider);

-- Update existing users to have 'email' as auth_provider
UPDATE users SET auth_provider = 'email' WHERE auth_provider IS NULL;

-- Verify the changes
DESCRIBE users;
