import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/gift_service_simple.dart';
import '../../services/auth_service.dart';
import '../../services/razorpay_service.dart';
import 'BuyCoinsPage.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int currentCoins = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserCoins();
    
    // Register callback for coin updates
    RazorpayService.onCoinsUpdated = () {
      _loadUserCoins();
    };
  }
  
  @override
  void dispose() {
    // Unregister callback
    RazorpayService.onCoinsUpdated = null;
    super.dispose();
  }

  Future<void> _loadUserCoins() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final coins = await GiftService.getUserCoins();
      setState(() {
        currentCoins = coins;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading user coins: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Wallet'),
        backgroundColor: Color(0xFF7D64FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserCoins,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Balance Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7D64FF),
                        Color(0xFF9B6DFF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF7D64FF).withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Current Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (isLoading)
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      else
                        Text(
                          '$currentCoins',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(height: 8),
                      Text(
                        'Coins',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Quick Recharge Section
                Text(
                  'Quick Recharge',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                
                // Recharge Options
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildRechargeOption(1, 1, '1 Coins', '17% OFF'),
                    _buildRechargeOption(500, 450, '500 Coins', '25% OFF'),
                    _buildRechargeOption(1000, 800, '1000 Coins', '33% OFF'),
                    _buildRechargeOption(2000, 1500, '2000 Coins', '38% OFF'),
                  ],
                ),
                
                SizedBox(height: 32),
                
                // Buy More Coins Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToDepositPage(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7D64FF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Buy More Coins',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Transaction History
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                
                // Placeholder for transaction history
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your transaction history will appear here',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRechargeOption(int coins, int price, String title, String discount) {
    return GestureDetector(
      onTap: () => _showRechargeDialog(coins, price),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Discount badge
            if (discount.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  discount,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            if (discount.isNotEmpty) SizedBox(height: 4),
            Text(
              '$coins',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7D64FF),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Coins',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF7D64FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '₹$price',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7D64FF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRechargeDialog(int coins, int price) {
    Get.dialog(
      AlertDialog(
        title: Text('Buy Coins'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Do you want to buy $coins coins for ₹$price?'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.payment, color: Color(0xFF7D64FF)),
                SizedBox(width: 8),
                Text('Secure payment via Razorpay'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _initiatePayment(coins, price);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7D64FF),
              foregroundColor: Colors.white,
            ),
            child: Text('Pay Now'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _initiatePayment(int coins, int price) async {
    try {
      // Show loading
      Get.dialog(
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7D64FF)),
          ),
        ),
        barrierDismissible: false,
      );
      
      // Initialize Razorpay
      await RazorpayService.initialize();
      
      // Close loading
      Get.back();
      
      // Initiate payment
      await RazorpayService.initiatePayment(
        coins: coins,
        amount: price,
        currency: 'INR',
        description: 'Buy $coins coins for MySgram',
      );
      
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Failed to initiate payment: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _navigateToDepositPage() {
    Get.to(() => BuyCoinsPage());
  }
}

// Deposit Page
class DepositPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Deposit'),
        backgroundColor: Color(0xFF7D64FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Payment Method',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            
            // Payment Methods
            _buildPaymentMethod(
              'UPI',
              'Pay using UPI',
              Icons.account_balance,
              () => _showUPIDialog(),
            ),
            _buildPaymentMethod(
              'Credit/Debit Card',
              'Pay using card',
              Icons.credit_card,
              () => _showCardDialog(),
            ),
            _buildPaymentMethod(
              'Net Banking',
              'Pay using net banking',
              Icons.account_balance,
              () => _showNetBankingDialog(),
            ),
            _buildPaymentMethod(
              'Wallet',
              'Pay using digital wallet',
              Icons.account_balance_wallet,
              () => _showWalletDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF7D64FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Color(0xFF7D64FF),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showUPIDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('UPI Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('UPI ID: mysgram@paytm'),
            SizedBox(height: 16),
            Text('Scan QR code or use UPI ID to pay'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Payment initiated via UPI',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7D64FF),
              foregroundColor: Colors.white,
            ),
            child: Text('Pay'),
          ),
        ],
      ),
    );
  }

  void _showCardDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Card Payment'),
        content: Text('Card payment gateway will open'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Card payment gateway opened',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7D64FF),
              foregroundColor: Colors.white,
            ),
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showNetBankingDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Net Banking'),
        content: Text('Select your bank for payment'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Net banking options opened',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7D64FF),
              foregroundColor: Colors.white,
            ),
            child: Text('Select Bank'),
          ),
        ],
      ),
    );
  }

  void _showWalletDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Digital Wallet'),
        content: Text('Select your digital wallet'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Digital wallet options opened',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7D64FF),
              foregroundColor: Colors.white,
            ),
            child: Text('Select Wallet'),
          ),
        ],
      ),
    );
  }
} 