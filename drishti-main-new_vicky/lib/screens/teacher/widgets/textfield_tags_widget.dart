// ignore_for_file: unused_import

import 'package:srisridrishti/providers/teacher_provider.dart';
import 'package:srisridrishti/screens/teacher/screens/teacher_search_screen.dart';
import 'package:srisridrishti/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Widget textFieldWithTagsWidget(
    TextEditingController controller, String hintText,
    {IconData? prefixIcon,
    String? Function(String?)? validator,
    Color? labelColor,
    IconData? suffixIcon,
    List<String>? tags,
    void Function(String)? onTagAdded,
    onTap,
    List<String>? addedTeachers,
    userName,
    mcontext}) {
  // print(userName);
  userName == "" ? onTagAdded! : onTagAdded!.call(userName);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: controller,
        validator: validator,
        onFieldSubmitted: (value) {
          if (value.isNotEmpty) {
            onTagAdded.call(value);
            controller.clear();
          }
        },
        onTap: onTap,
        style: GoogleFonts.manrope(
          textStyle: TextStyle(
            color: labelColor != null ? AppColors.primaryColor : Colors.black,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(14),
          hintText: hintText,
          labelText: hintText,
          labelStyle: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          fillColor: Colors.white,
          filled: true,
          hintStyle: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  size: 17.sp,
                  color: Colors.grey.withOpacity(0.4),
                )
              : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(
                    suffixIcon,
                    size: 18.sp,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      onTagAdded.call(controller.text);
                      controller.clear();
                    }
                  },
                )
              : null,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(6),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: (addedTeachers ?? []).map((teacher) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  teacher,
                  style: GoogleFonts.manrope(
                    textStyle: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    // Handle removing teacher
                  },
                  child: Icon(
                    Icons.close,
                    size: 18.sp,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ],
  );
}
