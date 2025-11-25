# Mysgram Backend API

This is the backend API for the Mysgram Flutter app, providing authentication and user management functionality using PHP and MySQL.

## Features

- **Email Authentication**: Register and login with email/password
- **Google OAuth**: Login with Google account
- **Facebook OAuth**: Login with Facebook account
- **JWT Token Authentication**: Secure token-based authentication
- **Password Reset**: Forgot password functionality
- **Profile Management**: Update user profiles
- **Account Linking**: Link multiple auth providers to one account

## Setup Instructions

### 1. Database Setup

1. Create a MySQL database named `mysgram_db`
2. Import the schema from `database/schema.sql`:
   ```sql
   mysql -u root -p mysgram_db < database/schema.sql
   ```

### 2. Configuration

1. Update `config/database.php` with your MySQL credentials:
   ```php
   private $host = "localhost";
   private $db_name = "mysgram_db";
   private $username = "your_username";
   private $password = "your_password";
   ```

2. Update `config/config.php` with your API keys:
   - **JWT_SECRET**: Generate a secure random string
   - **GOOGLE_CLIENT_ID**: Your Google OAuth client ID
   - **GOOGLE_CLIENT_SECRET**: Your Google OAuth client secret
   - **FACEBOOK_APP_ID**: Your Facebook app ID
   - **FACEBOOK_APP_SECRET**: Your Facebook app secret

### 3. OAuth Setup

#### Google OAuth
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add your redirect URI: `http://localhost/mysgram/backend/auth/google_callback.php`

#### Facebook OAuth
1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app
3. Add Facebook Login product
4. Configure OAuth redirect URIs
5. Get your App ID and App Secret

## API Endpoints

### Authentication Endpoints

#### 1. Register User
```
POST /auth/register.php
Content-Type: application/json

{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "password123",
    "full_name": "John Doe",
    "profile_picture": "https://example.com/avatar.jpg"
}
```

**Response:**
```json
{
    "message": "User registered successfully.",
    "token": "jwt_token_here",
    "user": {
        "id": 1,
        "username": "john_doe",
        "email": "john@example.com",
        "full_name": "John Doe",
        "profile_picture": "https://example.com/avatar.jpg",
        "auth_provider": "email",
        "is_verified": false,
        "created_at": "2024-01-01 12:00:00"
    }
}
```

#### 2. Login User
```
POST /auth/login.php
Content-Type: application/json

{
    "email": "john@example.com",
    "password": "password123"
}
```

#### 3. Google Login
```
POST /auth/google_login.php
Content-Type: application/json

{
    "google_token": "google_id_token_here"
}
```

#### 4. Facebook Login
```
POST /auth/facebook_login.php
Content-Type: application/json

{
    "facebook_token": "facebook_access_token_here"
}
```

### Protected Endpoints

#### 1. Verify Token
```
GET /auth/verify_token.php
Authorization: Bearer jwt_token_here
```

#### 2. Update Profile
```
PUT /auth/update_profile.php
Authorization: Bearer jwt_token_here
Content-Type: application/json

{
    "username": "new_username",
    "full_name": "New Full Name",
    "profile_picture": "https://example.com/new_avatar.jpg"
}
```

#### 3. Forgot Password
```
POST /auth/forgot_password.php
Content-Type: application/json

{
    "email": "john@example.com"
}
```

#### 4. Reset Password
```
POST /auth/reset_password.php
Content-Type: application/json

{
    "token": "reset_token_here",
    "new_password": "new_password123"
}
```

## Error Responses

All endpoints return appropriate HTTP status codes:

- **200**: Success
- **201**: Created
- **400**: Bad Request
- **401**: Unauthorized
- **404**: Not Found
- **503**: Service Unavailable

Error response format:
```json
{
    "message": "Error description"
}
```

## Security Features

1. **Password Hashing**: All passwords are hashed using PHP's `password_hash()`
2. **JWT Tokens**: Secure token-based authentication
3. **Input Validation**: All inputs are validated and sanitized
4. **CORS Headers**: Proper CORS configuration for cross-origin requests
5. **SQL Injection Protection**: Prepared statements for all database queries

## Flutter Integration

To integrate with your Flutter app, you'll need to:

1. Add HTTP package to your `pubspec.yaml`:
   ```yaml
   dependencies:
     http: ^1.1.0
   ```

2. Create API service class in your Flutter app
3. Handle authentication state management
4. Implement OAuth flows for Google and Facebook

## File Structure

```
backend/
├── config/
│   ├── database.php
│   └── config.php
├── models/
│   └── User.php
├── utils/
│   └── JWT.php
├── auth/
│   ├── register.php
│   ├── login.php
│   ├── google_login.php
│   ├── facebook_login.php
│   ├── verify_token.php
│   ├── update_profile.php
│   ├── forgot_password.php
│   └── reset_password.php
├── database/
│   └── schema.sql
└── README.md
```

## Notes

- This is a basic implementation. For production, consider adding:
  - Rate limiting
  - Email verification
  - Two-factor authentication
  - Logging and monitoring
  - HTTPS enforcement
  - Input sanitization improvements
  - API versioning

- The OAuth implementation assumes you're handling the OAuth flow in your Flutter app and sending the tokens to the backend for verification. 