import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubheadingStyles {
  static TextStyle subheading1({Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
      fontSize: 18.sp,
      color: color,
    );
  }

  static TextStyle subheading2({Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
      fontSize: 16.sp,
      color: color,
    );
  }

  static TextStyle subheading3({Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
      fontSize: 12.sp,
      color: color,
    );
  }

  static TextStyle subheading4({Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w200,
      fontSize: 9.sp,
      color: color,
    );
  }
}
