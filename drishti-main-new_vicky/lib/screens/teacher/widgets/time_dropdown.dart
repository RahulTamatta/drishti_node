import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../providers/create_event_provider.dart';

class TimeDropdown extends StatefulWidget {
  final String? durationFrom;

  final dynamic width;
  const TimeDropdown({super.key, this.durationFrom, this.width});

  @override
  TimeDropdownState createState() => TimeDropdownState();
}

class TimeDropdownState extends State<TimeDropdown> {
  List<String> _timeIntervals = [];
  String? _selectedTime;
  String? _selectedTitle;
  List<String> amPm = ['AM', 'PM'];
  @override
  void initState() {
    _timeIntervals = _generateTimeIntervals();
    _selectedTitle = 'AM'; // Set default period
    
    if (widget.durationFrom != null) {
      // Parse existing time if provided
      RegExp exp = RegExp(r'(\d{1,2}):(\d{2})(AM|PM)');
      var match = exp.firstMatch(widget.durationFrom!);
      if (match != null) {
        _selectedTime = '${match.group(1)}:${match.group(2)}';
        _selectedTitle = match.group(3);
      }
    } else {
      _selectedTime = '00:00';
    }
    super.initState();
  }

  List<String> _generateTimeIntervals() {
    List<String> intervals = [];
    for (int hour = 0; hour < 12; hour++) {
      for (int minute = 0; minute < 60; minute += 15) {
        String time =
            "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
        intervals.add(time);
      }
    }
    return intervals;
  }

  void _updateTime(CreateEventProvider provider, String? time, String? amPm) {
    if (time != null && amPm != null) {
      String formattedTime = '$time$amPm';
      provider.updateDurationFrom(formattedTime);
      
      // Ensure duration array is updated whenever time changes
      _updateDuration(provider);
    }
  }

  void _updateDuration(CreateEventProvider provider) {
    if (provider.createEventModel.durationFrom != null && 
        provider.createEventModel.durationTo != null) {
      provider.createEventModel.duration = [{
        'from': _formatTime(provider.createEventModel.durationFrom!),
        'to': _formatTime(provider.createEventModel.durationTo!)
      }];
    }
  }

  String _formatTime(String time) {
    final RegExp exp = RegExp(r'(\d{1,2}):(\d{2})(AM|PM)');
    final match = exp.firstMatch(time);
    
    if (match != null) {
      var hour = int.parse(match.group(1)!);
      final minute = match.group(2)!;
      final period = match.group(3);
      
      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      
      return '${hour.toString().padLeft(2, '0')}:$minute';
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final CreateEventProvider createEventProvider =
        Provider.of<CreateEventProvider>(context, listen: false);

    return Container(
      width: widget.width ?? 170,
      height: 50,
      margin: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: (widget.width - 70) ?? 100,
            height: 50,
            child: DropdownButtonFormField<String>(
              isDense: true,
              value: _selectedTime,
              items: _timeIntervals.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedTime = newValue;
                });
                _updateTime(createEventProvider, _selectedTime, _selectedTitle);
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 14),
                // hintText: 'Select Time',
                labelText: 'Start',
                labelStyle: GoogleFonts.manrope(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 13.sp,
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
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          Container(
            width: 65,
            height: 50,
            margin: const EdgeInsets.only(left: 5),
            child: DropdownButtonFormField<String>(
              isDense: true,
              value: _selectedTitle,
              items: amPm.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedTitle = newValue;
                });
                _updateTime(createEventProvider, _selectedTime, newValue);
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(7),
                // hintText: 'AM',
                // labelText: 'AM',
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
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeDropdown1 extends StatefulWidget {
  final String? durationTo;

  const TimeDropdown1({super.key, this.durationTo});

  @override
  TimeDropdownState1 createState() => TimeDropdownState1();
}

class TimeDropdownState1 extends State<TimeDropdown1> {
  List<String> _timeIntervals = [];
  String? _selectedTime, _selectedTitle;

  List<String> amPm = ['AM', 'PM'];

  @override
  void initState() {
    _timeIntervals = _generateTimeIntervals();
    _selectedTitle = 'AM'; // Set default period
    
    if (widget.durationTo != null) {
      // Parse existing time if provided
      RegExp exp = RegExp(r'(\d{1,2}):(\d{2})(AM|PM)');
      var match = exp.firstMatch(widget.durationTo!);
      if (match != null) {
        _selectedTime = '${match.group(1)}:${match.group(2)}';
        _selectedTitle = match.group(3);
      }
    } else {
      _selectedTime = '00:00';
    }
    super.initState();
  }

  List<String> _generateTimeIntervals() {
    List<String> intervals = [];
    for (int hour = 0; hour < 12; hour++) {
      for (int minute = 0; minute < 60; minute += 15) {
        String time =
            "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
        intervals.add(time);
      }
    }
    return intervals;
  }

  void _updateEndTime(CreateEventProvider provider, String? time, String? amPm) {
    if (time != null && amPm != null) {
      String formattedTime = '$time$amPm';
      provider.updateDurationTo(formattedTime);
      
      // Ensure duration array is updated whenever time changes
      _updateDuration(provider);
    }
  }

  void _updateDuration(CreateEventProvider provider) {
    if (provider.createEventModel.durationFrom != null && 
        provider.createEventModel.durationTo != null) {
      provider.createEventModel.duration = [{
        'from': _formatTime(provider.createEventModel.durationFrom!),
        'to': _formatTime(provider.createEventModel.durationTo!)
      }];
    }
  }

  String _formatTime(String time) {
    final RegExp exp = RegExp(r'(\d{1,2}):(\d{2})(AM|PM)');
    final match = exp.firstMatch(time);
    
    if (match != null) {
      var hour = int.parse(match.group(1)!);
      final minute = match.group(2)!;
      final period = match.group(3);
      
      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      
      return '${hour.toString().padLeft(2, '0')}:$minute';
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final CreateEventProvider createEventProvider = Provider.of<CreateEventProvider>(context, listen: false);

    return Container(
      width: 170,
      height: 50,
      margin: const EdgeInsets.only(left: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            height: 50,
            child: DropdownButtonFormField<String>(
              isDense: true,
              value: _selectedTime,
              items: _timeIntervals.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedTime = newValue;
                });
                _updateEndTime(createEventProvider, newValue, _selectedTitle);
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(7),
                // hintText: 'Select Time',
                labelText: 'End',
                labelStyle: GoogleFonts.manrope(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 13.sp,
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
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          Container(
            width: 65,
            height: 50,
            margin: const EdgeInsets.only(left: 5),
            child: DropdownButtonFormField<String>(
              value: _selectedTitle,
              items: amPm.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedTitle = newValue;
                });
                _updateEndTime(createEventProvider, _selectedTime, newValue);
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(7),
                // hintText: 'AM',
                // labelText: 'AM',
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
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
