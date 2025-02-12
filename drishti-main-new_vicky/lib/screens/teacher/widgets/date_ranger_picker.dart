import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

import '../../../models/create_event_model.dart';
import '../../../providers/create_event_provider.dart';
import '../../../themes/theme.dart';
import '../../../widgets/add_icon_button.dart';

class MyDateRangePicker extends StatefulWidget {
  final dynamic sDate;

  final dynamic eDate;

  const MyDateRangePicker({super.key, this.sDate, this.eDate});

  @override
  MyDateRangePickerState createState() => MyDateRangePickerState();
}

class MyDateRangePickerState extends State<MyDateRangePicker> {
  TextEditingController endDateController = TextEditingController();
  TextEditingController startDateController = TextEditingController();

  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now().add(const Duration(days: 2));

  @override
  void initState() {
    // selectedStartDate = widget.sDate;
    // selectedEndDate = widget.eDate;
    if (widget.sDate != null) {
      startDateController.text = Jiffy.parseFromDateTime(widget.sDate).yMMMd;
    }
    if (widget.eDate != null) {
      isEnd = true;
      width = 170;
      endDateController.text = Jiffy.parseFromDateTime(widget.eDate).yMMMd;
    }
    super.initState();
  }

  bool isEnd = false;
  double width = 250;
  @override
  Widget build(BuildContext context) {
    final CreateEventProvider createEventProvider =
        Provider.of<CreateEventProvider>(context, listen: false);
    return Row(
      children: [
        _textFieldWidget(startDateController, "Start Date",
            suffixIcon: Icons.calendar_month, onTap: () {
          _selectStartDate(context, createEventProvider);
        }),
        SizedBox(width: 10.sp),
        Visibility(
            visible: !isEnd,
            child: GestureDetector(
              onTap: () {
                width = 170;
                isEnd = true;
                setState(() {});
              },
              child: addIconButton(),
            )),
        Visibility(
          visible: isEnd,
          child: _textFieldWidget(endDateController, "End Date",
              suffixIcon: Icons.calendar_month, onTap: () {
            _selectEndDate(context, createEventProvider);
          }),
        ),
      ],
    );
  }

  Future<void> _selectStartDate(
      BuildContext context, CreateEventProvider createEventProvider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: selectedStartDate,
      lastDate: DateTime(2042),
    );
    if (picked != null && picked != selectedStartDate) {
      startDateController.text = Jiffy.parseFromDateTime(picked).yMMMd;
      setState(() {
        selectedStartDate = picked;
      });
      EventDateTime eventDateTime =
          createEventProvider.createEventModel.date ?? EventDateTime();
      eventDateTime.from = selectedStartDate.toIso8601String();
      createEventProvider.updateDate(eventDateTime);
    }
  }

  Future<void> _selectEndDate(
      BuildContext context, CreateEventProvider createEventProvider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate,
      firstDate: selectedStartDate,
      lastDate: DateTime(2040),
    );
    if (picked != null && picked != selectedEndDate) {
      endDateController.text = Jiffy.parseFromDateTime(picked).yMMMd;
      setState(() {
        selectedEndDate = picked;
      });
      EventDateTime eventDateTime =
          createEventProvider.createEventModel.date ?? EventDateTime();
      eventDateTime.to = selectedEndDate.toIso8601String();
      createEventProvider.updateDate(eventDateTime);
    }
  }

  Widget _textFieldWidget(TextEditingController controller, String hintText,
      {String? Function(String?)? validator,
      VoidCallback? onTap,
      Color? labelColor,
      IconData? suffixIcon}) {
    return SizedBox(
        width: width,
        child: TextFormField(
          controller: controller,
          validator: validator,
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: labelColor != null ? AppColors.primaryColor : Colors.black,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(14),
            hintText: hintText,
            labelText: hintText,
            labelStyle: GoogleFonts.manrope(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            fillColor: Colors.white,
            filled: true,
            hintStyle: GoogleFonts.manrope(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            // prefixIcon: prefixIcon != null
            //     ? Icon(
            //         prefixIcon,
            //         size: 17.sp,
            //         color: Colors.grey.withOpacity(0.4),
            //       )
            //     : null,
            // suffixIcon: suffixIcon != null
            //     ? Icon(
            //         suffixIcon,
            //         size: 18.sp,
            //         color: Colors.grey.withOpacity(0.7),
            //       )
            //     : null,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12),
              borderRadius: BorderRadius.circular(6),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onTap: onTap,
          readOnly: true,
        ));
  }
}
