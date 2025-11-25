// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';

// // // Model class for daily activity data
// // class DailyActivity {
// //   final String day;
// //   final String shortDay;
// //   final int minutes;
// //   final bool isToday;

// //   DailyActivity({
// //     required this.day,
// //     required this.shortDay,
// //     required this.minutes,
// //     this.isToday = false,
// //   });
// // }

// // // GetX Controller
// // class YourActivityController extends GetxController {
// //   // Observable variables
// //   var totalTimeToday = 1.obs; // in minutes
// //   var dailyActivities = <DailyActivity>[].obs;
// //   var isDailyReminderEnabled = true.obs;
// //   var isNotificationsEnabled = true.obs;

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     loadActivityData();
// //   }

// //   void loadActivityData() {
// //     // Sample data for the week
// //     dailyActivities.value = [
// //       DailyActivity(day: 'Monday', shortDay: 'MON', minutes: 45),
// //       DailyActivity(day: 'Tuesday', shortDay: 'TUE', minutes: 5),
// //       DailyActivity(day: 'Wednesday', shortDay: 'WED', minutes: 38),
// //       DailyActivity(day: 'Thursday', shortDay: 'THU', minutes: 42),
// //       DailyActivity(day: 'Friday', shortDay: 'FRI', minutes: 15),
// //       DailyActivity(day: 'Saturday', shortDay: 'SAT', minutes: 25),
// //       DailyActivity(
// //           day: 'Today', shortDay: 'Today', minutes: 65, isToday: true),
// //     ];
// //   }

// //   void toggleDailyReminder() {
// //     isDailyReminderEnabled.value = !isDailyReminderEnabled.value;
// //   }

// //   void toggleNotifications() {
// //     isNotificationsEnabled.value = !isNotificationsEnabled.value;
// //   }

// //   // Get max minutes for chart scaling
// //   int get maxMinutes {
// //     if (dailyActivities.isEmpty) return 100;
// //     return dailyActivities
// //         .map((e) => e.minutes)
// //         .reduce((a, b) => a > b ? a : b);
// //   }
// // }

// // class YourActivity extends StatelessWidget {
// //   const YourActivity({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     double width = MediaQuery.of(context).size.width;
// //     double height = MediaQuery.of(context).size.height;

// //     // Initialize controller
// //     final controller = Get.put(YourActivityController());

// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             // Header Section
// //             Container(
// //               height: height * 0.08,
// //               decoration: BoxDecoration(
// //                 color: Color(0xFFE6D7FF),
// //                 borderRadius: BorderRadius.only(
// //                   bottomLeft: Radius.circular(20),
// //                   bottomRight: Radius.circular(20),
// //                 ),
// //               ),
// //               child: Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: width * 0.04),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     GestureDetector(
// //                       onTap: () => Get.back(),
// //                       child: Icon(
// //                         Icons.arrow_back_ios,
// //                         color: Colors.black,
// //                         size: width * 0.06,
// //                       ),
// //                     ),
// //                     Text(
// //                       'Your Activity',
// //                       style: TextStyle(
// //                         fontSize: width * 0.05,
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.black,
// //                       ),
// //                     ),
// //                     Container(
// //                       width: width * 0.08,
// //                       height: width * 0.08,
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         shape: BoxShape.circle,
// //                         border: Border.all(color: Colors.black, width: 2),
// //                       ),
// //                       child: Center(
// //                         child: Icon(
// //                           Icons.info_outline,
// //                           color: Colors.black,
// //                           size: width * 0.05,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),

// //             // Content Section
// //             Expanded(
// //               child: SingleChildScrollView(
// //                 padding: EdgeInsets.all(width * 0.04),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     // Time on Instagram Section
// //                     Text(
// //                       'Time on Instagram',
// //                       style: TextStyle(
// //                         fontSize: width * 0.065,
// //                         fontWeight: FontWeight.w700,
// //                         color: Colors.black,
// //                       ),
// //                     ),

// //                     SizedBox(height: height * 0.04),

// //                     // Today's Time Display
// //                     Center(
// //                       child: Column(
// //                         children: [
// //                           Obx(() => RichText(
// //                                 text: TextSpan(
// //                                   children: [
// //                                     TextSpan(
// //                                       text:
// //                                           '${controller.totalTimeToday.value}',
// //                                       style: TextStyle(
// //                                         fontSize: width * 0.2,
// //                                         fontWeight: FontWeight.w300,
// //                                         color: Color(0xFFFF6B6B),
// //                                       ),
// //                                     ),
// //                                     TextSpan(
// //                                       text: 'm',
// //                                       style: TextStyle(
// //                                         fontSize: width * 0.08,
// //                                         fontWeight: FontWeight.w500,
// //                                         color: Color(0xFFFF6B6B),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               )),
// //                         ],
// //                       ),
// //                     ),

// //                     SizedBox(height: height * 0.04),

// //                     // Daily Average Section
// //                     Center(
// //                       child: Column(
// //                         children: [
// //                           Text(
// //                             'Daily Average',
// //                             style: TextStyle(
// //                               fontSize: width * 0.055,
// //                               fontWeight: FontWeight.w600,
// //                               color: Colors.black,
// //                             ),
// //                           ),
// //                           SizedBox(height: height * 0.01),
// //                           Text(
// //                             'Average time you spent per day using the\nInstagram app on this device in the last\nweek',
// //                             textAlign: TextAlign.center,
// //                             style: TextStyle(
// //                               fontSize: width * 0.04,
// //                               color: Colors.grey[600],
// //                               height: 1.4,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),

// //                     SizedBox(height: height * 0.04),

// //                     // Chart Section
// //                     Container(
// //                       height: height * 0.25,
// //                       child: Obx(() => Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                             crossAxisAlignment: CrossAxisAlignment.end,
// //                             children:
// //                                 controller.dailyActivities.map((activity) {
// //                               double barHeight =
// //                                   (activity.minutes / controller.maxMinutes) *
// //                                       (height * 0.18);
// //                               return Column(
// //                                 mainAxisAlignment: MainAxisAlignment.end,
// //                                 children: [
// //                                   Container(
// //                                     width: width * 0.08,
// //                                     height: barHeight,
// //                                     decoration: BoxDecoration(
// //                                       color: activity.isToday
// //                                           ? Color(0xFF6366F1)
// //                                           : Color(0xFF8B5CF6),
// //                                       borderRadius: BorderRadius.circular(4),
// //                                     ),
// //                                   ),
// //                                   SizedBox(height: height * 0.01),
// //                                   Text(
// //                                     activity.shortDay,
// //                                     style: TextStyle(
// //                                       fontSize: width * 0.032,
// //                                       color: activity.isToday
// //                                           ? Color(0xFF6366F1)
// //                                           : Colors.grey[600],
// //                                       fontWeight: activity.isToday
// //                                           ? FontWeight.w600
// //                                           : FontWeight.w500,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               );
// //                             }).toList(),
// //                           )),
// //                     ),

// //                     SizedBox(height: height * 0.04),

// //                     // Manage Your Time Section
// //                     Text(
// //                       'Manage Your Time',
// //                       style: TextStyle(
// //                         fontSize: width * 0.055,
// //                         fontWeight: FontWeight.w700,
// //                         color: Colors.black,
// //                       ),
// //                     ),

// //                     SizedBox(height: height * 0.025),

// //                     // Set Daily Reminder Option
// //                     Container(
// //                       padding: EdgeInsets.symmetric(vertical: height * 0.02),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'Set Daily Reminder',
// //                                   style: TextStyle(
// //                                     fontSize: width * 0.045,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: Colors.black,
// //                                   ),
// //                                 ),
// //                                 SizedBox(height: height * 0.005),
// //                                 Text(
// //                                   'We\'ll send you a remainder once you\'ve reached\nthe time you set yourself',
// //                                   style: TextStyle(
// //                                     fontSize: width * 0.037,
// //                                     color: Colors.grey[600],
// //                                     height: 1.3,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                           Icon(
// //                             Icons.arrow_forward_ios,
// //                             color: Colors.grey[500],
// //                             size: width * 0.04,
// //                           ),
// //                         ],
// //                       ),
// //                     ),

// //                     // Divider
// //                     Divider(
// //                       color: Colors.grey[300],
// //                       thickness: 1,
// //                     ),

// //                     // Notifications Settings Option
// //                     Container(
// //                       padding: EdgeInsets.symmetric(vertical: height * 0.02),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'Notifications Settings',
// //                                   style: TextStyle(
// //                                     fontSize: width * 0.045,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: Colors.black,
// //                                   ),
// //                                 ),
// //                                 SizedBox(height: height * 0.005),
// //                                 Text(
// //                                   'choose which Instagram notifications to get. You\ncan also pause push notifications.',
// //                                   style: TextStyle(
// //                                     fontSize: width * 0.037,
// //                                     color: Colors.grey[600],
// //                                     height: 1.3,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                           Icon(
// //                             Icons.arrow_forward_ios,
// //                             color: Colors.grey[500],
// //                             size: width * 0.04,
// //                           ),
// //                         ],
// //                       ),
// //                     ),

// //                     SizedBox(height: height * 0.1),
// //                   ],
// //                 ),
// //               ),
// //             ),

// //             // Bottom Navigation Bar
// //             Container(
// //               height: height * 0.08,
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.grey.withOpacity(0.2),
// //                     spreadRadius: 1,
// //                     blurRadius: 5,
// //                     offset: Offset(0, -2),
// //                   ),
// //                 ],
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                 children: [
// //                   Icon(Icons.home, color: Colors.black, size: width * 0.07),
// //                   Icon(Icons.search, color: Colors.black, size: width * 0.07),
// //                   Icon(Icons.add_box_outlined,
// //                       color: Colors.black, size: width * 0.07),
// //                   Icon(Icons.video_library_outlined,
// //                       color: Colors.black, size: width * 0.07),
// //                   Container(
// //                     width: width * 0.07,
// //                     height: width * 0.07,
// //                     decoration: BoxDecoration(
// //                       color: Colors.blue,
// //                       shape: BoxShape.circle,
// //                       image: DecorationImage(
// //                         image: NetworkImage(
// //                             'https://via.placeholder.com/150x150/4285F4/FFFFFF?text=U'),
// //                         fit: BoxFit.cover,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// // Model class for daily activity data
// class DailyActivity {
//   final String day;
//   final String shortDay;
//   final int minutes;
//   final bool isToday;

//   DailyActivity({
//     required this.day,
//     required this.shortDay,
//     required this.minutes,
//     this.isToday = false,
//   });
// }

// // GetX Controller
// class YourActivityController extends GetxController {
//   // Observable variables
//   var totalTimeToday = 1.obs; // in minutes
//   var dailyActivities = <DailyActivity>[].obs;
//   var isDailyReminderEnabled = true.obs;
//   var isNotificationsEnabled = true.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadActivityData();
//   }

//   void loadActivityData() {
//     // Sample data for the week
//     dailyActivities.value = [
//       DailyActivity(day: 'Monday', shortDay: 'MON', minutes: 45),
//       DailyActivity(day: 'Tuesday', shortDay: 'TUE', minutes: 5),
//       DailyActivity(day: 'Wednesday', shortDay: 'WED', minutes: 38),
//       DailyActivity(day: 'Thursday', shortDay: 'THU', minutes: 42),
//       DailyActivity(day: 'Friday', shortDay: 'FRI', minutes: 15),
//       DailyActivity(day: 'Saturday', shortDay: 'SAT', minutes: 25),
//       DailyActivity(
//           day: 'Today', shortDay: 'Today', minutes: 65, isToday: true),
//     ];
//   }

//   void toggleDailyReminder() {
//     isDailyReminderEnabled.value = !isDailyReminderEnabled.value;
//   }

//   void toggleNotifications() {
//     isNotificationsEnabled.value = !isNotificationsEnabled.value;
//   }

//   // Get max minutes for chart scaling
//   int get maxMinutes {
//     if (dailyActivities.isEmpty) return 100;
//     return dailyActivities
//         .map((e) => e.minutes)
//         .reduce((a, b) => a > b ? a : b);
//   }
// }

// class YourActivity extends StatelessWidget {
//   const YourActivity({super.key});

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;

//     // Initialize controller
//     final controller = Get.put(YourActivityController());

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header Section
//             Container(
//               height: height * 0.08,
//               decoration: BoxDecoration(
//                 color: Color(0xFFE6D7FF),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 ),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: width * 0.04),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     GestureDetector(
//                       onTap: () => Get.back(),
//                       child: Icon(
//                         Icons.arrow_back_ios,
//                         color: Colors.black,
//                         size: width * 0.06,
//                       ),
//                     ),
//                     Text(
//                       'Your Activity',
//                       style: TextStyle(
//                         fontSize: width * 0.05,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                       ),
//                     ),
//                     Container(
//                       width: width * 0.08,
//                       height: width * 0.08,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.black, width: 2),
//                       ),
//                       child: Center(
//                         child: Icon(
//                           Icons.info_outline,
//                           color: Colors.black,
//                           size: width * 0.05,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Content Section
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.all(width * 0.04),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Time on Instagram Section
//                     Text(
//                       'Time on Instagram',
//                       style: TextStyle(
//                         fontSize: width * 0.065,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black,
//                       ),
//                     ),

//                     SizedBox(height: height * 0.04),

//                     // Today's Time Display
//                     Center(
//                       child: Column(
//                         children: [
//                           Obx(() => RichText(
//                                 text: TextSpan(
//                                   children: [
//                                     TextSpan(
//                                       text:
//                                           '${controller.totalTimeToday.value}',
//                                       style: TextStyle(
//                                         fontSize: width * 0.2,
//                                         fontWeight: FontWeight.w300,
//                                         color: Color(0xFFFF6B6B),
//                                       ),
//                                     ),
//                                     TextSpan(
//                                       text: 'm',
//                                       style: TextStyle(
//                                         fontSize: width * 0.08,
//                                         fontWeight: FontWeight.w500,
//                                         color: Color(0xFFFF6B6B),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )),
//                         ],
//                       ),
//                     ),

//                     SizedBox(height: height * 0.04),

//                     // Daily Average Section
//                     Center(
//                       child: Column(
//                         children: [
//                           Text(
//                             'Daily Average',
//                             style: TextStyle(
//                               fontSize: width * 0.055,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black,
//                             ),
//                           ),
//                           SizedBox(height: height * 0.01),
//                           Text(
//                             'Average time you spent per day using the\nInstagram app on this device in the last\nweek',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: width * 0.04,
//                               color: Colors.grey[600],
//                               height: 1.4,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     SizedBox(height: height * 0.04),

//                     // Chart Section
//                     Container(
//                       height: height * 0.25,
//                       child: Obx(() => Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children:
//                                 controller.dailyActivities.map((activity) {
//                               double barHeight =
//                                   (activity.minutes / controller.maxMinutes) *
//                                       (height * 0.18);
//                               return Column(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   Container(
//                                     width: width * 0.08,
//                                     height: barHeight,
//                                     decoration: BoxDecoration(
//                                       color: activity.isToday
//                                           ? Color(0xFF6366F1)
//                                           : Color(0xFF8B5CF6),
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                   ),
//                                   SizedBox(height: height * 0.01),
//                                   Text(
//                                     activity.shortDay,
//                                     style: TextStyle(
//                                       fontSize: width * 0.032,
//                                       color: activity.isToday
//                                           ? Color(0xFF6366F1)
//                                           : Colors.grey[600],
//                                       fontWeight: activity.isToday
//                                           ? FontWeight.w600
//                                           : FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }).toList(),
//                           )),
//                     ),

//                     SizedBox(height: height * 0.04),

//                     // Manage Your Time Section
//                     Text(
//                       'Manage Your Time',
//                       style: TextStyle(
//                         fontSize: width * 0.055,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black,
//                       ),
//                     ),

//                     SizedBox(height: height * 0.025),

//                     // Set Daily Reminder Option
//                     Container(
//                       padding: EdgeInsets.symmetric(vertical: height * 0.02),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Set Daily Reminder',
//                                   style: TextStyle(
//                                     fontSize: width * 0.045,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 SizedBox(height: height * 0.005),
//                                 Text(
//                                   'We\'ll send you a remainder once you\'ve reached\nthe time you set yourself',
//                                   style: TextStyle(
//                                     fontSize: width * 0.037,
//                                     color: Colors.grey[600],
//                                     height: 1.3,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Icon(
//                             Icons.arrow_forward_ios,
//                             color: Colors.grey[500],
//                             size: width * 0.04,
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Divider
//                     Divider(
//                       color: Colors.grey[300],
//                       thickness: 1,
//                     ),

//                     // Notifications Settings Option
//                     Container(
//                       padding: EdgeInsets.symmetric(vertical: height * 0.02),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Notifications Settings',
//                                   style: TextStyle(
//                                     fontSize: width * 0.045,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 SizedBox(height: height * 0.005),
//                                 Text(
//                                   'choose which Instagram notifications to get. You\ncan also pause push notifications.',
//                                   style: TextStyle(
//                                     fontSize: width * 0.037,
//                                     color: Colors.grey[600],
//                                     height: 1.3,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Icon(
//                             Icons.arrow_forward_ios,
//                             color: Colors.grey[500],
//                             size: width * 0.04,
//                           ),
//                         ],
//                       ),
//                     ),

//                     SizedBox(height: height * 0.1),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Model class for daily activity data
class DailyActivity {
  final String day;
  final String shortDay;
  final int minutes;
  final bool isToday;

  DailyActivity({
    required this.day,
    required this.shortDay,
    required this.minutes,
    this.isToday = false,
  });
}

// GetX Controller
class YourActivityController extends GetxController {
  // Observable variables
  var totalTimeToday = 1.obs; // in minutes
  var dailyActivities = <DailyActivity>[].obs;
  var isDailyReminderEnabled = true.obs;
  var isNotificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadActivityData();
  }

  void loadActivityData() {
    // Sample data for the week
    dailyActivities.value = [
      DailyActivity(day: 'Monday', shortDay: 'MON', minutes: 45),
      DailyActivity(day: 'Tuesday', shortDay: 'TUE', minutes: 5),
      DailyActivity(day: 'Wednesday', shortDay: 'WED', minutes: 38),
      DailyActivity(day: 'Thursday', shortDay: 'THU', minutes: 42),
      DailyActivity(day: 'Friday', shortDay: 'FRI', minutes: 15),
      DailyActivity(day: 'Saturday', shortDay: 'SAT', minutes: 25),
      DailyActivity(
          day: 'Today', shortDay: 'Today', minutes: 65, isToday: true),
    ];
  }

  void toggleDailyReminder() {
    isDailyReminderEnabled.value = !isDailyReminderEnabled.value;
  }

  void toggleNotifications() {
    isNotificationsEnabled.value = !isNotificationsEnabled.value;
  }

  // Get max minutes for chart scaling
  int get maxMinutes {
    if (dailyActivities.isEmpty) return 100;
    return dailyActivities
        .map((e) => e.minutes)
        .reduce((a, b) => a > b ? a : b);
  }
}

class YourActivity extends StatelessWidget {
  const YourActivity({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // Initialize controller
    final controller = Get.put(YourActivityController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF7D64FF), // Purple color from left
                Color(0xFFFFFFFF), // White color to right
              ],
            ),
            // borderRadius: BorderRadius.only(
            //   bottomLeft: Radius.circular(20),
            //   bottomRight: Radius.circular(20),
            // ),
          ),
        ),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: width * 0.06,
          ),
        ),
        title: Text(
          'Your Activity',
          style: TextStyle(
            fontSize: width * 0.05,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          Container(
            width: width * 0.08,
            height: width * 0.08,
            margin: EdgeInsets.only(right: width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Center(
              child: Icon(
                Icons.info_outline,
                color: Colors.black,
                size: width * 0.05,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time on Instagram Section
              Text(
                'Time on Instagram',
                style: TextStyle(
                  fontSize: width * 0.065,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: height * 0.04),

              // Today's Time Display
              Center(
                child: Column(
                  children: [
                    Obx(() => RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${controller.totalTimeToday.value}',
                                style: TextStyle(
                                  fontSize: width * 0.2,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                              TextSpan(
                                text: 'm',
                                style: TextStyle(
                                  fontSize: width * 0.08,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              SizedBox(height: height * 0.04),

              // Daily Average Section
              Center(
                child: Column(
                  children: [
                    Text(
                      'Daily Average',
                      style: TextStyle(
                        fontSize: width * 0.055,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      'Average time you spent per day using the\nInstagram app on this device in the last\nweek',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.04),

              // Chart Section
              Container(
                height: height * 0.25,
                child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: controller.dailyActivities.map((activity) {
                        double barHeight =
                            (activity.minutes / controller.maxMinutes) *
                                (height * 0.18);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: width * 0.08,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: activity.isToday
                                    ? Color(0xFF6366F1)
                                    : Color(0xFF8B5CF6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            Text(
                              activity.shortDay,
                              style: TextStyle(
                                fontSize: width * 0.032,
                                color: activity.isToday
                                    ? Color(0xFF6366F1)
                                    : Colors.grey[600],
                                fontWeight: activity.isToday
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    )),
              ),

              SizedBox(height: height * 0.04),

              // Manage Your Time Section
              Text(
                'Manage Your Time',
                style: TextStyle(
                  fontSize: width * 0.055,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: height * 0.025),

              // Set Daily Reminder Option
              Container(
                padding: EdgeInsets.symmetric(vertical: height * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Set Daily Reminder',
                            style: TextStyle(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: height * 0.005),
                          Text(
                            'We\'ll send you a remainder once you\'ve reached\nthe time you set yourself',
                            style: TextStyle(
                              fontSize: width * 0.037,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[500],
                      size: width * 0.04,
                    ),
                  ],
                ),
              ),

              // Divider
              Divider(
                color: Colors.grey[300],
                thickness: 1,
              ),

              // Notifications Settings Option
              Container(
                padding: EdgeInsets.symmetric(vertical: height * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications Settings',
                            style: TextStyle(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: height * 0.005),
                          Text(
                            'choose which Instagram notifications to get. You\ncan also pause push notifications.',
                            style: TextStyle(
                              fontSize: width * 0.037,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[500],
                      size: width * 0.04,
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
