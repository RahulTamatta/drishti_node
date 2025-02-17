import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../themes/theme.dart';

class courseDetailsCard extends StatelessWidget {
  const courseDetailsCard({
    super.key,
    required this.width,
    required this.courseName,
    required this.courseDate,
    required this.coursetime,
    required this.courseStartsIn,
    required this.courseMode,
  });

  final double width;
  final String courseName;
  final String courseDate;
  final String coursetime;
  final String courseStartsIn;
  final String courseMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.010, vertical: width * 0.01),
      margin: EdgeInsets.symmetric(
          horizontal: width * 0.01, vertical: width * 0.02),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.cardColor1_FFE3E3, AppColors.cardColor2_FEC9C9]),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            courseName,
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                  color: AppColors.brown_511D1D,
                  fontSize: width * 0.025,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/images/calendar.svg",
                        height: width * 0.02,
                        width: width * 0.02,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        courseDate,
                        style: GoogleFonts.manrope(
                          textStyle: TextStyle(
                              color: AppColors.brown_511D1D,
                              fontSize: width * 0.016,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/images/clock.svg",
                        height: width * 0.02,
                        width: width * 0.02,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        coursetime,
                        style: GoogleFonts.manrope(
                          textStyle: TextStyle(
                              color: AppColors.brown_511D1D,
                              fontSize: width * 0.016,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        'Start In $courseStartsIn hours',
                        style: GoogleFonts.manrope(
                          textStyle: TextStyle(
                              color: AppColors.brown_511D1D,
                              fontSize: width * 0.015,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.02, vertical: width * 0.012),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            border:
                                Border.all(color: AppColors.cardColor1_FFE3E3),
                            color: Colors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              "assets/images/online.svg",
                              height: width * 0.02,
                              width: width * 0.02,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Online',
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: width * 0.018,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.02, vertical: width * 0.012),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            border:
                                Border.all(color: AppColors.cardColor1_FFE3E3),
                            color: Colors.white),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.home,
                              color: AppColors.brown_511D1D.withOpacity(0.8),
                              size: 18.sp,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Offline',
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: width * 0.018,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/images/course.svg",
                            height: width * 0.02,
                            width: width * 0.02,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Course',
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: width * 0.018,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            color: AppColors.brown_511D1D.withOpacity(0.7),
                            size: 18.sp,
                          ),
                          SizedBox(
                            width: width * 0.01,
                          ),
                          Text(
                            'Follow up',
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: width * 0.018,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Stack(alignment: Alignment.center, children: <Widget>[
                Container(
                  width: 80.0.sp,
                  height: 80.0.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cardColor1_FFE3E3,
                      // Color of the ring
                      width: 4.0, // Width of the ring
                    ),
                  ),
                ),
                ClipOval(
                  child: Image.asset(
                    'assets/images/ellipse_yoga.png',
                    width: 78.0.sp,
                    height: 78.0.sp,
                    fit: BoxFit.cover,
                  ),
                ),
              ])
            ],
          )
        ],
      ),
    );
  }
}
