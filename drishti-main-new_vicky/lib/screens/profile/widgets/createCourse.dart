import 'package:srisridrishti/models/all_events_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../themes/theme.dart';
import '../../../widgets/common_container_button.dart';

class CreateCourse extends StatefulWidget {
  const CreateCourse({super.key, Event? event});

  @override
  _CreateCourseState createState() => _CreateCourseState();
}

class _CreateCourseState extends State<CreateCourse> {
  String selectedCourseName = 'Sudarshan Kriya';
  DateTime fromDate = DateTime(2024, 2, 8);
  DateTime toDate = DateTime(2024, 2, 8);
  List<String> images = [
    'assets/images/yoga_group.jpg',
    'assets/images/yoga_individual.jpg',
  ];
  List<bool> isPublic = [true, true];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Course Details',
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownField('Course Name', selectedCourseName),
            SizedBox(height: 16.sp),
            _buildTextField('Add Teacher', 'Search Teacher Name'),
            SizedBox(height: 16.sp),
            Row(
              children: [
                Expanded(child: _buildDateField('From Date', fromDate)),
                SizedBox(width: 16.sp),
                Expanded(child: _buildDateField('To Date', toDate)),
              ],
            ),
            SizedBox(height: 16.sp),
            ...List.generate(images.length, (index) => _buildImageCard(index)),
            SizedBox(height: 16.sp),
            const CommonContainerButton(
              labelText: 'Save',
              // onPressed: () {
              //   // Implement save functionality
              // },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: Colors.black54,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 8.sp),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.manrope(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.black),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: Colors.black54,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 8.sp),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.manrope(
              textStyle: TextStyle(
                color: Colors.grey,
                fontSize: 16.sp,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.sp),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: Colors.black54,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 8.sp),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Text(
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
            style: GoogleFonts.manrope(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sp),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.sp)),
                child: Image.asset(
                  images[index],
                  width: double.infinity,
                  height: 200.sp,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8.sp,
                right: 8.sp,
                child: GestureDetector(
                  onTap: () {
                    // Implement image removal
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.sp),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 20.sp, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Caption',
                  style: GoogleFonts.manrope(
                    textStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildRadioButton('Public', isPublic[index], (value) {
                      setState(() => isPublic[index] = value!);
                    }),
                    SizedBox(width: 16.sp),
                    _buildRadioButton('Private', !isPublic[index], (value) {
                      setState(() => isPublic[index] = !value!);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioButton(
      String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Radio<bool>(
          value: true,
          groupValue: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
        ),
        Text(
          label,
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
