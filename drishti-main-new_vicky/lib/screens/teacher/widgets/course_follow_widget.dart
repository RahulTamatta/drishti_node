import 'package:srisridrishti/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/create_event_provider.dart';

// Define an enum for the options
enum Option { courses, followup, events }

class CourseFollowupEventWidget extends StatefulWidget {
  final List<String>? aol;
  const CourseFollowupEventWidget({super.key, this.aol});

  @override
  CourseFollowupEventWidgetState createState() =>
      CourseFollowupEventWidgetState();
}

class CourseFollowupEventWidgetState extends State<CourseFollowupEventWidget> {
  Option _selectedOption = Option.courses;

  @override
  void initState() {
    if (widget.aol != null) {
      _selectedOption = widget.aol![0] == "followup"
          ? Option.followup
          : widget.aol![0] == "events "
              ? Option.events
              : Option.courses;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final CreateEventProvider createEventProvider =
        Provider.of<CreateEventProvider>(context, listen: false);
    return Row(
      children: [
        _containerWidget(Option.courses, "Courses", createEventProvider),
        _containerWidget(Option.followup, "Follow up", createEventProvider),
        _containerWidget(Option.events, "Events", createEventProvider),
      ],
    );
  }

  Widget _containerWidget(
      Option option, String text, CreateEventProvider createEventProvider) {
    bool isSelected = _selectedOption == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          createEventProvider.createEventModel.aol = [text.toString()];
          _selectedOption = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.sp),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
        ),
        margin: const EdgeInsets.only(right: 10),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
