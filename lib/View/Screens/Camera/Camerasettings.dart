// import 'package:flutter/material.dart';

// class Camerasettings extends StatelessWidget {
//   const Camerasettings({super.key});

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: Column(
//         children: [
//           // Top header with gradient
//           Container(
//             height: height * 0.15,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//                 colors: [
//                   Color(0xFF7D64FF), // Purple color from left
//                   Color(0xFFFFFFFF), // White color to right
//                 ],
//               ),
//             ),
//             child: SafeArea(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Cancel',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 17,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     Text(
//                       'Photo',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 17,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(width: 50), // Empty space for balance
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Main content area
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 children: [
//                   SizedBox(height: 40),

//                   // Circular image
//                   Container(
//                     width: 200,
//                     height: 200,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       image: DecorationImage(
//                         image: AssetImage('assets/Camerapageimage.png'),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),

//                   SizedBox(height: 60),

//                   // Settings options
//                   _buildSettingItem(Icons.brightness_6, 'Brightness'),
//                   SizedBox(height: 25),
//                   _buildSettingItem(Icons.contrast, 'Contrast'),
//                   SizedBox(height: 25),
//                   _buildSettingItem(Icons.flash_on, 'Flash'),
//                   SizedBox(height: 25),
//                   _buildSettingItem(Icons.crop, 'Crop'),

//                   Spacer(),

//                   // Bottom navigation
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Library',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                         Column(
//                           children: [
//                             Text(
//                               'Photo',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             SizedBox(height: 5),
//                             Container(
//                               width: 40,
//                               height: 2,
//                               color: Colors.black,
//                             ),
//                           ],
//                         ),
//                         Text(
//                           'Videos',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: 20),

//                   // Home indicator
//                   Container(
//                     width: 134,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(2.5),
//                     ),
//                   ),

//                   SizedBox(height: 15),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettingItem(IconData icon, String title) {
//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             icon,
//             color: Colors.white,
//             size: 20,
//           ),
//         ),
//         SizedBox(width: 15),
//         Text(
//           title,
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Spacer(),
//         Container(
//           width: 51,
//           height: 31,
//           decoration: BoxDecoration(
//             color: Color(0xFF007AFF), // iOS blue color
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                 right: 3,
//                 top: 3,
//                 child: Container(
//                   width: 25,
//                   height: 25,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class Camerasettings extends StatefulWidget {
  const Camerasettings({super.key});

  @override
  State<Camerasettings> createState() => _CamerasettingsState();
}

class _CamerasettingsState extends State<Camerasettings> {
  bool isBrightnessOn = true;
  bool isContrastOn = true;
  bool isFlashOn = true;
  bool isCropOn = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Top header with gradient
          Container(
            height: height * 0.15,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF7D64FF), // Purple color from left
                  Color(0xFFFFFFFF), // White color to right
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'Photo',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 50), // Empty space for balance
                  ],
                ),
              ),
            ),
          ),

          // Main content area
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: 40),

                  // Circular image with filters applied
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(_getColorMatrix()),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/Camerapageimage.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: isFlashOn
                              ? Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      center: Alignment.center,
                                      radius: 0.8,
                                      colors: [
                                        Colors.white.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 60),

                  // Settings options
                  _buildSettingItem(
                    Icons.brightness_6,
                    'Brightness',
                    isBrightnessOn,
                    (value) {
                      setState(() {
                        isBrightnessOn = value;
                      });
                    },
                  ),
                  SizedBox(height: 25),
                  _buildSettingItem(
                    Icons.contrast,
                    'Contrast',
                    isContrastOn,
                    (value) {
                      setState(() {
                        isContrastOn = value;
                      });
                    },
                  ),
                  SizedBox(height: 25),
                  _buildSettingItem(
                    Icons.flash_on,
                    'Flash',
                    isFlashOn,
                    (value) {
                      setState(() {
                        isFlashOn = value;
                      });
                    },
                  ),
                  SizedBox(height: 25),
                  _buildSettingItem(
                    Icons.crop,
                    'Crop',
                    isCropOn,
                    (value) {
                      setState(() {
                        isCropOn = value;
                      });
                    },
                  ),

                  Spacer(),

                  // Bottom navigation
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Library',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              'Photo',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: 40,
                              height: 2,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        Text(
                          'Videos',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Home indicator
                  Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),

                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      IconData icon, String title, bool isOn, Function(bool) onToggle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        SizedBox(width: 15),
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        Spacer(),
        GestureDetector(
          onTap: () => onToggle(!isOn),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 51,
            height: 31,
            decoration: BoxDecoration(
              color: isOn ? Color(0xFF007AFF) : Colors.grey[400],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: Duration(milliseconds: 200),
                  left: isOn ? 23 : 3,
                  top: 3,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Color matrix for brightness and contrast adjustments
  List<double> _getColorMatrix() {
    double brightness = isBrightnessOn ? 0.1 : -0.2; // Adjust brightness
    double contrast = isContrastOn ? 1.2 : 0.8; // Adjust contrast

    return [
      contrast,
      0,
      0,
      0,
      brightness * 255,
      0,
      contrast,
      0,
      0,
      brightness * 255,
      0,
      0,
      contrast,
      0,
      brightness * 255,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}
