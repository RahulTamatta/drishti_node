import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar homeAppbar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        const Icon(
          Icons.location_on,
          color: Colors.red,
        ),
        const SizedBox(width: 10),
        Text(
          "Mumbai",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: Icon(
            Icons.keyboard_arrow_down_sharp,
            color: Colors.black,
            size: 20,
          ),
        ),
      ],
    ),
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 35.0),
        child: Icon(
          CupertinoIcons.search,
          color: Colors.black,
        ),
      ),
    ],
  );
}
