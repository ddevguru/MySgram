import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({Key? key}) : super(key: key);

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  String testResult = 'Click a test button to start testing';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification System Test'),
        backgroundColor: const Color(0xFF7D64FF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Results Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Results:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    testResult,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Test Buttons
            ElevatedButton(
              onPressed: isLoading ? null : _testGetNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D64FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Test Get Notifications'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: isLoading ? null : _testGetUnreadCount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Test Get Unread Count'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: isLoading ? null : _testCreateNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Test Create Notification'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: isLoading ? null : _testMarkAllRead,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Test Mark All as Read'),
            ),
            
            const SizedBox(height: 24),
            
            // Back to Notifications Button
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Back to Notifications'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testGetNotifications() async {
    setState(() {
      isLoading = true;
      testResult = 'Testing get notifications...';
    });

    try {
      final notifications = await NotificationService.getNotifications();
      setState(() {
        testResult = '✅ Get Notifications Test: SUCCESS\n'
            'Found ${notifications.length} notifications\n'
            'First notification: ${notifications.isNotEmpty ? notifications.first.title : "None"}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        testResult = '❌ Get Notifications Test: FAILED\n'
            'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _testGetUnreadCount() async {
    setState(() {
      isLoading = true;
      testResult = 'Testing get unread count...';
    });

    try {
      final count = await NotificationService.getUnreadCount();
      setState(() {
        testResult = '✅ Get Unread Count Test: SUCCESS\n'
            'Unread notifications: $count';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        testResult = '❌ Get Unread Count Test: FAILED\n'
            'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _testCreateNotification() async {
    setState(() {
      isLoading = true;
      testResult = 'Testing create notification...';
    });

    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        setState(() {
          testResult = '❌ Create Notification Test: FAILED\n'
              'No current user found';
          isLoading = false;
        });
        return;
      }

      final success = await NotificationService.createNotification(
        type: 'test',
        recipientId: currentUser['id'].toString(),
        senderId: currentUser['id'].toString(),
        message: 'This is a test notification created at ${DateTime.now()}',
      );

      setState(() {
        testResult = success 
            ? '✅ Create Notification Test: SUCCESS\n'
              'Test notification created successfully'
            : '❌ Create Notification Test: FAILED\n'
              'Failed to create test notification';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        testResult = '❌ Create Notification Test: FAILED\n'
            'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _testMarkAllRead() async {
    setState(() {
      isLoading = true;
      testResult = 'Testing mark all as read...';
    });

    try {
      final success = await NotificationService.markAllNotificationsRead();
      setState(() {
        testResult = success 
            ? '✅ Mark All as Read Test: SUCCESS\n'
              'All notifications marked as read'
            : '❌ Mark All as Read Test: FAILED\n'
              'Failed to mark notifications as read';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        testResult = '❌ Mark All as Read Test: FAILED\n'
            'Error: $e';
        isLoading = false;
      });
    }
  }
} 