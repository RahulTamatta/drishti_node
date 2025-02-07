import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme.dart';

class HeadingStyles {
  static TextStyle heading1({Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      fontSize: 28.sp,
      color: color ?? AppColors.primaryColor500,
    );
  }

  static TextStyle heading2({Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      fontSize: 24.sp,
      color: color,
    );
  }

  static TextStyle heading3({Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      fontSize: 20.sp,
      color: color,
    );
  }
}
