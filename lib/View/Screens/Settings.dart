// import 'package:flutter/material.dart';

// class Settings extends StatelessWidget {
//   const Settings({super.key});

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color(0xFF7D64FF), // Purple color from left
//                 Color(0xFFFFFFFF), // White color to right
//               ],
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//             ),
//           ),
//         ),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: Colors.black,
//             size: width * 0.06,
//           ),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'Settings',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: width * 0.055,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Search Bar
//             Container(
//               margin: EdgeInsets.all(width * 0.04),
//               padding: EdgeInsets.symmetric(
//                 horizontal: width * 0.04,
//                 vertical: height * 0.015,
//               ),
//               decoration: BoxDecoration(
//                 color: Color(0xFFE5E5E5),
//                 borderRadius: BorderRadius.circular(width * 0.06),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.search,
//                     color: Colors.grey[600],
//                     size: width * 0.06,
//                   ),
//                   SizedBox(width: width * 0.03),
//                   Text(
//                     'Search',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: width * 0.045,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Settings Menu Items
//             _buildMenuItem(
//               context,
//               icon: Icons.person_add_outlined,
//               title: 'Follow and Invite Friends',
//               width: width,
//             ),
//             _buildMenuItem(
//               context,
//               icon: Icons.history,
//               title: 'Your activity',
//               width: width,
//             ),
//             _buildMenuItem(
//               context,
//               icon: Icons.notifications_outlined,
//               title: 'Notifications',
//               width: width,
//             ),
//             _buildMenuItem(
//               context,
//               icon: Icons.lock_outline,
//               title: 'Privacy',
//               width: width,
//             ),
//             _buildMenuItem(
//               context,
//               icon: Icons.verified_user_outlined,
//               title: 'Security',
//               width: width,
//             ),
//             _buildMenuItem(
//               context,
//               icon: Icons.credit_card_outlined,
//               title: 'Payments',
//               width: width,
//             ),
//             _buildMenuItem(
//               context,
//               icon: Icons.movie_outlined,
//               title: 'Ads',
//               width: width,
//             ),
//             _buildMenuItem(
//               context,
//               icon: Icons.account_circle_outlined,
//               title: 'Account',
//               width: width,
//             ),
//             _buildMenuItem(
//               context,
//               icon: Icons.help_outline,
//               title: 'Help',
//               width: width,
//             ),
//             _buildMenuItem(
//               context,
//               icon: Icons.info_outline,
//               title: 'About',
//               width: width,
//             ),

//             // Logins Section
//             Container(
//               width: width,
//               padding: EdgeInsets.only(
//                 left: width * 0.04,
//                 top: height * 0.03,
//                 bottom: height * 0.01,
//               ),
//               child: Text(
//                 'Logins',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: width * 0.055,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),

//             _buildMenuItem(
//               context,
//               icon: Icons.login,
//               title: 'Login info',
//               width: width,
//             ),

//             // Log Out Button
//             Container(
//               width: width,
//               padding: EdgeInsets.symmetric(
//                 horizontal: width * 0.04,
//                 vertical: height * 0.015,
//               ),
//               margin: EdgeInsets.only(top: height * 0.02),
//               child: Row(
//                 children: [
//                   Text(
//                     'Log Out',
//                     style: TextStyle(
//                       color: Color(0xFF4285F4),
//                       fontSize: width * 0.045,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(width: width * 0.02),
//                   Icon(
//                     Icons.logout,
//                     color: Color(0xFF4285F4),
//                     size: width * 0.05,
//                   ),
//                 ],
//               ),
//             ),

//             SizedBox(height: height * 0.05),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required double width,
//   }) {
//     return Container(
//       width: width,
//       padding: EdgeInsets.symmetric(
//         horizontal: width * 0.04,
//         vertical: MediaQuery.of(context).size.height * 0.02,
//       ),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: Colors.black,
//             size: width * 0.06,
//           ),
//           SizedBox(width: width * 0.04),
//           Expanded(
//             child: Text(
//               title,
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: width * 0.045,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Icon(
//             Icons.arrow_forward_ios,
//             color: Colors.grey[600],
//             size: width * 0.04,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mysgram/View/Screens/Yourcativity.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF7D64FF), // Purple color from left
                Color(0xFFFFFFFF), // White color to right
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: width * 0.06,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.055,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: EdgeInsets.all(width * 0.04),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.015,
              ),
              decoration: BoxDecoration(
                color: Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(width * 0.06),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: width * 0.06,
                  ),
                  SizedBox(width: width * 0.03),
                  Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Settings Menu Items
            _buildMenuItem(
              context,
              icon: Icons.person_add_outlined,
              title: 'Follow and Invite Friends',
              width: width,
              // onTap: () => Get.to(const FollowInvitePage()),
            ),
            _buildMenuItem(
              context,
              icon: Icons.history,
              title: 'Your activity',
              width: width,
              onTap: () => Get.to(YourActivity()),
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              width: width,
              // onTap: () => Get.to(const NotificationsPage()),
            ),
            _buildMenuItem(
              context,
              icon: Icons.lock_outline,
              title: 'Privacy',
              width: width,
              // onTap: () => Get.to(const PrivacyPage()),
            ),
            _buildMenuItem(
              context,
              icon: Icons.verified_user_outlined,
              title: 'Security',
              width: width,
              // onTap: () => Get.to(const SecurityPage()),
            ),
            _buildMenuItem(
              context,
              icon: Icons.credit_card_outlined,
              title: 'Payments',
              width: width,
              // onTap: () => Get.to(const PaymentsPage()),
            ),
            _buildMenuItem(
              context,
              icon: Icons.movie_outlined,
              title: 'Ads',
              width: width,
              // onTap: () => Get.to(const AdsPage()),
            ),
            _buildMenuItem(
              context,
              icon: Icons.account_circle_outlined,
              title: 'Account',
              width: width,
              // onTap: () => Get.to(const AccountPage()),
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Help',
              width: width,
              // onTap: () => Get.to(const HelpPage()),
            ),
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              title: 'About',
              width: width,
              // onTap: () => Get.to(const AboutPage()),
            ),

            // Logins Section
            Container(
              width: width,
              padding: EdgeInsets.only(
                left: width * 0.04,
                top: height * 0.03,
                bottom: height * 0.01,
              ),
              child: Text(
                'Logins',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: width * 0.055,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            _buildMenuItem(
              context,
              icon: Icons.login,
              title: 'Login info',
              width: width,
              // onTap: () => Get.to(const LoginInfoPage()),
            ),

            // Log Out Button
            GestureDetector(
              onTap: () {
                // Handle logout and redirect to Signinpage
                // Get.offAll(const Signinpage());
              },
              child: Container(
                width: width,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.015,
                ),
                margin: EdgeInsets.only(top: height * 0.02),
                child: Row(
                  children: [
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    Icon(
                      Icons.logout,
                      color: Color(0xFF4285F4),
                      size: width * 0.05,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required double width,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: width * 0.06,
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: width * 0.04,
            ),
          ],
        ),
      ),
    );
  }
}
