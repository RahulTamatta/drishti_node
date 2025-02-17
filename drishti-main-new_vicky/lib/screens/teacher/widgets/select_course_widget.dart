import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/create_event_provider.dart';
import '../../../providers/select_course_provider.dart';

class SelectCourseWidget extends StatefulWidget {
  final String? title;
  const SelectCourseWidget({super.key, this.title});

  @override
  SelectCourseWidgetState createState() => SelectCourseWidgetState();
}

class SelectCourseWidgetState extends State<SelectCourseWidget> {
  String? _selectedCourse;

  final List<String> _courses = [
    'Sudarshan Kriya',
    'Medha Yoga',
    'Utkarsh Yoga',
    'Rudra Pooja',
    'Ganesh Homa',
    'Durga Puja',
  ];

  @override
  void initState() {
    if (widget.title != null) {
      _selectedCourse = widget.title;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final CourseSelectionProvider courseProvider =
        Provider.of<CourseSelectionProvider>(context, listen: false);
    final CreateEventProvider createEventProvider =
        Provider.of<CreateEventProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select Course',
          labelStyle: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        value: _selectedCourse,
        onChanged: (String? newValue) {
          courseProvider.updateCourse(newValue.toString());
          setState(() {
            createEventProvider.createEventModel.title = [newValue!];
            _selectedCourse = newValue;
          });
        },
        items: _courses.map<DropdownMenuItem<String>>((String course) {
          return DropdownMenuItem<String>(
            value: course,
            child: Text(
              course,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
