import 'package:srisridrishti/screens/home/widgets/show_course_card.dart';
import 'package:srisridrishti/services/events_services/events_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import '../../../models/map_models.dart';
import '../../../utils/constants.dart';
import '../../../utils/month_dates.dart';
import '../../../utils/shared_preference_helper.dart';

class FilterBottomSheet extends StatefulWidget {
  final LatLng? currentPosition;

  const FilterBottomSheet({super.key, this.currentPosition});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomShetState();
}

class _FilterBottomShetState extends State<FilterBottomSheet> {
  DateTime selectedMonth = DateTime.now();
  DateTime? selectedDate;
  bool isSelected = false;
  List<DateTime> list_of_day = [];
  bool _isLoading = false;
  List<EventModel> events = [];

  @override
  void initState() {
    list_of_day = getDatesInMonth(selectedMonth.month);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.currentPosition != null) {
        getEvents(
            dateTime: DateTime.now(),
            lat: widget.currentPosition!.latitude,
            long: widget.currentPosition!.longitude);
      } else {
        getEvents(dateTime: DateTime.now());
      }
    });
  }

  void getEvents({
    required DateTime dateTime,
    double? lat,
    double? long,
  }) async {
    String? token = await SharedPreferencesHelper.getAccessToken() ?? await SharedPreferencesHelper.getRefreshToken();
    print("Token: $token");
    setState(() {
      _isLoading = true;
    });
    var result = await EventServices()
        .getEvents(token: token, date: dateTime, lat: lat, long: long);
    if (result != null) {
      setState(() {
        _isLoading = false;
        events = result;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void getEventsByTag({
    required String? tag,
  }) async {
    String? token = await SharedPreferencesHelper.getAccessToken() ?? await SharedPreferencesHelper.getRefreshToken();
    print("Token: $token");
    setState(() {
      _isLoading = true;
    });
    var result = await EventServices()
        .getEvents(token: token, date: DateTime.now(), course: tag);
    if (result != null) {
      setState(() {
        _isLoading = false;
        events = result;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBFE),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 2.4,
                right: MediaQuery.of(context).size.width / 2.4,
                top: 14),
            child: const Divider(
                color: Color(0xffA6A6A6), height: 4, thickness: 4),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40, // Adjust the height as needed
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              scrollDirection: Axis.horizontal,
                              itemCount: 12,
                              // 12 months
                              separatorBuilder: (context, index) {
                                return const SizedBox(width: 15);
                              },
                              itemBuilder: (context, index) {
                                final month = DateTime.now()
                                    .add(Duration(days: 31 * index));

                                // Months ahead
                                return Material(
                                  color: selectedMonth == null
                                      ? const Color(0xff0692F8)
                                      : Jiffy.parseFromDateTime(month).MEd ==
                                              Jiffy.parseFromDateTime(
                                                      selectedMonth)
                                                  .MEd
                                          ? const Color(0xff0692F8)
                                          : const Color(0x7FD9D0D7),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: selectedMonth == null
                                            ? 0
                                            : Jiffy.parseFromDateTime(month)
                                                        .MEd ==
                                                    Jiffy.parseFromDateTime(
                                                            selectedMonth)
                                                        .MEd
                                                ? 1
                                                : 0,
                                        color: const Color(0xFFE3D0EE)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      list_of_day =
                                          getDatesInMonth(month.month);
                                      setState(() {
                                        selectedDate = null;
                                        selectedMonth = month;
                                        isSelected =
                                            true; // Update selected month
                                      });
                                    },
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 24, right: 24),
                                        child: Text(
                                          DateFormat('MMM').format(month),
                                          style: TextStyle(
                                            color: selectedMonth == null
                                                ? const Color(0x7F6A5079)
                                                : Jiffy.parseFromDateTime(month)
                                                            .MEd ==
                                                        Jiffy.parseFromDateTime(
                                                                selectedMonth)
                                                            .MEd
                                                    ? Colors.white
                                                    : const Color(0x7F6A5079),
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.all(11.0),
                              child: Image(
                                  image: AssetImage(
                                      "assets/images/search_icon.png"),
                                  height: 20,
                                  width: 20),
                            ),
                          ),
                        )
                      ],
                    ),
                    // Date Picker
                    Container(
                      height: 70,
                      decoration: const BoxDecoration(color: Color(0xff101010)),
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: ListView.separated(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Material(
                              borderRadius: BorderRadius.circular(12),
                              color: selectedDate == list_of_day[index]
                                  ? const Color(0xFF0692F8)
                                  : Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  getEvents(dateTime: list_of_day[index]);
                                  setState(() {
                                    selectedDate = list_of_day[index];
                                  });
                                },
                                child: SizedBox(
                                  width: 60,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 12,
                                        right: 12),
                                    child: Column(
                                      children: [
                                        Text(
                                          Jiffy.parseFromDateTime(
                                                  list_of_day[index])
                                              .E,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          list_of_day[index].day.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              width: 10,
                            );
                          },
                          itemCount: list_of_day.length),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Tags Section

          SizedBox(
              height: 35,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        // itemCount: courseList_Provider.tagsList.length,
                        itemCount: tagList.length,
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 8);
                        },
                        itemBuilder: (context, index) {
                          // var tag = courseList_Provider.tagsList[index];
                          return Material(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                    width: 1, color: Color(0xFFE3D0EE))),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                getEventsByTag(tag: tagList[index].name);
                              },
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 12,
                                  ),
                                  child: Text(
                                    tagList[index].name,
                                    style: TextStyle(
                                      color: tagList[index].color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(width: 12)
                ],
              )),
          const SizedBox(height: 15),

          if (_isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),

          // show courses listview below
          if (_isLoading == false)
            Expanded(
              child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                  scrollDirection: Axis.vertical,
                  // itemCount: providerCourseList.myMap.length, // courseMokData.myMap.length,
                  itemCount: events.length,
                  // courseMokData.myMap.length,
                  itemBuilder: (context, index) {
                    var listTimes = [];

                    return Container(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Material(
                              color: const Color(0xFF6A5079),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 0.50, color: Color(0xFF6A5079)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, bottom: 8, top: 8),
                                child: Text(
                                  // eachTime, //times
                                  events[index].time, //times
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.41,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 185,
                            child: ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                // itemCount: sameTimeCourses.length,
                                itemCount: events[index].evens_list.length,
                                separatorBuilder: (context, index) {
                                  return const SizedBox(width: 15);
                                },
                                itemBuilder: (context, index) {
                                  // var course = sameTimeCourses[index];
                                  return ShowCourseCard(
                                    eventId: events[index].evens_list[index].id,
                                    profileUrl: events[index]
                                                .evens_list[index]
                                                .usersDetails
                                                .isEmpty &&
                                            events[index]
                                                .evens_list[index]
                                                .teachersDetails
                                                .isEmpty
                                        ? "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"
                                        : events[index]
                                                .evens_list[index]
                                                .teachersDetails
                                                .isNotEmpty
                                            ? events[index]
                                                .evens_list[index]
                                                .teachersDetails
                                                .first
                                                .profileImage
                                            : events[index]
                                                    .evens_list[index]
                                                    .usersDetails
                                                    .first
                                                    .profileImage ??
                                                "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                                    // course.teachers?[0].imageUrl,
                                    phoneNumber: events[index]
                                        .evens_list[index]
                                        .phoneNumber,
                                    // course.teachers![0].mobileNo!,
                                    // time: eachTime,
                                    time: events[index]
                                        .evens_list[index]
                                        .duration
                                        .first,
                                    teacherName: events[index]
                                                .evens_list[index]
                                                .usersDetails
                                                .isEmpty &&
                                            events[index]
                                                .evens_list[index]
                                                .teachersDetails
                                                .isEmpty
                                        ? "Bhupendra Jogi"
                                        : events[index]
                                                .evens_list[index]
                                                .teachersDetails
                                                .isNotEmpty
                                            ? events[index]
                                                    .evens_list[index]
                                                    .teachersDetails
                                                    .first
                                                    .name ??
                                                "Bhupendra Jogi"
                                            : events[index]
                                                    .evens_list[index]
                                                    .usersDetails
                                                    .first
                                                    .name ??
                                                "Bhupendra Jogi",
                                    // course.teachers![0].name!,
                                    // courseName: course.course!,
                                    courseName:
                                        events[index].evens_list[index].title,
                                    courseID: "course.sId!",
                                    mode: events[index].evens_list[index].mode,
                                    zoomLink: events[index]
                                        .evens_list[index]
                                        .meetingLink,
                                  );
                                }),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
        ],
      ),
    );
  }
}

showBottomSheetHomeScreen(BuildContext context,
    {LatLng? currentPosition, required GlobalKey<ScaffoldState> scaffoldkey}) {
  return scaffoldkey.currentState!.showBottomSheet(
    (context) => FilterBottomSheet(
      currentPosition: currentPosition,
    ),
  );
}
