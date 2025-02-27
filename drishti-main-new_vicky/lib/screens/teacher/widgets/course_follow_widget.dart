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
  String? selectedAOL;

  final List<String> aolTypes = ["event", "course", "follow-up", "wellness"];

  @override
  void initState() {
    if (widget.aol != null) {
      selectedAOL = widget.aol![0];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final createEventProvider = Provider.of<CreateEventProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Event Type *", // Added asterisk to indicate required field
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 10.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: aolTypes.map((type) {
            bool isSelected = selectedAOL == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAOL = type;
                  // Update the provider with the selected AOL type
                  createEventProvider.updateAol([type]);
                });
              },
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: GoogleFonts.manrope(
                    textStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
