# MySgram Chat & Gift System API Documentation

## Overview
This document describes the backend API endpoints for the MySgram chat and gift system.

## Base URL
```
http://your-backend-url.com/backend
```

## Authentication
All API endpoints require JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer YOUR_JWT_TOKEN
```

## Chat Endpoints

### 1. Create Chat Room
**POST** `/chat/create_room`

Creates a new chat room between two users.

**Request Body:**
```json
{
  "user_id_1": 1,
  "user_id_2": 2
}
```

**Response:**
```json
{
  "success": true,
  "room": {
    "id": "123",
    "participants": [1, 2],
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### 2. Get Chat Rooms
**GET** `/chat/rooms`

Retrieves all chat rooms for the authenticated user.

**Response:**
```json
{
  "success": true,
  "rooms": [
    {
      "id": "123",
      "participants": [1, 2],
      "last_message": {
        "id": "456",
        "room_id": "123",
        "sender_id": 1,
        "message": "Hello!",
        "timestamp": "2024-01-01T00:00:00Z",
        "metadata": {}
      },
      "unread_count": 2,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### 3. Get Chat Messages
**GET** `/chat/messages/{room_id}?limit=50&offset=0`

Retrieves messages for a specific chat room.

**Query Parameters:**
- `limit`: Number of messages to retrieve (max 100, default 50)
- `offset`: Number of messages to skip (default 0)

**Response:**
```json
{
  "success": true,
  "messages": [
    {
      "id": "456",
      "room_id": "123",
      "sender_id": 1,
      "message": "Hello!",
      "type": "text",
      "reply_to": null,
      "metadata": {},
      "timestamp": "2024-01-01T00:00:00Z",
      "username": "john_doe",
      "profile_picture": "https://example.com/avatar.jpg"
    }
  ],
  "room_id": "123",
  "limit": 50,
  "offset": 0
}
```

## Gift Endpoints

### 1. Send Gift
**POST** `/gift/send`

Sends a gift from one user to another.

**Request Body:**
```json
{
  "recipient_id": 2,
  "gift_id": "1",
  "quantity": 1,
  "total_cost": 100,
  "message": "Happy Birthday!"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Gift sent successfully",
  "transaction_id": "789",
  "gift_name": "Rose",
  "gift_icon": "🌹",
  "quantity": 1,
  "total_cost": 100
}
```

### 2. Get Gift History
**GET** `/gift/history`

Retrieves the gift sending history for the authenticated user.

**Response:**
```json
{
  "success": true,
  "transactions": [
    {
      "id": "789",
      "sender_id": 1,
      "sender_name": "john_doe",
      "recipient_id": 2,
      "recipient_name": "jane_doe",
      "gift_id": "1",
      "gift_name": "Rose",
      "gift_icon": "🌹",
      "quantity": 1,
      "total_cost": 100,
      "timestamp": "2024-01-01T00:00:00Z",
      "message": "Happy Birthday!"
    }
  ]
}
```

### 3. Get Received Gifts
**GET** `/gift/received`

Retrieves gifts received by the authenticated user.

**Response:**
```json
{
  "success": true,
  "gifts": [
    {
      "id": "789",
      "sender_id": 1,
      "sender_name": "john_doe",
      "recipient_id": 2,
      "recipient_name": "jane_doe",
      "gift_id": "1",
      "gift_name": "Rose",
      "gift_icon": "🌹",
      "quantity": 1,
      "total_cost": 100,
      "timestamp": "2024-01-01T00:00:00Z",
      "message": "Happy Birthday!"
    }
  ]
}
```

### 4. Get Gift Statistics
**GET** `/gift/stats`

Retrieves gift statistics for the authenticated user.

**Response:**
```json
{
  "success": true,
  "total_gifts_sent": 10,
  "total_gifts_received": 5,
  "total_coins_spent": 1000,
  "total_coins_earned": 500,
  "top_gifts_sent": {
    "1": 3,
    "2": 2
  },
  "top_gifts_received": {
    "1": 2,
    "3": 1
  }
}
```

## User Endpoints

### 1. Get User Coins
**GET** `/user/coins`

Retrieves the coin balance for the authenticated user.

**Response:**
```json
{
  "success": true,
  "coins": 1000,
  "user_id": 1
}
```

## Purchase Endpoints

### 1. Verify Purchase
**POST** `/purchase/verify`

Verifies an in-app purchase and adds coins to the user's account.

**Request Body:**
```json
{
  "product_id": "coins_100",
  "purchase_token": "purchase_token_123",
  "transaction_date": "2024-01-01T00:00:00Z"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Purchase verified and coins added",
  "coins_added": 100
}
```

## Error Responses

All endpoints return error responses in the following format:

```json
{
  "error": "Error message description"
}
```

**HTTP Status Codes:**
- `200` - Success
- `400` - Bad Request (missing or invalid parameters)
- `401` - Unauthorized (invalid or missing token)
- `403` - Forbidden (access denied)
- `404` - Not Found
- `405` - Method Not Allowed
- `500` - Internal Server Error

## Rate Limiting

To prevent abuse, consider implementing rate limiting:
- Chat messages: 10 per minute per user
- Gift sending: 5 per minute per user
- API calls: 100 per hour per user

## Security Considerations

1. **JWT Validation**: Always validate JWT tokens on every request
2. **Input Validation**: Sanitize and validate all input data
3. **SQL Injection**: Use prepared statements for all database queries
4. **CORS**: Configure CORS properly for your frontend domain
5. **HTTPS**: Use HTTPS in production for all API calls

## Testing

Use the provided test scripts to verify your setup:

```bash
# Test database setup
php setup_chat_gift.php

# Test system functionality
php test_chat_gift.php
```

## Support

For issues or questions:
1. Check the error logs
2. Verify database connectivity
3. Ensure all required tables exist
4. Check JWT token validity 