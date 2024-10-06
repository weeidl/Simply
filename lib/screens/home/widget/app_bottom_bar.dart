// import 'package:flutter/material.dart';
// import 'package:sms_forward_app/style/colors.dart';
//
// class AppBottomBar extends StatefulWidget {
//   final int selectedIndex;
//   final GestureTapCallback onTap;
//
//   const AppBottomBar({
//     super.key,
//     required this.selectedIndex,
//     required this.onTap,
//   });
//
//   @override
//   State<AppBottomBar> createState() => _AppBottomBarState();
// }
//
// class _AppBottomBarState extends State<AppBottomBar> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 60,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 0,
//             blurRadius: 24,
//             offset: const Offset(0, -3),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildNavItem(Icons.search, 'Discover', 0),
//           _buildNavItem(Icons.message, 'Message', 1),
//           _buildNavItem(Icons.settings, 'Settings', 2),
//         ],
//       ),
//     );
//   }
// }
//
// Widget _buildNavItem(IconData icon, String label, int index) {
//   return GestureDetector(
//     onTap: widget.onTap,
//     child: Row(
//       children: [
//         Icon(
//           icon,
//           color: widget.selectedIndex == index ? AppColor.orange : Colors.grey,
//         ),
//         const SizedBox(width: 5),
//         Text(
//           label,
//           style: TextStyle(
//             color:
//                 widget.selectedIndex == index ? AppColor.orange : Colors.grey,
//           ),
//         ),
//       ],
//     ),
//   );
// }
