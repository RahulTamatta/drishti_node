// import 'package:srisridrishti/screens/teacher/screens/schedule_meeting.dart';
// import 'package:srisridrishti/screens/teacher/widgets/profile_header_widget.dart';
// import 'package:srisridrishti/screens/teacher/widgets/teacher_appbar.dart';
// import 'package:srisridrishti/themes/theme.dart';
// import 'package:srisridrishti/widgets/common_container_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../../widgets/add_icon_button.dart';

// class TeacherScreen extends StatelessWidget {
//   const TeacherScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: teacherAppbar(context),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             profileHeaderWidget(),
//             const SizedBox(height: 15),
//             Text(
//               "Courses Teach",
//               style: GoogleFonts.poppins(
//                 textStyle: TextStyle(
//                     color: Colors.black,
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w500),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 addIconButton(),
//                 const Spacer(),
//                 SizedBox(
//                   height: 30.sp,
//                   width: 275.sp,
//                   child: ListView.builder(
//                       //  padding: const EdgeInsets.only(left: 10),
//                       shrinkWrap: true,
//                       scrollDirection: Axis.horizontal,
//                       itemCount: 5,
//                       itemBuilder: (context, index) {
//                         return Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: const Color(0xfffebf4ff),
//                             borderRadius: BorderRadius.circular(15.sp),
//                             border: Border.all(
//                               color: const Color(0xfff3487ed),
//                             ),
//                           ),
//                           margin: const EdgeInsets.only(right: 10),
//                           alignment: Alignment.center,
//                           child: Text(
//                             "Sudarhsan",
//                             style: GoogleFonts.poppins(
//                               textStyle: TextStyle(
//                                   color: const Color(0xfff054089),
//                                   fontSize: 13.sp,
//                                   fontWeight: FontWeight.w400),
//                             ),
//                           ),
//                         );
//                       }),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 25),
//             Row(
//               children: [
//                 Expanded(
//                     child: Container(
//                   padding: EdgeInsets.symmetric(vertical: 12.sp),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(7),
//                       border: Border.all(color: AppColors.primaryColor)),
//                   alignment: Alignment.center,
//                   child: Text(
//                     "Contact Info",
//                     style: GoogleFonts.manrope(
//                       textStyle: TextStyle(
//                           color: AppColors.primaryColor,
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 )),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: InkWell(
//                       onTap: () {
//                         Navigator.of(context)
//                             .push(MaterialPageRoute(builder: (context) {
//                           return const ScheduleMeetingScreen();
//                         }));
//                       },
//                       child: const CommonContainerButton(
//                           labelText: "Create Courses")),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
