import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

showToast(
    {required String text,
    required Color color,
    required BuildContext context}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(
          text,
          style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ),
        backgroundColor: color),
  );
}
