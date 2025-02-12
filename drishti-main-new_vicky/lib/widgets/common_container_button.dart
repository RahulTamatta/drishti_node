import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/theme.dart';

class CommonContainerButton extends StatelessWidget {
  final String labelText;
  const CommonContainerButton({super.key, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.sp),
      width: double.maxFinite,
      decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(7)),
      alignment: Alignment.center,
      child: Text(
        labelText,
        style: GoogleFonts.manrope(
          textStyle: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
