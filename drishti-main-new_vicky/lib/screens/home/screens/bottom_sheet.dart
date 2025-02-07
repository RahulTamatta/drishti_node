// ignore_for_file: unused_import

import 'package:srisridrishti/bloc/all_event_bloc/all_event_bloc.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_bloc.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_event.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_state.dart';
import 'package:srisridrishti/handler/responses/profile_details_response.dart';
import 'package:srisridrishti/models/all_events_model.dart';
import 'package:srisridrishti/providers/home_provider.dart';
import 'package:srisridrishti/screens/home/screens/all_courses_screen.dart';
import 'package:srisridrishti/screens/home/screens/course_details_screen.dart';
import 'package:srisridrishti/screens/home/widgets/event_shimmer_effect.dart';
import 'package:srisridrishti/screens/home/widgets/home_list_container.dart';
import 'package:srisridrishti/screens/home/widgets/map_widget.dart';
import 'package:srisridrishti/themes/theme.dart';
import 'package:srisridrishti/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenBottomSheet extends StatefulWidget {
  final Position position;
  final String userID;
  final dynamic radius;
  const HomeScreenBottomSheet(
      {super.key,
      required this.position,
      required this.userID,
      required this.radius});

  @override
  State<HomeScreenBottomSheet> createState() => HomeScreenBottomSheetState();
}

class HomeScreenBottomSheetState extends State<HomeScreenBottomSheet> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<AllEventBloc>().add(FetchAllEvents(
            "",
            // widget.position.latitude,
            // widget.position.longitude,
            // widget.radius ?? 5000,
            0.0,
            0.0,
            0,

            "2024-01-26T15:00:00.000Z",
          ));
    });

    super.initState();
  }

  DateTime currentDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final HomeProvider homeProvider = Provider.of(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildAllButton(homeProvider),
                    ...List.generate(10, (index) {
                      DateTime date = DateTime.now().add(Duration(days: index));
                      return InkWell(
                        onTap: () {
                          if (homeProvider.selectedDate != null &&
                              formatDate(homeProvider.selectedDate!) ==
                                  formatDate(date)) {
                            homeProvider.updateSelectedDate(null);
                          } else {
                            homeProvider.updateSelectedDate(date);
                          }
                        },
                        child: _buildDateItem(date, homeProvider),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30.sp,
                    width: 350.sp,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 10),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: kriyaNames.length,
                      itemBuilder: (context, index) {
                        String name = kriyaNames[index];
                        return GestureDetector(
                          onTap: () {
                            if (homeProvider.selectedYoga == name) {
                              homeProvider.selectedYoga = "";
                            } else {
                              homeProvider.selectedYoga = name;
                            }

                            WidgetsBinding.instance
                                .addPostFrameCallback((_) async {
                              context.read<AllEventBloc>().add(FetchAllEvents(
                                    homeProvider.selectedYoga,
                                    widget.position.latitude,
                                    widget.position.longitude,
                                    5000,
                                    "2024-01-26T15:00:00.000Z",
                                  ));
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: homeProvider.selectedYoga == name
                                      ? AppColors.primaryColor
                                      : Colors.grey.withOpacity(0.5)),
                            ),
                            margin: const EdgeInsets.only(right: 10),
                            alignment: Alignment.center,
                            child: Text(
                              kriyaNames[index],
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: homeProvider.selectedYoga == name
                                        ? AppColors.primaryColor
                                        : Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              BlocBuilder<AllEventBloc, AllEventState>(
                builder: (context, state) {
                  if (state is AllEventLoadSuccess) {
                    final events = state.events.data?.data ?? [];

                    if (events == []) {
                      return Center(child: Text("${state.events.message}"));
                    } else {
                      return ListView.builder(
                        itemCount: events.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final EventData res = events[index];
                          // Logger logger = Logger();
                          // logger.d(res.events![index]);
                          if ((res.events?.isNotEmpty ?? false)) {
                            // Check if the date filter is applied
                            if (homeProvider.selectedDate != null) {
                              // Filter events based on the selected date
                              final filteredEvents = res.events!.where((event) {
                                // Parse the dateTo string to DateTime
                                DateTime? eventDate = event.dateTo;
                                if (eventDate == null) return false;
                                return formatDate(eventDate) ==
                                    formatDate(homeProvider.selectedDate!);
                              }).toList();

                              if (filteredEvents.isEmpty) {
                                return const SizedBox();
                              }

                              return _buildEventSection(
                                  context, res, filteredEvents);
                            } else {
                              // Show all events when no date is selected
                              return _buildEventSection(
                                  context, res, res.events!);
                            }
                          }
                          return const SizedBox();
                        },
                      );
                    }
                  } else {
                    return eventShimmerEffect();
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllButton(HomeProvider homeProvider) {
    bool isSelected = homeProvider.selectedDate == null;

    return InkWell(
      onTap: () {
        homeProvider.updateSelectedDate(null);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        width: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: Colors.white,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.black.withOpacity(0.4),
          ),
        ),
        child: Center(
          child: Text(
            'All',
            style: GoogleFonts.manrope(
              textStyle: TextStyle(
                color: isSelected ? AppColors.primaryColor : Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateItem(DateTime date, HomeProvider homeProvider) {
    String formattedDate = formatDate(date);
    String formattedSelectedDate = homeProvider.selectedDate != null
        ? formatDate(homeProvider.selectedDate!)
        : '';

    bool isSelected = formattedDate == formattedSelectedDate;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.white,
        border: Border.all(
          color: isSelected
              ? AppColors.primaryColor
              : Colors.black.withOpacity(0.4),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            DateFormat('EEE').format(date),
            style: GoogleFonts.manrope(
              textStyle: TextStyle(
                color: isSelected ? AppColors.primaryColor : Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            DateFormat('dd').format(date),
            style: GoogleFonts.manrope(
              textStyle: TextStyle(
                color: isSelected ? AppColors.primaryColor : Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSection(
      BuildContext context, EventData res, List<Event> events) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${res.from}",
                style: GoogleFonts.manrope(
                  textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AllCoursesScreen(
                          eventsData: res, userID: widget.userID),
                    ),
                  );
                },
                child: Text(
                  "View All >",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 205,
            child: events.isEmpty
                ? const Center(child: Text('No events available'))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CourseDetailsScreen(
                                  event: event, userID: widget.userID),
                            ),
                          );
                        },
                        child: HomeListViewItem(
                          event: event,
                          userID: widget.userID,
                          position: widget.position,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 5),
        ],
      ),
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
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return null;
    }
  }
}
