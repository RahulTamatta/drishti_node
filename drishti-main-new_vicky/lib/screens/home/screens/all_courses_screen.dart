import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/screens/home/screens/course_details_screen.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/all_events_model.dart';
import '../../../themes/theme.dart';

class AllCoursesScreen extends StatefulWidget {
  final EventData? eventsData;
  final String userID;
  const AllCoursesScreen(
      {super.key, required this.eventsData, required this.userID});

  @override
  State<AllCoursesScreen> createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen> {
  ApiBloc apiBloc = ApiBloc();
  Future<Widget> bloc(id) async {
    String? token = await SharedPreferencesHelper.getAccessToken();
    print("Token: $token");

    dynamic headers = {
      'Authorization': 'Bearer ${token.toString()}'
    }; // Add 'Bearer 'token.toString()};
    apiBloc.add(NotifyMe(id: id, header: headers));
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
                    return PopScope(
                        canPop: false, // prevent back
                        onPopInvokedWithResult: (bool didPop, Object? result) {
                          Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    print(widget.eventsData!.from);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          "All Courses",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 10),
            Text(
              widget.eventsData!.from == ''
                  ? ''
                  : widget.eventsData!.from.toString(),
              style: GoogleFonts.manrope(
                textStyle: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.grey_4F4F4F,
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.eventsData!.events!.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final Event? event = widget.eventsData?.events?[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return CourseDetailsScreen(
                              event: event, userID: widget.userID);
                        }));
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 25.0),
                          child: Container(
                            width: 260.sp,
                            padding: const EdgeInsets.all(15),
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
                                SizedBox(
                                  height: 100.0.sp,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(left: 12),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: event?.teachers?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {},
                                        child: Column(
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 80.0,
                                                  height: 80.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: AppColors
                                                          .lightgrey_E0E0E0,
                                                      width:
                                                          4.0, // Width of the ring
                                                    ),
                                                  ),
                                                ),
                                                event!
                                                        .teachersDetails![index]
                                                        .profileImage!
                                                        .isNotEmpty
                                                    ? ClipOval(
                                                        child: Image(
                                                        image: NetworkImage(event
                                                            .teachersDetails![
                                                                index]
                                                            .profileImage!),
                                                        width: 60.0,
                                                        height: 60.0,
                                                        fit: BoxFit.cover,
                                                      ))
                                                    : ClipOval(
                                                        child: Image.asset(
                                                          'assets/images/user.png',
                                                          width: 60.0,
                                                          height: 60.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                              ],
                                            ),
                                            Flexible(
                                              child: Text(
                                                "${event.teachersDetails?[index].name}",
                                                style: GoogleFonts.lato(
                                                  textStyle: const TextStyle(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      color:
                                                          AppColors.grey_4F4F4F,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.maxFinite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEB),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${event?.title![0]}",
                                                  style: GoogleFonts.manrope(
                                                    textStyle: TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        color: const Color(
                                                            0xfff511d1d),
                                                        fontSize: 15.sp,
                                                        fontWeight:
                                                            FontWeight.w700),
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
                                                        "${event?.participantsDetails?.length} Participants",
                                                    style: GoogleFonts.manrope(
                                                      textStyle: TextStyle(
                                                          color: const Color(
                                                              0xfff511d1d),
                                                          fontSize: 12.sp,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontWeight:
                                                              FontWeight.w500),
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
                                                        color: const Color(
                                                            0xfff511d1d),
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500),
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
                                                        color: const Color(
                                                            0xfff511d1d),
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //       borderRadius:
                                    //           BorderRadius.circular(4),
                                    //       border: Border.all(
                                    //           color: AppColors.primaryColor),
                                    //       color: Colors.white),
                                    //   padding: const EdgeInsets.symmetric(
                                    //       horizontal: 35, vertical: 10),
                                    //   alignment: Alignment.center,
                                    //   child: RichText(
                                    //       text: TextSpan(children: [
                                    //     const WidgetSpan(
                                    //       child: Icon(
                                    //         Icons.location_on_outlined,
                                    //         size: 18,
                                    //         color: AppColors.primaryColor,
                                    //       ),
                                    //     ),
                                    //     TextSpan(
                                    //       text: "${event?.distanceInKilometers}"
                                    //                   .length >
                                    //               4
                                    //           ? "${"${event?.distanceInKilometers}".substring(0, 4)}..."
                                    //           : "${event?.distanceInKilometers}",
                                    //       style: GoogleFonts.poppins(
                                    //         textStyle: TextStyle(
                                    //           overflow: TextOverflow.ellipsis,
                                    //           color: AppColors.primaryColor,
                                    //           fontSize: 14.sp,
                                    //           fontWeight: FontWeight.w600,
                                    //         ),
                                    //       ),
                                    //     )
                                    //   ])),
                                    // ),

                                    InkWell(
                                      onTap: () async {
                                        bloc(event!.id);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: AppColors.primaryColor),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 10),
                                        alignment: Alignment.center,
                                        child: RichText(
                                            text: TextSpan(children: [
                                          const WidgetSpan(
                                            child: Icon(
                                              Icons.notification_add_rounded,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextSpan(
                                            text: " Notify Me",
                                            style: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  letterSpacing: 1,
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )
                                        ])),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
