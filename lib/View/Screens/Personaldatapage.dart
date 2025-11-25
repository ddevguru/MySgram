// // import 'package:flutter/material.dart';

// // class Personaldatapage extends StatelessWidget {
// //   const Personaldatapage({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     double width = MediaQuery.of(context).size.width;
// //     double height = MediaQuery.of(context).size.height;

// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: SafeArea(
// //         child: Padding(
// //           padding: EdgeInsets.symmetric(horizontal: width * 0.08),
// //           child: Column(
// //             children: [
// //               // Top spacing
// //               SizedBox(height: height * 0.06),

// //               // Back button and title row
// //               Row(
// //                 children: [
// //                   GestureDetector(
// //                     onTap: () {
// //                       Navigator.pop(context);
// //                     },
// //                     child: Container(
// //                       padding: EdgeInsets.all(8),
// //                       child: Icon(
// //                         Icons.arrow_back,
// //                         color: Colors.black,
// //                         size: 24,
// //                       ),
// //                     ),
// //                   ),
// //                   Expanded(
// //                     child: Text(
// //                       'Personal Data',
// //                       style: TextStyle(
// //                         color: Colors.black,
// //                         fontSize: 20,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                       textAlign: TextAlign.center,
// //                     ),
// //                   ),
// //                   SizedBox(width: 40), // Balance the back button
// //                 ],
// //               ),

// //               SizedBox(height: height * 0.08),

// //               // Profile Image Section
// //               Stack(
// //                 alignment: Alignment.center,
// //                 children: [
// //                   // Pink rectangle background
// //                   Image.asset(
// //                     'assets/pinkback.png',
// //                     width: 104,
// //                     height: 104,
// //                     fit: BoxFit.cover,
// //                   ),

// //                   // White rectangle overlay
// //                   Image.asset(
// //                     'assets/whiteback.png',
// //                     width: 90,
// //                     height: 90,
// //                     fit: BoxFit.cover,
// //                   ),

// //                   // Camera icon on top
// //                   GestureDetector(
// //                     onTap: () {
// //                       // Handle camera tap
// //                       print('Camera tapped');
// //                     },
// //                     child: Image.asset(
// //                       'assets/Camera.png',
// //                       width: 30,
// //                       height: 20,
// //                       fit: BoxFit.contain,
// //                     ),
// //                   ),
// //                 ],
// //               ),

// //               SizedBox(height: height * 0.04),

// //               // Add Photo Text
// //               Text(
// //                 'Add your photo',
// //                 style: TextStyle(
// //                   color: Colors.black,
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),

// //               SizedBox(height: height * 0.02),

// //               // Subtitle text
// //               Text(
// //                 'Upload a photo to help others recognize you',
// //                 style: TextStyle(
// //                   color: Colors.grey[600],
// //                   fontSize: 14,
// //                   fontWeight: FontWeight.w400,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),

// //               SizedBox(height: height * 0.08),

// //               // Name Input Field
// //               TextField(
// //                 decoration: InputDecoration(
// //                   labelText: 'Full Name',
// //                   labelStyle: TextStyle(
// //                     color: Colors.grey[600],
// //                     fontSize: 16,
// //                   ),
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(8),
// //                     borderSide: BorderSide(color: Colors.grey[300]!),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(8),
// //                     borderSide: BorderSide(color: Colors.blue),
// //                   ),
// //                   contentPadding:
// //                       EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //                 ),
// //                 style: TextStyle(
// //                   color: Colors.black,
// //                   fontSize: 16,
// //                 ),
// //               ),

// //               SizedBox(height: height * 0.03),

// //               // Username Input Field
// //               TextField(
// //                 decoration: InputDecoration(
// //                   labelText: 'Username',
// //                   labelStyle: TextStyle(
// //                     color: Colors.grey[600],
// //                     fontSize: 16,
// //                   ),
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(8),
// //                     borderSide: BorderSide(color: Colors.grey[300]!),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(8),
// //                     borderSide: BorderSide(color: Colors.blue),
// //                   ),
// //                   contentPadding:
// //                       EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //                 ),
// //                 style: TextStyle(
// //                   color: Colors.black,
// //                   fontSize: 16,
// //                 ),
// //               ),

// //               Spacer(),

// //               // Continue Button
// //               Container(
// //                 width: width * 0.84,
// //                 height: 55,
// //                 margin: EdgeInsets.only(bottom: height * 0.04),
// //                 decoration: BoxDecoration(
// //                   color: Colors.blue,
// //                   borderRadius: BorderRadius.circular(28),
// //                 ),
// //                 child: Material(
// //                   color: Colors.transparent,
// //                   child: InkWell(
// //                     borderRadius: BorderRadius.circular(28),
// //                     onTap: () {
// //                       // Continue action
// //                     },
// //                     child: Center(
// //                       child: Text(
// //                         'Continue',
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';

// class Personaldatapage extends StatelessWidget {
//   const Personaldatapage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: width * 0.08),
//           child: Column(
//             children: [
//               // Top spacing
//               SizedBox(height: height * 0.02),

//               // Header with Cancel, Title, and Done
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Text(
//                       'Cancel',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     'Edit Profile',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       // Handle done action
//                     },
//                     child: Text(
//                       'Done',
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: height * 0.05),

//               // Profile Image Section (keeping your existing stack structure)
//               Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // Pink rectangle background
//                   Image.asset(
//                     'assets/pinkback.png',
//                     width: 104,
//                     height: 104,
//                     fit: BoxFit.cover,
//                   ),

//                   // White rectangle overlay
//                   Image.asset(
//                     'assets/whiteback.png',
//                     width: 90,
//                     height: 90,
//                     fit: BoxFit.cover,
//                   ),

//                   // Camera icon on top
//                   GestureDetector(
//                     onTap: () {
//                       // Handle camera tap
//                       print('Camera tapped');
//                     },
//                     child: Image.asset(
//                       'assets/Camera.png',
//                       width: 30,
//                       height: 20,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: height * 0.04),

//               // Form Fields
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Username Field
//                       Text(
//                         'Username',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       TextField(
//                         decoration: InputDecoration(
//                           hintText: 'Your Username',
//                           hintStyle: TextStyle(
//                             color: Colors.grey[500],
//                             fontSize: 16,
//                           ),
//                           border: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           focusedBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.blue),
//                           ),
//                           enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                       ),

//                       SizedBox(height: height * 0.03),

//                       // First Name Field
//                       Text(
//                         'First Name',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       TextField(
//                         decoration: InputDecoration(
//                           hintText: 'Your name',
//                           hintStyle: TextStyle(
//                             color: Colors.grey[500],
//                             fontSize: 16,
//                           ),
//                           border: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           focusedBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.blue),
//                           ),
//                           enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                       ),

//                       SizedBox(height: height * 0.03),

//                       // Last Name Field
//                       Text(
//                         'Last Name',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       TextField(
//                         decoration: InputDecoration(
//                           hintText: 'Your last name',
//                           hintStyle: TextStyle(
//                             color: Colors.grey[500],
//                             fontSize: 16,
//                           ),
//                           border: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           focusedBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.blue),
//                           ),
//                           enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                       ),

//                       SizedBox(height: height * 0.03),

//                       // Date of Birth Field
//                       Text(
//                         'Date Of Birth',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       TextField(
//                         decoration: InputDecoration(
//                           hintText: 'Your Birthday (DD-MM-YYYY)',
//                           hintStyle: TextStyle(
//                             color: Colors.grey[500],
//                             fontSize: 16,
//                           ),
//                           border: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           focusedBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.blue),
//                           ),
//                           enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                       ),

//                       SizedBox(height: height * 0.05),
//                     ],
//                   ),
//                 ),
//               ),

//               // Complete Button
//               Container(
//                 width: width * 0.84,
//                 height: 55,
//                 margin: EdgeInsets.only(bottom: height * 0.04),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(28),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(28),
//                     onTap: () {
//                       // Complete action
//                     },
//                     child: Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Complete',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Icon(
//                             Icons.check,
//                             color: Colors.black,
//                             size: 20,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mysgram/View/Screens/Signinpage.dart';
import 'package:mysgram/View/Screens/Signuppage.dart';

class Personaldatapage extends StatelessWidget {
  const Personaldatapage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: Column(
            children: [
              // Top spacing
              SizedBox(height: height * 0.02),

              // Header with Cancel, Title, and Done in rounded container
              Container(
                width: width * 0.9,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 3,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle done action
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.05),

              // Profile Image Section (keeping your existing stack structure)
              Stack(
                alignment: Alignment.center,
                children: [
                  // Pink rectangle background
                  Image.asset(
                    'assets/pinkback.png',
                    width: 104,
                    height: 104,
                    fit: BoxFit.cover,
                  ),

                  // White rectangle overlay
                  Image.asset(
                    'assets/whiteback.png',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),

                  // Camera icon on top
                  GestureDetector(
                    onTap: () {
                      // Handle camera tap
                      print('Camera tapped');
                    },
                    child: Image.asset(
                      'assets/Camera.png',
                      width: 30,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.04),

              // Form Fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username Field
                      Text(
                        'Username',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Your Username',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(height: height * 0.03),

                      // First Name Field
                      Text(
                        'First Name',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Your name',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(height: height * 0.03),

                      // Last Name Field
                      Text(
                        'Last Name',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Your last name',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(height: height * 0.03),

                      // Date of Birth Field
                      Text(
                        'Date Of Birth',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Your Birthday (DD-MM-YYYY)',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(height: height * 0.05),
                    ],
                  ),
                ),
              ),

              // Complete Button
              Container(
                width: width * 0.84,
                height: 55,
                margin: EdgeInsets.only(bottom: height * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () {
                      Get.to(Signinpage());
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Complete',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
