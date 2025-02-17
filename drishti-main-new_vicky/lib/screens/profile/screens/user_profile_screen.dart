import 'package:srisridrishti/screens/teacher/widgets/course_attend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user_details_model.dart';
import '../../../themes/theme.dart';

class UserProfileScreen extends StatefulWidget {
  final UserDetailsModel? userDetails;
  const UserProfileScreen({super.key, required this.userDetails});

  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    getUserID();
    _tabController = TabController(length: 2, vsync: this);
  }

  var userID = "";
  Future<void> getUserID() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.getString("UserID");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var width = MediaQuery.of(context).size.height;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      // crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.userDetails?.profileImage != null && 
                widget.userDetails!.profileImage!.isNotEmpty)
              ClipOval(
                child: Image(
                  image: NetworkImage(widget.userDetails!.profileImage!),
                  width: 80.0,
                  height: 80.0,
                  fit: BoxFit.cover,
                ),
              )
            else
              ClipOval(
                child: Image.asset(
                  'assets/images/user.png',
                  width: 72.0,
                  height: 72.0,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userDetails?.name ?? "",
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    "It is a long established fact that a reader will be distracted by the readable fnmue content of a page by the readable fnmue content of a page",
                    maxLines: 3,
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        color: Colors.black54,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 20.sp),
        Row(
          children: [
            Expanded(
              child: InkWell(
                  onTap: () {
                    showModalBottomSheet<void>(
                        isDismissible: true,
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                              height: 150,
                              color: Colors.white,
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2, vertical: 3),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 130, vertical: 2),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: AppColors.lightgrey_BDBDBD),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.email_outlined,
                                        size: 24,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        widget.userDetails!.email.toString(),
                                        style: const TextStyle(fontSize: 24),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.phone_in_talk,
                                            size: 24,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Text(
                                            widget.userDetails!.mobileNo
                                                .toString(),
                                            style:
                                                const TextStyle(fontSize: 24),
                                          )
                                        ],
                                      ),
                                      //       Row(
                                      //   children: [
                                      //     Icon(
                                      //       Icons.phone_in_talk,
                                      //       size: 12,
                                      //       color: Colors.grey,
                                      //     ),
                                      //     Text(widget.userDetails!.email.toString())
                                      //   ],
                                      // )
                                    ],
                                  )
                                ],
                              ));
                        });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.sp),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: AppColors.primaryColor)),
                    alignment: Alignment.center,
                    child: Text(
                      "Contact Info",
                      style: GoogleFonts.manrope(
                        textStyle: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  )),
            )
          ],
        ),
        SizedBox(height: 10.sp),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryColor,
          labelStyle: GoogleFonts.manrope(
              textStyle: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          )),
          tabs: const [
            // Tab(text: "Courses Created"),
            Tab(text: "Courses Attended"),
          ],
        ),
        SizedBox(
          height: 345.sp, // Adjust height as needed
          child: TabBarView(
            controller: _tabController,
            children: [
              CoursesAttendedScreen(),
            ],
          ),
        ),
      ],
    );
  }
}

String formatDate(DateTime date) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}

DateTime? parseDate(String? dateString) {
  if (dateString == null) return null;
  try {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  } catch (e) {
    print('Error parsing date: $e');
    return null;
  }
}
