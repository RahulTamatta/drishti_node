import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar locationAppBar(BuildContext context) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    leading: IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: const Icon(
        Icons.arrow_back_ios,
        color: Colors.black,
        size: 20,
      ),
    ),
    centerTitle: false,
    title: Text(
      "Update Location",
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
            color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
