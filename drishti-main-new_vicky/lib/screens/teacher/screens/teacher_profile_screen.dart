import 'package:srisridrishti/bloc/all_event_bloc/all_event_bloc.dart';
import 'package:srisridrishti/models/all_events_model.dart';
import 'package:srisridrishti/providers/home_provider.dart';
import 'package:srisridrishti/screens/home/widgets/event_shimmer_effect.dart';
import 'package:srisridrishti/screens/teacher/screens/course_details_screen.dart';
import 'package:srisridrishti/screens/teacher/screens/schedule_meeting.dart';
import 'package:srisridrishti/screens/teacher/widgets/course_attend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user_details_model.dart';
import '../../../themes/theme.dart';
import '../../../utils/constants.dart';
import '../../../widgets/add_icon_button.dart';
import '../../../widgets/common_container_button.dart';
import '../../home/widgets/course_details_card.dart';

class TeacherProfileScreen extends StatefulWidget {
  final UserDetailsModel? userDetails;
  const TeacherProfileScreen({super.key, required this.userDetails});

  @override
  TeacherProfileScreenState createState() => TeacherProfileScreenState();
}

class TeacherProfileScreenState extends State<TeacherProfileScreen>
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
    var width = MediaQuery.of(context).size.height;
    final HomeProvider homeProvider = Provider.of(context, listen: true);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      // crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            widget.userDetails!.profileImage!.isNotEmpty
                ? ClipOval(
                    child: Image(
                    image: NetworkImage(widget.userDetails!.profileImage!),
                    width: 80.0,
                    height: 80.0,
                    fit: BoxFit.cover,
                  ))
                : ClipOval(
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
        const SizedBox(height: 15),
        Text(
          "Courses Teach",
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 15.sp,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(onTap: () {}, child: addIconButton()),
            SizedBox(
              height: 30.sp,
              width: 285.sp,
              child: ListView.builder(
                  padding: const EdgeInsets.only(left: 10),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: kriyaNames.length,
                  itemBuilder: (context, index) {
                    String name = kriyaNames[index];
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.sp),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.5)),
                        ),
                        margin: const EdgeInsets.only(right: 10),
                        alignment: Alignment.center,
                        child: Text(
                          kriyaNames[index],
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
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
                                        widget.userDetails!.mobileNo.toString(),
                                        style: const TextStyle(fontSize: 24),
                                      )
                                    ],
                                  ),
<<<<<<< HEAD
=======
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
>>>>>>> parent of 283b956a (latest update .create course is remaining)
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
              ),
            )),
            const SizedBox(width: 20),
            Expanded(
                child: InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const ScheduleMeetingScreen();
                      }));
                    },
                    child: const CommonContainerButton(
                        labelText: "Create Course"))),
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
            Tab(text: "Courses Created"),
<<<<<<< HEAD
            // Tab(text: "Courses Attended"), // Commented out Courses Attended tab
=======
            Tab(text: "Courses Attended"),
>>>>>>> parent of 283b956a (latest update .create course is remaining)
          ],
        ),
        SizedBox(
          height: 345.sp, // Adjust height as needed
          child: TabBarView(
            controller: _tabController,
            children: [
              // Content for "Courses Created" tab
<<<<<<< HEAD
=======

>>>>>>> parent of 283b956a (latest update .create course is remaining)
              BlocBuilder<AllEventBloc, AllEventState>(
                builder: (context, state) {
                  if (state is AllEventLoadSuccess) {
                    final events = state.events.data?.data ?? [];
<<<<<<< HEAD
=======

                    return Column(
                      children: [
                        Expanded(
                            child: ListView.builder(
                                padding: const EdgeInsets.all(0),
                                shrinkWrap: true,
                                itemCount: events
                                    .length, // Use the actual length of events
                                itemBuilder: (context, index) {
                                  if (index < events.length) {
                                    // Add this check
                                    final EventData res = events[index];
                                    if ((res.events?.isNotEmpty ?? false)) {
                                      // Check if the date filter is applied
                                      if (homeProvider.selectedDate != null) {
                                        // Filter events based on the selected date
                                        res.events!.where((event) {
                                          // Parse the dateTo string to DateTime
                                          DateTime? eventDate = event.dateTo;
                                          if (eventDate == null) return false;
                                          return formatDate(eventDate) ==
                                              formatDate(
                                                  homeProvider.selectedDate!);
                                        }).toList();

                                        // Use filteredEvents if needed
                                      }

                                      if (res.events != null &&
                                          res.events!.isNotEmpty) {
                                        DateTime dateTime =
                                            res.events![0].dateFrom!;
                                        String formattedDate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(dateTime);

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TeacherCourseDetailsScreen(
                                                        event: res.events![0],
                                                        userID: userID),
                                              ),
                                            );
                                          },
                                          child: courseDetailsCard(
                                            width: width.sp,
                                            courseName: res.events![0].title![0]
                                                .toString(),
                                            courseDate: formattedDate,
                                            coursetime: res
                                                .events![0].durationTo
                                                .toString(),
                                            courseStartsIn: "Start in 2 hours",
                                            courseMode: 'Online',
                                          ),
                                        );
                                      }
                                    }
                                  }
                                  return null;
                                }))
                      ],
                    );
                  } else {
                    return eventShimmerEffect();
                  }
                },
              ),
              CoursesAttendedScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
>>>>>>> parent of 283b956a (latest update .create course is remaining)

                    return Column(
                      children: [
                        Expanded(
                            child: ListView.builder(
                                padding: const EdgeInsets.all(0),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  if (index < events.length) {
                                    final EventData res = events[index];
                                    if ((res.events?.isNotEmpty ?? false)) {
                                      if (homeProvider.selectedDate != null) {
                                        res.events!.where((event) {
                                          DateTime? eventDate = event.dateTo;
                                          if (eventDate == null) return false;
                                          return formatDate(eventDate) ==
                                              formatDate(
                                                  homeProvider.selectedDate!);
                                        }).toList();
                                      }

                                      if (res.events != null &&
                                          res.events!.isNotEmpty) {
                                        DateTime dateTime =
                                            res.events![0].dateFrom!;
                                        String formattedDate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(dateTime);

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TeacherCourseDetailsScreen(
                                                        event: res.events![0],
                                                        userID: userID),
                                              ),
                                            );
                                          },
                                          child: courseDetailsCard(
                                            width: width.sp,
                                            courseName: res.events![0].title![0]
                                                .toString(),
                                            courseDate: formattedDate,
                                            coursetime: res
                                                .events![0].durationTo
                                                .toString(),
                                            courseStartsIn: "Start in 2 hours",
                                            courseMode: 'Online',
                                          ),
                                        );
                                      }
                                    }
                                  }
                                  return null;
                                }))
                      ],
                    );
                  } else {
                    return eventShimmerEffect();
                  }
                },
              ),
              // CoursesAttendedScreen(), // Commented out CoursesAttendedScreen
            ],
          ),
        ),
      ],
    );
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
}
