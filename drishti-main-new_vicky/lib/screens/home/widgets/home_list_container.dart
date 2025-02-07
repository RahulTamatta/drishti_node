import 'dart:convert';

import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/all_events_model.dart';
import '../../../providers/home_provider.dart';
import '../../../themes/theme.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';
import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import '../../../bloc_latest/bloc/bloc_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:math' show cos, pi, sin, acos;

class HomeListViewItem extends StatefulWidget {
  final Event? event;
  final String userID;
  final Position position;
  const HomeListViewItem(
      {super.key,
      required this.event,
      required this.userID,
      required this.position});

  @override
  State<HomeListViewItem> createState() => _HomeListViewItemState();
}

class _HomeListViewItemState extends State<HomeListViewItem> {
  ApiBloc apiBloc = ApiBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final HomeProvider homeProvider =
        Provider.of<HomeProvider>(context, listen: true);

    DateTime dateFrom = widget.event!.dateFrom!.toLocal();
    DateTime dateTo = widget.event!.dateTo!.toLocal();

    bool isDateSelected = false;
    if (homeProvider.selectedDate != null) {
      isDateSelected =
          isDateInRange(homeProvider.selectedDate!, dateFrom, dateTo);
    }

    if (homeProvider.selectedYoga.isEmpty &&
        homeProvider.selectedDate == null) {
      return _containerWidget();
    } else if (homeProvider.selectedDate != null &&
        homeProvider.selectedYoga.isNotEmpty) {
      if (widget.event!.title![0] == homeProvider.selectedYoga &&
          isDateSelected) {
        return _containerWidget();
      } else {
        return const SizedBox();
      }
    } else if (homeProvider.selectedYoga.isNotEmpty &&
        homeProvider.selectedDate == null) {
      if (widget.event!.title![0] == homeProvider.selectedYoga) {
        return _containerWidget();
      } else {
        return const SizedBox();
      }
    } else if (homeProvider.selectedDate != null &&
        homeProvider.selectedYoga.isEmpty) {
      if (isDateSelected) {
        return _containerWidget();
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }

  Widget _containerWidget() {
    return Container(
      width: 300.sp,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.black.withOpacity(0.6),
        ),
      ),
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.event?.teachersDetails?.isNotEmpty == true
                  ? (widget.event!.teachersDetails![0].profileImage!.isNotEmpty
                      ? ClipOval(
                          child: Image(
                          image: NetworkImage(
                              widget.event!.teachersDetails![0].profileImage!),
                          width: 50.0,
                          height: 50.0,
                          fit: BoxFit.cover,
                        ))
                      : ClipOval(
                          child: Image.asset(
                            'assets/images/user.png',
                            width: 50.0,
                            height: 50.0,
                            fit: BoxFit.cover,
                          ),
                        ))
                  : ClipOval(
                      child: Image.asset(
                        'assets/images/user.png',
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      ),
                    ),
              const SizedBox(width: 15),
              Flexible(
                child: Text(
                  widget.event?.teachersDetails?.isNotEmpty == true
                      ? "${widget.event!.teachersDetails![0].name} "
                      : "No teacher",
                  style: GoogleFonts.manrope(
                    textStyle: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(
                  "${widget.event!.teachersDetails!.length > 1 ? "+" : ""}${widget.event!.teachersDetails!.length > 1 ? widget.event!.teachersDetails!.length - 1 : ""}",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEB),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.event?.title![0]}",
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: const Color(0xfff511d1d),
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 5),
                          RichText(
                              text: TextSpan(children: [
                            const WidgetSpan(
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: Color(0xfff511d1d),
                              ),
                            ),
                            TextSpan(
                              text:
                                  "${widget.event?.participantsDetails?.length ?? 0} Participants",
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                    color: const Color(0xfff511d1d),
                                    fontSize: 12.sp,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          ])),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          const WidgetSpan(
                            child: Icon(
                              Icons.note_alt_outlined,
                              size: 18,
                              color: Color(0xfff511d1d),
                            ),
                          ),
                          TextSpan(
                            text: "Courses",
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                  color: const Color.fromARGB(255, 81, 29, 29),

                                  //  const Color(0xfff511d1d),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ])),
                        const SizedBox(height: 5),
                        RichText(
                            text: TextSpan(children: [
                          const WidgetSpan(
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: Color(0xfff511d1d),
                            ),
                          ),
                          TextSpan(
                            text: "Follow up",
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                  color: const Color(0xfff511d1d),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ])),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryColor)),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primaryColor,
                      ),
                      Text(
                        "${distance(widget.position.latitude, widget.position.longitude, widget.event!.location!.coordinates![0], widget.event!.location!.coordinates![1], 'K')}KM",
                        style: TextStyle(
                            color: AppColors.primaryColor, fontSize: 14.sp),
                      )
                    ],
                  )),
              // Always use _notifyButton() directly
              _notifyButton(),
            ],
          )
        ],
      ),
    );
  }

  Future<Widget> bloc() async {
    String? token = await SharedPreferencesHelper.getAccessToken();
    print("Token: $token");

    dynamic headers = {
      'Authorization': 'Bearer ${token.toString()}'
    }; // Add 'Bearer 'token.toString()};
    apiBloc.add(NotifyMe(id: widget.event!.id, header: headers));
    return BlocProvider(
      create: (_) => apiBloc,
      child: BlocListener<ApiBloc, BlocState>(
        listener: (context, state) {
          if (state is Error) {
            showToast(
                text: state.message!, color: Colors.red, context: context);
          }
        },
        child: BlocBuilder<ApiBloc, BlocState>(
          builder: (context, state) {
            if (state is Initial) {
              return buildLoading();
            } else if (state is Loading) {
              return Container(child: buildLoading());
            } else if (state is Loaded) {
              // dynamic add = state.data;

              // print(add);

              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return WillPopScope(
                        onWillPop: () {
                          Navigator.of(context).pop();
                          return Future.value(false);
                        },
                        child: AlertDialog(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          content: Builder(
                            builder: (context) {
                              return const SizedBox(
                                height: 200,
                                width: 200,
                              );
                            },
                          ),
                          insetPadding: EdgeInsets.zero,
                          contentPadding: EdgeInsets.zero,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                        ));
                  });

              return Container();
            } else if (state is Error) {
              return Container();
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

// unit = the unit you desire for results
//       where: 'M' is statute miles (default)
//              'K' is kilometers
//              'N' is nautical miles
  String distance(
      double lat1, double lon1, double lat2, double lon2, String unit) {
    // print("$lat1  $lon1  $lat2  $lon2  $unit");
    double theta = lon1 - lon2;
    double dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));
    dist = acos(dist);
    dist = rad2deg(dist);
    dist = dist * 60 * 1.1515;
    if (unit == 'K') {
      dist = dist * 1.609344;
    } else if (unit == 'N') {
      dist = dist * 0.8684;
    }
    return (dist).toStringAsFixed(0);
  }

  double deg2rad(double deg) {
    return (deg * pi / 180.0);
  }

  double rad2deg(double rad) {
    return (rad * 180.0 / pi);
  }

  Widget _notifyButton() {
    return InkWell(
      onTap: () async {
        try {
          String? token = await SharedPreferencesHelper.getAccessToken();
          final response = await http.post(
            Uri.parse(
                'http://10.0.2.2:8080/notifications/subscribe/${widget.event!.id}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
          );

          if (response.statusCode == 200) {
            final responseBody = json.decode(response.body);
            final bool isSubscribed =
                responseBody['data']['isOneHourReminder'] != null;
            print("signsit$isSubscribed");
            // Update state inside a single setState call
            setState(() {
              if (isSubscribed) {
                // Add user ID if not already present
                if (!widget.event!.notifyTo!.contains(widget.userID)) {
                  widget.event!.notifyTo!.add(widget.userID);
                }
              } else {
                // Remove user ID if present (unsubscribe)
                widget.event!.notifyTo!.remove(widget.userID);
              }
            });

            // Show a snackbar confirming the action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isSubscribed
                    ? 'Subscribed to notifications'
                    : 'Unsubscribed from notifications'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            // Handle server error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Failed to toggle notifications: ${response.body}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          // Handle network or parsing errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Icon(
                  Icons.notifications,
                  color: widget.event!.notifyTo!.contains(widget.userID)
                      ? AppColors.primaryColor
                      : AppColors.white,
                ),
              ),
              TextSpan(
                text: widget.event!.notifyTo!.contains(widget.userID)
                    ? "Notification On"
                    : "Notify Me",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: widget.event!.notifyTo!.contains(widget.userID)
                        ? AppColors.primaryColor
                        : AppColors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // timePicker() async {
  //   TimeOfDay initialTime = TimeOfDay.now();
  //   TimeOfDay? pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: initialTime,
  //     builder: (BuildContext context, Widget child) {
  //       return Directionality(
  //         textDirection: TextDirection.rtl,
  //         child: child,
  //       );
  //     },
  //   );

  // }

  bool isDateInRange(
      DateTime selectedDate, DateTime dateFrom, DateTime dateTo) {
    DateTime selectedDateOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    DateTime dateFromOnly =
        DateTime(dateFrom.year, dateFrom.month, dateFrom.day);
    DateTime dateToOnly = DateTime(dateTo.year, dateTo.month, dateTo.day);
    return selectedDateOnly
            .isAfter(dateFromOnly.subtract(const Duration(days: 1))) &&
        selectedDateOnly.isBefore(dateToOnly.add(const Duration(days: 1)));
  }
}
