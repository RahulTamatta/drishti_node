import 'package:srisridrishti/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

Widget bulletTexts(String bulletText) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2.0),
          child: Icon(Icons.brightness_1, size: 8, color: Colors.black),
        ),
        const SizedBox(width: 8),
        Text(
          bulletText,
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

uploadDocument() => Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset("assets/icons/doc_upload.png"),
        const SizedBox(width: 15),
        Text(
          'Upload Documents',
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
