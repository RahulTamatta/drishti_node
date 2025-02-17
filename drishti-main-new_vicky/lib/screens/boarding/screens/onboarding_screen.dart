import 'package:srisridrishti/widgets/common_container_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png"),
            const SizedBox(height: 20),
            Text(
              "Welcome to\nart of living",
              style: GoogleFonts.aBeeZee(
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 27.sp,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 90),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.sp),
                child: const CommonContainerButton(
                    labelText: "Continue as Participant")),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.sp),
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(7)),
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 15.sp),
              child: Text(
                "Continue as Art of Living Teacher",
                style: GoogleFonts.manrope(
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
