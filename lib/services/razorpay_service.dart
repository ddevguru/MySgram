import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class RazorpayService {
  static Razorpay? _razorpay;
  static bool _isInitialized = false;
  
  // Razorpay configuration - PRODUCTION KEYS
  static const String _keyId = 'rzp_live_Nb4qh9syPEKkss'; // Your production key
  static const String _keySecret = 'Ao03v6uv5H0DpcP9ZAMnmY5c'; // Your production secret
  
  // Initialize Razorpay
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      
      _isInitialized = true;
      print('✅ Razorpay initialized successfully');
    } catch (e) {
      print('❌ Error initializing Razorpay: $e');
      _isInitialized = false;
    }
  }
  
  // Handle payment success
  static void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('✅ Payment successful: ${response.paymentId}');
    
    // Verify payment with backend
    _verifyPayment(response.paymentId!, response.orderId!, response.signature!);
  }
  
  // Handle payment error
  static void _handlePaymentError(PaymentFailureResponse response) {
    print('❌ Payment failed: ${response.message}');
    Get.snackbar(
      'Payment Failed',
      'Payment was not completed. Please try again.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
  
  // Handle external wallet
  static void _handleExternalWallet(ExternalWalletResponse response) {
    print('💰 External wallet selected: ${response.walletName}');
  }
  
  // Verify payment with backend
  static Future<void> _verifyPayment(String paymentId, String orderId, String signature) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found');
        return;
      }
      
      final response = await http.post(
        Uri.parse('https://mysgram.com/payment/verify_payment.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'payment_id': paymentId,
          'order_id': orderId,
          'signature': signature,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
            'Payment Successful! 🎉',
            'Coins added to your wallet successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          
          // Refresh user coins
          // You can add a callback here to refresh the UI
        } else {
          Get.snackbar(
            'Payment Verification Failed',
            data['message'] ?? 'Could not verify payment',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } else {
        print('❌ Payment verification failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error verifying payment: $e');
    }
  }
  
  // Create order and initiate payment
  static Future<void> initiatePayment({
    required int coins,
    required int amount,
    required String currency,
    required String description,
  }) async {
    try {
      if (!_isInitialized || _razorpay == null) {
        await initialize();
      }
      
      // Create order on backend first
      final orderId = await _createOrder(amount, currency);
      if (orderId == null) {
        Get.snackbar('Error', 'Failed to create order');
        return;
      }
      
      // Prepare payment options
      final options = {
        'key': _keyId,
        'amount': (amount * 100).toString(), // Razorpay expects amount in paise
        'currency': currency,
        'name': 'MySgram',
        'description': description,
        'order_id': orderId,
        'prefill': {
          'contact': '', // You can prefill user's contact
          'email': '',   // You can prefill user's email
        },
        'theme': {
          'color': '#7D64FF', // Your app's primary color
        },
        'modal': {
          'confirm_close': true,
        },
      };
      
      // Open payment modal
      _razorpay!.open(options);
      
    } catch (e) {
      print('❌ Error initiating payment: $e');
      Get.snackbar('Error', 'Failed to initiate payment: $e');
    }
  }
  
  // Create order on backend
  static Future<String?> _createOrder(int amount, String currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found');
        return null;
      }
      
      final response = await http.post(
        Uri.parse('https://mysgram.com/payment/create_order.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'amount': amount,
          'currency': currency,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['order_id'];
        }
      }
      
      print('❌ Failed to create order: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Error creating order: $e');
      return null;
    }
  }
  
  // Dispose Razorpay
  static void dispose() {
    if (_razorpay != null) {
      _razorpay!.clear();
      _razorpay = null;
      _isInitialized = false;
    }
  }
  
  // Get available coin packages
  static List<CoinPackage> getCoinPackages() {
    return [
      CoinPackage(
        id: 'coins_100',
        coins: 100,
        price: 100,
        originalPrice: 120,
        discount: '17% OFF',
        popular: false,
      ),
      CoinPackage(
        id: 'coins_500',
        coins: 500,
        price: 450,
        originalPrice: 600,
        discount: '25% OFF',
        popular: true,
      ),
      CoinPackage(
        id: 'coins_1000',
        coins: 1000,
        price: 800,
        originalPrice: 1200,
        discount: '33% OFF',
        popular: false,
      ),
      CoinPackage(
        id: 'coins_2000',
        coins: 2000,
        price: 1500,
        originalPrice: 2400,
        discount: '38% OFF',
        popular: false,
      ),
      CoinPackage(
        id: 'coins_5000',
        coins: 5000,
        price: 3000,
        originalPrice: 6000,
        discount: '50% OFF',
        popular: false,
      ),
    ];
  }
}

// Coin package model
class CoinPackage {
  final String id;
  final int coins;
  final int price;
  final int originalPrice;
  final String discount;
  final bool popular;
  
  CoinPackage({
    required this.id,
    required this.coins,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.popular,
  });
} 