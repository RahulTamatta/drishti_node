import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar teacherAppbar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    leading: IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: const Icon(
        Icons.arrow_back_ios,
        size: 20,
        color: Colors.black,
      ),
    ),
    title: Text(
      "Sagar Kumar",
      style: GoogleFonts.manrope(
        textStyle: TextStyle(
            color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.w600),
      ),
    ),
    actions: [
      IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          )),
    ],
  );
}
