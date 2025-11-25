import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GiftService {
  // Temporarily using working backend - change back to https://mysgram.com when accessible
  static const String baseUrl = 'https://mysgram.com';
  
  // Gift categories and items
  static final List<GiftCategory> giftCategories = [
    GiftCategory(
      id: '1',
      name: 'Love & Hearts',
      icon: '❤️',
      gifts: [
        GiftItem(id: '1', name: 'Rose', icon: '🌹', price: 10, coins: 100),
        GiftItem(id: '2', name: 'Heart', icon: '💖', price: 20, coins: 200),
        GiftItem(id: '3', name: 'Kiss', icon: '💋', price: 30, coins: 300),
      ],
    ),
    GiftCategory(
      id: '2',
      name: 'Celebration',
      icon: '🎉',
      gifts: [
        GiftItem(id: '4', name: 'Cake', icon: '🎂', price: 50, coins: 500),
        GiftItem(id: '5', name: 'Balloon', icon: '🎈', price: 25, coins: 250),
        GiftItem(id: '6', name: 'Party', icon: '🎊', price: 100, coins: 1000),
      ],
    ),
    GiftCategory(
      id: '3',
      name: 'Nature',
      icon: '🌿',
      gifts: [
        GiftItem(id: '7', name: 'Flower', icon: '🌸', price: 15, coins: 150),
        GiftItem(id: '8', name: 'Tree', icon: '🌳', price: 40, coins: 400),
        GiftItem(id: '9', name: 'Sun', icon: '☀️', price: 35, coins: 350),
      ],
    ),
    GiftCategory(
      id: '4',
      name: 'Animals',
      icon: '🐾',
      gifts: [
        GiftItem(id: '10', name: 'Cat', icon: '🐱', price: 45, coins: 450),
        GiftItem(id: '11', name: 'Dog', icon: '🐕', price: 55, coins: 550),
        GiftItem(id: '12', name: 'Butterfly', icon: '🦋', price: 30, coins: 300),
      ],
    ),
    GiftCategory(
      id: '5',
      name: 'Premium',
      icon: '💎',
      gifts: [
        GiftItem(id: '13', name: 'Diamond', icon: '💎', price: 200, coins: 2000),
        GiftItem(id: '14', name: 'Crown', icon: '👑', price: 500, coins: 5000),
        GiftItem(id: '15', name: 'Star', icon: '⭐', price: 150, coins: 1500),
      ],
    ),
  ];
  
  // Initialize gift service
  static Future<void> initialize() async {
    try {
      print('✅ Gift service initialized (simplified version)');
    } catch (e) {
      print('❌ Error initializing gift service: $e');
    }
  }
  
  // Get user's coin balance
  static Future<int> getUserCoins() async {
    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 200));
      
      // For demo purposes, return a default amount
      return 1000;
    } catch (e) {
      print('❌ Error getting user coins: $e');
      return 0;
    }
  }
  
  // Purchase coins (simulated)
  static Future<bool> purchaseCoins(String productId) async {
    try {
      print('💰 Simulating coin purchase for: $productId');
      await Future.delayed(Duration(seconds: 2));
      print('✅ Coin purchase simulation completed');
      return true;
    } catch (e) {
      print('❌ Error purchasing coins: $e');
      return false;
    }
  }
  
  // Send gift to user
  static Future<bool> sendGift(String recipientId, String giftId, {int quantity = 1}) async {
    try {
      // Find gift details
      GiftItem? giftItem;
      for (var category in giftCategories) {
        giftItem = category.gifts.firstWhere((gift) => gift.id == giftId);
        if (giftItem != null) break;
      }
      
      if (giftItem == null) {
        print('❌ Gift not found: $giftId');
        return false;
      }
      
      final totalCost = giftItem.coins * quantity;
      
      // Check if user has enough coins
      final userCoins = await getUserCoins();
      if (userCoins < totalCost) {
        print('❌ Insufficient coins. Required: $totalCost, Available: $userCoins');
        return false;
      }
      
      // Simulate sending gift
      print('🎁 Simulating gift send: ${giftItem.name} to user $recipientId');
      await Future.delayed(Duration(seconds: 1));
      
      print('✅ Gift sent successfully');
      return true;
    } catch (e) {
      print('❌ Error sending gift: $e');
      return false;
    }
  }
  
  // Get gift history
  static Future<List<GiftTransaction>> getGiftHistory() async {
    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 200));
      
      // Return empty list for now
      return [];
    } catch (e) {
      print('❌ Error getting gift history: $e');
      return [];
    }
  }
  
  // Get received gifts
  static Future<List<GiftTransaction>> getReceivedGifts() async {
    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 200));
      
      // Return empty list for now
      return [];
    } catch (e) {
      print('❌ Error getting received gifts: $e');
      return [];
    }
  }
  
  // Get gift statistics
  static Future<GiftStats> getGiftStats() async {
    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 200));
      
      return GiftStats();
    } catch (e) {
      print('❌ Error getting gift stats: $e');
      return GiftStats();
    }
  }
  
  // Process in-app purchase (simulated)
  static Future<void> processPurchase(dynamic purchaseDetails) async {
    try {
      print('💰 Processing purchase simulation');
      await Future.delayed(Duration(seconds: 1));
      print('✅ Purchase processed successfully');
    } catch (e) {
      print('❌ Error processing purchase: $e');
    }
  }
  
  // Listen to purchase updates (simulated)
  static Stream<List<dynamic>> get purchaseUpdates {
    // Return an empty stream for now
    return Stream.empty();
  }
}

// Data models
class GiftCategory {
  final String id;
  final String name;
  final String icon;
  final List<GiftItem> gifts;
  
  GiftCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.gifts,
  });
}

class GiftItem {
  final String id;
  final String name;
  final String icon;
  final double price; // USD
  final int coins; // App currency
  
  GiftItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    required this.coins,
  });
}

class GiftTransaction {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderProfilePicture;
  final String recipientId;
  final String recipientName;
  final String? recipientProfilePicture;
  final String giftId;
  final String giftName;
  final String giftIcon;
  final int quantity;
  final int totalCost;
  final DateTime timestamp;
  final String message;
  
  GiftTransaction({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderProfilePicture,
    required this.recipientId,
    required this.recipientName,
    this.recipientProfilePicture,
    required this.giftId,
    required this.giftName,
    required this.giftIcon,
    required this.quantity,
    required this.totalCost,
    required this.timestamp,
    required this.message,
  });
  
  factory GiftTransaction.fromJson(Map<String, dynamic> json) {
    return GiftTransaction(
      id: json['id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderProfilePicture: json['sender_profile_picture'],
      recipientId: json['recipient_id'],
      recipientName: json['recipient_name'],
      recipientProfilePicture: json['recipient_profile_picture'],
      giftId: json['gift_id'],
      giftName: json['gift_name'],
      giftIcon: json['gift_icon'],
      quantity: json['quantity'],
      totalCost: json['total_cost'],
      timestamp: DateTime.parse(json['timestamp']),
      message: json['message'] ?? '',
    );
  }
}

class GiftStats {
  final int totalGiftsSent;
  final int totalGiftsReceived;
  final int totalCoinsSpent;
  final int totalCoinsEarned;
  final Map<String, int> topGiftsSent;
  final Map<String, int> topGiftsReceived;
  
  GiftStats({
    this.totalGiftsSent = 0,
    this.totalGiftsReceived = 0,
    this.totalCoinsSpent = 0,
    this.totalCoinsEarned = 0,
    this.topGiftsSent = const {},
    this.topGiftsReceived = const {},
  });
  
  factory GiftStats.fromJson(Map<String, dynamic> json) {
    return GiftStats(
      totalGiftsSent: json['total_gifts_sent'] ?? 0,
      totalGiftsReceived: json['total_gifts_received'] ?? 0,
      totalCoinsSpent: json['total_coins_spent'] ?? 0,
      totalCoinsEarned: json['total_coins_earned'] ?? 0,
      topGiftsSent: Map<String, int>.from(json['top_gifts_sent'] ?? {}),
      topGiftsReceived: Map<String, int>.from(json['top_gifts_received'] ?? {}),
    );
  }
} 