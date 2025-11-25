# MySgram - Social Media App

<div align="center">

![MySgram](https://img.shields.io/badge/MySgram-Social%20Media-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![PHP](https://img.shields.io/badge/PHP-8.0+-777BB4?logo=php)
![License](https://img.shields.io/badge/License-MIT-green)

A modern social media application built with Flutter and PHP, inspired by Instagram. Share photos, videos, stories, chat with friends, and connect with people around the world.

[Features](#-features) • [Installation](#-installation) • [Configuration](#-configuration) • [API Documentation](#-api-documentation) • [Contributing](#-contributing)

</div>

---

## 📱 About

MySgram is a full-featured social media platform that allows users to:
- Share photos and videos
- Create and view stories
- Chat with other users
- Send virtual gifts
- Follow/unfollow users
- Like and comment on posts
- Search for users and content
- Manage profile and settings
- Purchase coins for in-app features

## ✨ Features

### Core Features
- 🔐 **Authentication**
  - Email/Password registration and login
  - Google OAuth integration
  - Facebook OAuth integration
  - JWT token-based authentication
  - Password reset functionality

- 📸 **Content Sharing**
  - Photo and video posts
  - Stories (24-hour expiring content)
  - Multiple image posts
  - Camera integration
  - Image picker and gallery access

- 💬 **Messaging**
  - Real-time chat
  - One-on-one conversations
  - Message replies
  - Gift sending in chat
  - Online/offline status

- 🎁 **Gifts & Coins**
  - Virtual gift system
  - In-app coin purchases
  - Payment integration (Razorpay, Stripe)
  - Gift history and statistics
  - Wallet management

- 👥 **Social Features**
  - Follow/Unfollow users
  - Like and comment on posts
  - User search and discovery
  - Profile viewing
  - Followers/Following lists
  - Activity feed

- 🔔 **Notifications**
  - Push notifications (Firebase Cloud Messaging)
  - Local notifications
  - Follow notifications
  - Like and comment notifications
  - Gift received notifications

- ⚙️ **User Management**
  - Profile customization
  - Profile picture upload
  - Personal data management
  - Account settings
  - Account deletion

## 🛠️ Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.0+
- **State Management**: GetX
- **HTTP Client**: Dio, http
- **Image Handling**: cached_network_image, image_picker
- **Video**: video_player
- **Authentication**: firebase_auth, google_sign_in
- **Notifications**: firebase_messaging, flutter_local_notifications
- **Payments**: razorpay_flutter, flutter_stripe
- **Storage**: shared_preferences, sqflite
- **Other**: url_launcher, webview_flutter, share_plus, permission_handler

### Backend (PHP)
- **Language**: PHP 8.0+
- **Database**: MySQL
- **Authentication**: JWT (JSON Web Tokens)
- **OAuth**: Google OAuth 2.0, Facebook OAuth
- **API**: RESTful API
- **Dependencies**: Google API Client (via Composer)

### Infrastructure
- **Cloud Messaging**: Firebase Cloud Messaging
- **File Storage**: Local/Server storage
- **Payment Gateways**: Razorpay, Stripe

## 📁 Project Structure

```
mysgram/
├── android/                 # Android platform-specific files
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── google-services.json
│   └── settings.gradle.kts
├── ios/                      # iOS platform-specific files
├── lib/                      # Flutter application code
│   ├── Controller/          # GetX controllers
│   ├── Model/               # Data models
│   ├── View/                # UI screens and widgets
│   │   └── Screens/
│   │       ├── Signinpage.dart
│   │       ├── Signuppage.dart
│   │       ├── Bottombar.dart
│   │       ├── Profilepage.dart
│   │       ├── ChatPage.dart
│   │       ├── Storiespostpage.dart
│   │       ├── NotificationPage.dart
│   │       ├── BuyCoinsPage.dart
│   │       └── ...
│   ├── services/            # API services
│   │   ├── auth_service.dart
│   │   ├── php_chat_service.dart
│   │   ├── notification_service.dart
│   │   ├── razorpay_service.dart
│   │   └── gift_service_simple.dart
│   ├── Routes/              # Navigation routes
│   ├── Utils/               # Utility functions
│   └── main.dart            # App entry point
├── backend/                  # PHP backend API
│   ├── auth/                # Authentication endpoints
│   │   ├── register.php
│   │   ├── login.php
│   │   ├── google_login.php
│   │   ├── facebook_login.php
│   │   └── ...
│   ├── chat/                # Chat endpoints
│   ├── gift/                # Gift endpoints
│   ├── payment/             # Payment endpoints
│   ├── config/              # Configuration files
│   │   ├── config.php
│   │   └── database.php
│   ├── models/              # PHP models
│   ├── utils/               # Utility classes
│   ├── database/            # Database schemas
│   └── uploads/             # Uploaded files
├── assets/                   # Images and assets
├── web/                      # Web platform files
├── pubspec.yaml             # Flutter dependencies
└── README.md                # This file
```

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0 or higher)
  ```bash
  flutter --version
  ```
- **Dart SDK** (comes with Flutter)
- **PHP** (8.0 or higher)
  ```bash
  php --version
  ```
- **MySQL** (5.7 or higher)
- **Composer** (PHP dependency manager)
  ```bash
  composer --version
  ```
- **Android Studio** / **Xcode** (for mobile development)
- **Git**

### Additional Requirements
- **Firebase Account** (for push notifications and authentication)
- **Google Cloud Console** account (for Google OAuth)
- **Facebook Developer** account (for Facebook OAuth)
- **Razorpay/Stripe** account (for payment integration)

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/mysgram.git
cd mysgram
```

### 2. Backend Setup

#### Install PHP Dependencies

```bash
cd backend
composer install
```

#### Database Setup

1. Create a MySQL database:
   ```sql
   CREATE DATABASE mysgram_db;
   ```

2. Import the database schema:
   ```bash
   mysql -u root -p mysgram_db < database/schema.sql
   ```
   Or use phpMyAdmin to import the SQL files from `backend/database/`

#### Configure Backend

1. Update `backend/config/database.php` with your MySQL credentials:
   ```php
   private $host = "localhost";
   private $db_name = "mysgram_db";
   private $username = "your_username";
   private $password = "your_password";
   ```

2. Update `backend/config/config.php`:
   ```php
   // Generate a secure JWT secret
   define('JWT_SECRET', 'your_secure_jwt_secret_key_here');
   
   // Google OAuth
   define('GOOGLE_CLIENT_ID', 'your_google_client_id');
   define('GOOGLE_CLIENT_SECRET', 'your_google_client_secret');
   
   // Facebook OAuth
   define('FACEBOOK_APP_ID', 'your_facebook_app_id');
   define('FACEBOOK_APP_SECRET', 'your_facebook_app_secret');
   
   // SMTP (for password reset emails)
   define('SMTP_HOST', 'smtp.gmail.com');
   define('SMTP_PORT', 587);
   define('SMTP_USERNAME', 'your_email@gmail.com');
   define('SMTP_PASSWORD', 'your_app_password');
   ```

3. Set up OAuth:
   - **Google OAuth**: Follow instructions in `backend/README.md`
   - **Facebook OAuth**: Follow instructions in `backend/README.md`

4. Configure your web server (Apache/Nginx) to point to the `backend` directory

### 3. Flutter App Setup

#### Install Flutter Dependencies

```bash
cd ..  # Return to project root
flutter pub get
```

#### Configure Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android app:
   - Download `google-services.json`
   - Place it in `android/app/google-services.json`
3. Add iOS app (if developing for iOS):
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/GoogleService-Info.plist`

#### Update API Endpoints

Update the base URLs in the service files:

- `lib/services/auth_service.dart`: Update `baseUrl`
- `lib/services/php_chat_service.dart`: Update `baseUrl`
- `lib/services/notification_service.dart`: Update `baseUrl`
- `lib/services/gift_service_simple.dart`: Update `baseUrl`

Replace `https://mysgram.com` with your actual backend URL.

#### Configure Payment Gateways

1. **Razorpay**:
   - Update keys in `lib/services/razorpay_service.dart`
   - Configure in Razorpay dashboard

2. **Stripe**:
   - Update publishable key in relevant files
   - Configure in Stripe dashboard

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the backend directory (if using environment variables):

```env
DB_HOST=localhost
DB_NAME=mysgram_db
DB_USER=your_username
DB_PASS=your_password
JWT_SECRET=your_jwt_secret
GOOGLE_CLIENT_ID=your_google_client_id
FACEBOOK_APP_ID=your_facebook_app_id
```

### Android Configuration

- Update `android/app/build.gradle.kts` with your signing config
- Update `applicationId` if needed
- Ensure `minSdk` and `targetSdk` are appropriate

### iOS Configuration

- Update bundle identifier in `ios/Runner.xcodeproj`
- Configure signing certificates
- Update Info.plist with required permissions

## 🏃 Running the App

### Backend

Start your PHP server:

```bash
# Using PHP built-in server (development)
cd backend
php -S localhost:8000

# Or use your web server (Apache/Nginx)
# Point document root to backend directory
```

### Flutter App

1. **Check connected devices:**
   ```bash
   flutter devices
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Build for release:**
   ```bash
   # Android
   flutter build apk --release
   flutter build appbundle --release
   
   # iOS
   flutter build ios --release
   ```

## 📚 API Documentation

### Authentication API

See `backend/README.md` for detailed authentication endpoints.

### Chat & Gift API

See `backend/API_README.md` for detailed chat and gift system endpoints.

### Base URL

All API endpoints use the base URL configured in your service files (default: `https://mysgram.com`).

### Authentication

Most endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer YOUR_JWT_TOKEN
```

## 🧪 Testing

### Backend Testing

Run the test scripts in the `backend` directory:

```bash
cd backend
php test_connection.php
php test_database_tables.php
php test_follow_backend.php
php test_chat_gift.php
```

### Flutter Testing

```bash
flutter test
```

## 📱 Screenshots

_Add screenshots of your app here_

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow Flutter/Dart style guidelines
- Follow PSR-12 for PHP code
- Write meaningful commit messages
- Add comments for complex logic

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All open-source contributors
- Firebase for backend services
- Payment gateway providers

## 📞 Support

For support, email your-email@example.com or create an issue in the repository.

## 🔮 Roadmap

- [ ] Video calling feature
- [ ] Live streaming
- [ ] Stories highlights
- [ ] Advanced search filters
- [ ] Dark mode
- [ ] Multi-language support
- [ ] Enhanced analytics
- [ ] Admin dashboard

---

<div align="center">

Made with ❤️ using Flutter and PHP

⭐ Star this repo if you find it helpful!

</div>
