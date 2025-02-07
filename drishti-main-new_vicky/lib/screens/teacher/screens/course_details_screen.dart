import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/screens/home/widgets/course_details_card.dart';
import 'package:srisridrishti/screens/teacher/screens/edit_meeting.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/all_events_model.dart';
import '../../../themes/theme.dart';

class TeacherCourseDetailsScreen extends StatefulWidget {
  final Event? event;

  final String userID;

  const TeacherCourseDetailsScreen(
      {super.key, required this.event, required this.userID});

  @override
  State<TeacherCourseDetailsScreen> createState() =>
      _TeacherCourseDetailsScreenState();
}

class _TeacherCourseDetailsScreenState
    extends State<TeacherCourseDetailsScreen> {
  //flutter bloc for hiting api

  final TextEditingController _searchController = TextEditingController();
  final List<String> imageUrls = [
    'assets/images/user.png',
    'assets/images/user.png',
    'assets/images/user.png',
    'assets/images/user.png',
  ];

  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  data(context) async {
    String? token = await SharedPreferencesHelper.getAccessToken();
    print("Token: $token");

    dynamic headers = {
      'Authorization': 'Bearer ${token.toString()}'
    }; // Add 'Bearer 'token.toString()};
    // dynamic headers = <String, dynamic>{};
    dynamic body = <String, dynamic>{};
    dynamic path = "/event/deleteEvent/${widget.event!.id}";
    dynamic type = "DELETE";
    apiBloc.add(GetApi(add: body, header: headers, path: path, type: type));

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
              canPop: true, // prevent back
              onPopInvokedWithResult: (bool didPop, Object? result) {
                Navigator.of(context).pop();
              },
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                content: Builder(
                  builder: (context) {
                    return SizedBox(
                      height: 200,
                      width: 200,
                      child: bloc1(),
                    );
                  },
                ),
                insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
              ));
        });
  }

  Widget bloc1() {
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
              // showToast(
              //     text: "Address Created Successfully",
              //     color: Colors.red,
              //     context: context);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Navigator.of(context).pushAndRemoveUntil(
                //     MaterialPageRoute(builder: (context) {
                //   return const BottomNavigationScreen();
                // }), (_) => false);
                Navigator.of(context).pop();
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

  final List<String> teachersName = ["Bhupendra", "Sagar", "Ravi", "Raj"];

  Future<void> _copyToClipboard(String meetingLink) async {
    await Clipboard.setData(ClipboardData(text: meetingLink));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        'Meeting Link Copied.',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: AppColors.primaryColor,
    ));
  }

  Duration calculateTimeLeft(String eventDateTime) {
    DateTime eventDate = DateTime.parse(eventDateTime);
    DateTime currentDate = DateTime.now();
    return eventDate.difference(currentDate);
  }

  String formatDuration(Duration duration) {
    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;

    return '${days}d ${hours}h ${minutes}m';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.height;
    DateTime dateTime = widget.event!.dateFrom!;
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

    Duration timeLeft =
        calculateTimeLeft(widget.event?.dateFrom.toString() ?? '');
    String formattedTimeLeft = formatDuration(timeLeft);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Course Details',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                color: Colors.black,
                overflow: TextOverflow.ellipsis,
                fontSize: width * 0.022,
                fontWeight: FontWeight.w500),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: IconButton(
              icon: const Icon(
                Icons.edit_document,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return EditMeetingScreen(
                          edit: "Edit Meeting", event: widget.event);
                    }),
                  );
                });
                // Add your onPressed code here!
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () {
                // set up the button
                Widget okButton = TextButton(
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    data(context);
                  },
                );

                Widget cancelButton = TextButton(
                  child: const Text(
                    "cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                );

                // set up the AlertDialog
                AlertDialog alert = AlertDialog(
                  title: const Text(
                    "Delete Course",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                      "Are you sure you want to delete this Course?"),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cancelButton,
                        okButton,
                      ],
                    ),
                  ],
                );

                // show the dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );

                // Add your onPressed code here!
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: IconButton(
              icon: const Icon(
                Icons.share,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () {
                // Add your onPressed code here!
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            courseDetailsCard(
              width: width,
              courseName: '${widget.event?.title![0]}',
              courseDate: formattedDate,
              coursetime: '${widget.event?.durationFrom}',
              courseStartsIn: formattedTimeLeft,
              courseMode: '',
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
              child: Text(
                'Teachers',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      color: AppColors.black_333333,
                      fontSize: width * 0.020,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            if (widget.event?.teachersDetails?.isNotEmpty ?? false)
              SizedBox(
                height: 100.0.sp,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.event?.teachersDetails!.length == null
                      ? 0
                      : widget.event!.teachers!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {},
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: width * 0.01),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                  width: 80.0,
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.lightgrey_E0E0E0,
                                      width: 4.0, // Width of the ring
                                    ),
                                  ),
                                ),
                                widget.event!.teachersDetails![index]
                                        .profileImage!.isNotEmpty
                                    ? ClipOval(
                                        child: Image(
                                        image: NetworkImage(widget
                                            .event!
                                            .teachersDetails![index]
                                            .profileImage!),
                                        width: 60.0,
                                        height: 60.0,
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
                              ],
                            ),
                          ),
                          Text(
                            "${widget.event!.teachersDetails![index].name!.isNotEmpty ? widget.event!.teachersDetails![index].name : ''}",
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: AppColors.grey_4F4F4F,
                                  fontSize: width * 0.018,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.02, vertical: 10),
                child: Text(
                  'No teachers assigned to this course.',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: AppColors.grey_4F4F4F,
                      fontSize: width * 0.018,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
              child: Text(
                'Meeting ID',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      color: AppColors.black_333333,
                      fontSize: width * 0.020,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Container(
              height: 45.sp,
              margin: EdgeInsets.symmetric(
                  horizontal: width * 0.02, vertical: width * 0.01),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: AppColors.lightgrey_DEDEDE),
              ),
              child: ListTile(
                title: Text(
                  "${widget.event?.meetingLink}",
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: AppColors.lightgrey_828282,
                        fontSize: width * 0.02,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                trailing: InkWell(
                    onTap: () {
                      _copyToClipboard(widget.event?.meetingLink ?? "");
                    },
                    child: const Icon(
                      Icons.copy,
                      color: AppColors.primaryColor,
                    )),
              ),
            ),
            InkWell(
              onTap: () {
                showSheet(context, width, widget.event);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                margin: EdgeInsets.symmetric(
                    horizontal: width * 0.02, vertical: width * 0.01),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.lightpurple_72B1FF),
                    color: AppColors.lightblue_EBF4FF),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/user.png',
                            width: 44.0,
                            height: 44.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    widget.event!.participantsDetails!.isNotEmpty
                        ? Text(
                            "${widget.event?.participantsDetails?.length}+ Participant",
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: width * 0.017,
                                  fontWeight: FontWeight.w600),
                            ))
                        : Text("No Participants registered yet!",
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: width * 0.017,
                                  fontWeight: FontWeight.w600),
                            )),
                    const Spacer(),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        )),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
              margin: EdgeInsets.symmetric(vertical: width * 0.01),
              child: Text(
                'Course Details',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      color: AppColors.black_333333,
                      fontSize: width * 0.020,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
              child: Text(
                widget.event!.description!,
                style: GoogleFonts.manrope(
                  textStyle: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.black_333333,
                      fontSize: width * 0.017,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  color: Colors.white),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.02, vertical: width * 0.01),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.63,
                          alignment: Alignment.center,
                          height: width * 0.1,
                          child: Text("${widget.event?.address?[0]}",
                              maxLines: 2,
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                    wordSpacing: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: width * 0.017,
                                    fontWeight: FontWeight.w400),
                              )),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            getAddressInMap(
                                widget.event!.location!.coordinates![0],
                                widget.event!.location!.coordinates![1]);
                          },
                          child: Transform.rotate(
                              alignment: Alignment.center,
                              angle: 0.2,
                              child: Image.asset(
                                "assets/images/location_arrow.png",
                                height: 22,
                                width: 22,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    _launchWhatsApp(
                                        '${widget.event?.phoneNumber}',
                                        'Hello, this is a message!');
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.01,
                                        vertical: width * 0.01),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.purple_7D5EFF),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                            "assets/images/whatsapp.png"),
                                        const SizedBox(width: 10),
                                        Text("WhatsApp",
                                            style: GoogleFonts.openSans(
                                              textStyle: TextStyle(
                                                  color: AppColors.black_333333,
                                                  fontSize: width * 0.018,
                                                  fontWeight: FontWeight.w600),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Visibility(
                                  visible:
                                      widget.event!.registrationLink!.isNotEmpty
                                          ? true
                                          : false,
                                  child: InkWell(
                                    onTap: () async {
                                      final Uri url = Uri.parse(
                                          '${widget.event!.registrationLink}');
                                      if (!await launchUrl(url)) {
                                        throw Exception(
                                            'Could not launch $url');
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.01,
                                          vertical: width * 0.01),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.purple_7D5EFF),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Row(
                                        children: [
                                          // Image.asset("assets/images/zoom.png"),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Register",
                                            style: GoogleFonts.openSans(
                                              textStyle: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: width * 0.018,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: widget.event!.meetingLink!
                                          .contains("zoom")
                                      ? true
                                      : false,
                                  child: InkWell(
                                    onTap: () async {
                                      _launchZoom(
                                          widget.event?.meetingLink ?? "");
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.01,
                                          vertical: width * 0.01),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.purple_7D5EFF),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Row(
                                        children: [
                                          Image.asset("assets/images/zoom.png"),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Zoom",
                                            style: GoogleFonts.openSans(
                                              textStyle: TextStyle(
                                                  color: AppColors.black_333333,
                                                  fontSize: width * 0.018,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: () async {
                                    _launchDialpad(
                                        widget.event?.phoneNumber.toString() ??
                                            0.toString());
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.01,
                                        vertical: width * 0.01),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.purple_7D5EFF),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      children: [
                                        Image.asset("assets/images/call.png"),
                                        const SizedBox(width: 10),
                                        Text("Call",
                                            style: GoogleFonts.openSans(
                                              textStyle: TextStyle(
                                                  color: AppColors.black_333333,
                                                  fontSize: width * 0.018,
                                                  fontWeight: FontWeight.w600),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                    const SizedBox(height: 25),
                    widget.event!.notifyTo!.contains(widget.userID)
                        ? _notifyButton(true)
                        : InkWell(
                            onTap: () async {
                              setState(() {
                                bloc(widget.event!.id);
                              });
                            },
                            child: _notifyButton(false),
                          )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _notifyButton(isNotified) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.purple_7D5EFF),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      alignment: Alignment.center,
      child: InkWell(
        onTap: () async {},
        child: RichText(
          text: TextSpan(children: [
            const WidgetSpan(
              child: Icon(
                Icons.notifications,
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
          ]),
        ),
      ),
    );
  }

  void _launchWhatsApp(String phoneNumber, String message) async {
    final Uri whatsappUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: '/$phoneNumber',
      queryParameters: {'text': message},
    );

    launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }

  void _launchZoom(String meetingUrl) async {
    launchUrl(Uri.parse(meetingUrl), mode: LaunchMode.externalApplication);
  }

  void _launchDialpad(String phoneNUmber) {
    launchUrl(Uri.parse("tel://$phoneNUmber"));
  }

  void showSheet(context, width, Event? event) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          if (event!.participantsDetails!.isNotEmpty) {
            return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                color: Colors.white,
                child: Wrap(spacing: 60, children: <Widget>[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 130, vertical: 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: AppColors.lightgrey_BDBDBD),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    alignment: Alignment.topLeft,
                    height: width * 0.06,
                    child: Text(
                        "${event.participantsDetails?.length} Participants Attending",
                        style: GoogleFonts.manrope(
                          textStyle: TextStyle(
                              fontSize: width * 0.02,
                              fontWeight: FontWeight.w600),
                        )),
                  ),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Participants',
                      contentPadding: const EdgeInsets.symmetric(vertical: 3),
                      hintStyle: GoogleFonts.manrope(
                        textStyle: TextStyle(
                            fontSize: width * 0.017,
                            color: AppColors.lightgrey_818181,
                            fontWeight: FontWeight.w400),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: AppColors.lightgrey_818181,
                          size: 19,
                        ),
                        onPressed: () {},
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: width * 2,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: event.participantsDetails?.length,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  event.participantsDetails![index]
                                              .profileImage !=
                                          ""
                                      ? ClipOval(
                                          child: Image(
                                          image: NetworkImage(event
                                              .participantsDetails![index]
                                              .profileImage!),
                                          width: 60.0,
                                          height: 60.0,
                                          fit: BoxFit.cover,
                                        ))
                                      : ClipOval(
                                          child: Image.asset(
                                            "assets/images/user.png",
                                            width: 60.0,
                                            height: 60.0,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ],
                              ),
                              const SizedBox(width: 5),
                              Container(
                                alignment: Alignment.center,
                                height: width * 0.1,
                                child: Text(
                                    "${event.participantsDetails?[index].name}",
                                    style: GoogleFonts.manrope(
                                      textStyle: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: width * 0.015,
                                          fontWeight: FontWeight.w400),
                                    )),
                              ),
                            ],
                          );
                        }),
                  ),
                ]));
          } else {
            return Container(
              width: double.maxFinite,
              height: 100,
              alignment: Alignment.center,
              child: Text("No Participants registered yet!",
                  style: GoogleFonts.manrope(
                    textStyle: TextStyle(
                        fontSize: width * 0.02, fontWeight: FontWeight.w600),
                  )),
            );
          }
        });
  }

  void getAddressInMap(double latitude, double longitude) {
    MapUtils.openMap(latitude, longitude);
  }
}

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
  }
}
