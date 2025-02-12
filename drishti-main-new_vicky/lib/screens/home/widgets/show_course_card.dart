import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/create_course_model.dart';
import '../../../themes/theme.dart';

class ShowCourseCard extends StatefulWidget {
  String? eventId;
  final String teacherName;
  final String phoneNumber;
  final String courseName;
  final String courseID;
  final String? zoomLink;
  final String? lati;
  final String? longi;
  final String mode;
  final String time;
  final Location? location;
  final String? profileUrl;

  ShowCourseCard({
    super.key,
    required this.teacherName,
    required this.time,
    required this.courseName,
    required this.courseID,
    this.zoomLink,
    this.lati,
    this.longi,
    this.location,
    required this.mode,
    required this.phoneNumber,
    required this.profileUrl,
    this.eventId,
  });

  @override
  State<ShowCourseCard> createState() => _ShowCourseCardState();
}

class _ShowCourseCardState extends State<ShowCourseCard> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 205,
      // constraints: BoxConstraints(maxWidth: 200, maxHeight: 250),
      // width: 195,
      // height: 160,

      decoration: BoxDecoration(
        color: AppColors.cardBgColor,
        // color: Color(0xffD9D9D9).withOpacity(0.28),
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        onTap: () {
          if (widget.eventId != null) {
            // Navigator.push(context, MaterialPageRoute(
            //   builder: (context) {
            //     return EventDetailsScreen(
            //       eventId: widget.eventId!,
            //       teacherName: widget.teacherName,
            //     );
            //   },
            // ));
          }
        },
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(right: 6, top: 5),
                child: Row(
                  children: [
                    Spacer(),
                    Text(
                      "500 m",
                      style: TextStyle(color: Color(0xffE3D0EF), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            //TODO:
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Distance

                  //profile image

                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        widget.profileUrl == null
                            ? "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"
                            : widget.profileUrl!,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  //name of teacher
                  Expanded(
                    child: Text(
                      widget.teacherName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontFamily: "Poppins",
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SizedBox(
            //   height: 5,
            // ),
            //Course name as tag below
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Text(
                widget.courseName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    color: AppColors.black),
              ),
            ),
            //

            const SizedBox(height: 5),

            //course time
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.courseBgColor),
                    child: const Text(
                      "Course",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.courseBgColor),
                    child: const Text(
                      "Follow-up",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //below row will contain icons of call message notification
            const SizedBox(height: 15),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
              child: Material(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () async {
                    String userId = "ss";
                    setState(() {
                      isTapped = true;
                    });
                    // sendNotification();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isTapped ? "Notified!" : "Notify Me",
                        style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      Image.asset(
                        "assets/images/notification.png",
                        color: Colors.white,
                        height: 18,
                        width: 18,
                      )
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _sendSMS(String phoneNumber, {String? message}) async {
    var url = 'sms:$phoneNumber';

    if (message != null) {
      url += '?body=${Uri.encodeQueryComponent(message)}';
    }
    if (await canLaunch(Uri.parse(url).toString())) {
      await launch(Uri.parse(url).toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  //call
  void _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';

    if (await canLaunch(Uri.parse(url).toString())) {
      await launch(Uri.parse(url).toString());
    } else {
      throw 'Could not launch $url';
    }
  }
}
