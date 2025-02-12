import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/theme.dart';

Widget addIconButton() {
  return Container(
    padding: const EdgeInsets.all(1),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: AppColors.primaryColor, width: 3),
    ),
    margin: EdgeInsets.only(right: 4.sp),
    alignment: Alignment.center,
    child: const Icon(Icons.add, color: AppColors.primaryColor),
  );
}
