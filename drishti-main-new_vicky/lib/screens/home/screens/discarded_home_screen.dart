import 'package:srisridrishti/screens/home/widgets/home_appbar.dart';
import 'package:srisridrishti/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DiscardedHomeScreen extends StatelessWidget {
  const DiscardedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: homeAppbar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 70.sp,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    DateTime date = DateTime.now().add(Duration(days: index));
                    return _buildDateItem(date);
                  },
                ),
              ),
              const SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30.sp,
                    width: 275.sp,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.sp),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.5)),
                            ),
                            margin: const EdgeInsets.only(right: 10),
                            alignment: Alignment.center,
                            child: Text(
                              "Sudarhsan",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          );
                        }),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black38),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.filter_alt,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "09:30",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          "View All >",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                        height: 205.sp,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return const Padding(
                                padding: EdgeInsets.only(right: 15.0),
                                child: SizedBox(), // HomeListViewItem(),
                              );
                            })),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "09:30",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          "View All >",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateItem(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: 55.sp,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.4))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            DateFormat('EEE').format(date), // Day of the week (e.g., Mon)
            style: GoogleFonts.manrope(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            DateFormat('dd').format(date), // Day of the month (e.g., 01)
            style: GoogleFonts.manrope(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
