import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/razorpay_service.dart';

class BuyCoinsPage extends StatefulWidget {
  const BuyCoinsPage({super.key});

  @override
  State<BuyCoinsPage> createState() => _BuyCoinsPageState();
}

class _BuyCoinsPageState extends State<BuyCoinsPage> {
  bool isLoading = false;
  List<CoinPackage> coinPackages = [];

  @override
  void initState() {
    super.initState();
    _loadCoinPackages();
  }

  void _loadCoinPackages() {
    setState(() {
      coinPackages = RazorpayService.getCoinPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Buy Coins'),
        backgroundColor: Color(0xFF7D64FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7D64FF),
                  Color(0xFF9B6DFF),
                ],
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Get More Coins',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Unlock premium features and send amazing gifts',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Coin packages
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: coinPackages.length,
              itemBuilder: (context, index) {
                final package = coinPackages[index];
                return _buildCoinPackage(package);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinPackage(CoinPackage package) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: package.popular 
          ? Border.all(color: Color(0xFF7D64FF), width: 2)
          : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Popular badge
          if (package.popular)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF7D64FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                // Coin icon and amount
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFF7D64FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${package.coins}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7D64FF),
                          ),
                        ),
                        Text(
                          'Coins',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF7D64FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(width: 20),
                
                // Package details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                              Text(
                          '${package.coins} Coins',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      SizedBox(height: 8),
                      
                      // Price comparison
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${package.price}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7D64FF),
                            ),
                          ),
                          Text(
                            '₹${package.originalPrice}',
                            style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Discount
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          package.discount,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: 16),
                
                // Buy button
                ElevatedButton(
                  onPressed: isLoading ? null : () => _buyCoins(package),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7D64FF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _buyCoins(CoinPackage package) async {
    try {
      setState(() {
        isLoading = true;
      });

      // Initialize Razorpay
      await RazorpayService.initialize();

      // Initiate payment
      await RazorpayService.initiatePayment(
        coins: package.coins,
        amount: package.price,
        currency: 'INR',
        description: 'Buy ${package.coins} coins',
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initiate payment: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
} 