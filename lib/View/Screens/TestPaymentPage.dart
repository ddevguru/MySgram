import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/razorpay_service.dart';

class TestPaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Payment'),
        backgroundColor: Color(0xFF7D64FF),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Test Razorpay Integration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Initialize Razorpay
                  await RazorpayService.initialize();
                  
                  // Test payment
                  await RazorpayService.initiatePayment(
                    coins: 100,
                    amount: 100,
                    currency: 'INR',
                    description: 'Test payment for 100 coins',
                  );
                } catch (e) {
                  Get.snackbar('Error', 'Payment failed: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7D64FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Test Payment'),
            ),
            SizedBox(height: 16),
            Text(
              'This will open Razorpay payment modal',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
} 