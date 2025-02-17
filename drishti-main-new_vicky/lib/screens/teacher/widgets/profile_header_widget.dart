import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

Widget profileHeaderWidget() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(radius: 35.sp),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sagar Kumar",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                "It is a long established fact that a reader will be distracted content of a page.",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      )
    ],
  );
}
