import 'package:country_code_picker/country_code_picker.dart';
import 'package:srisridrishti/bloc/create_event_bloc/create_event_bloc.dart';
import 'package:srisridrishti/models/all_events_model.dart';
import 'package:srisridrishti/models/search_user.dart';
import 'package:srisridrishti/providers/create_event_provider.dart';
import 'package:srisridrishti/providers/teacher_provider.dart';
import 'package:srisridrishti/screens/bottom_navigation/bottom_navigation_screen.dart';
import 'package:srisridrishti/screens/teacher/screens/selectLocation.dart';
import 'package:srisridrishti/screens/teacher/screens/teacher_search_screen.dart';
import 'package:srisridrishti/screens/teacher/widgets/course_follow_widget.dart';
import 'package:srisridrishti/screens/teacher/widgets/select_course_widget.dart';
import 'package:srisridrishti/screens/teacher/widgets/time_dropdown.dart';
import 'package:srisridrishti/themes/theme.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding_platform_interface/src/models/placemark.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../widgets/add_icon_button.dart';
import '../../../widgets/common_container_button.dart';
import '../widgets/date_ranger_picker.dart';
import '../widgets/textfield_tags_widget.dart';
import 'package:geolocator/geolocator.dart';

enum OfflineOnlineOption { offline, online }

class EditMeetingScreen extends StatefulWidget {
  final List<Placemark>? addresses;

  final String? edit;

  final Event? event;
  const EditMeetingScreen({super.key, this.addresses, this.edit, this.event});

  @override
  State<EditMeetingScreen> createState() => _EditMeetingScreenState();
}

class _EditMeetingScreenState extends State<EditMeetingScreen> {
  OfflineOnlineOption _selectedOption = OfflineOnlineOption.offline;

  final TextEditingController _meetingIDController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _mapController = TextEditingController();
  final TextEditingController _locationUrlController = TextEditingController();
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _registrationLinkController =
      TextEditingController();

  final List<TextEditingController> _phoneNumberControllers = [
    TextEditingController()
  ];
  List<String> addedTeachers = [];
  List<String> addedTeachersName = [];

  final List<Widget> _phoneNumberFields = [];

  void _addPhoneNumberField() {
    setState(() {
      _phoneNumberFields.add(phoneNumberField(
          UniqueKey(), _phoneNumberControllers[_phoneNumberFields.length]));
    });
  }

  @override
  void initState() {
    _addPhoneNumberField();
    if (widget.addresses != null) {
      String address =
          '${widget.addresses!.first.name!} ${widget.addresses!.first.subLocality!} ${widget.addresses!.first.administrativeArea!} ${widget.addresses!.first.postalCode!}';
      _locationUrlController.text = address;
    }

    if (widget.edit!.isNotEmpty) {
      print("object");
      editMeeting(widget.event!);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    _meetingIDController.dispose();
    _mapController.dispose();
    _locationUrlController.dispose();
    for (var controller in _phoneNumberControllers) {
      controller.dispose();
    }
  }

  bool _validateFields() {
    if (_meetingIDController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationUrlController.text.isEmpty ||
        _mapController.text.isEmpty) {
      return false;
    }
    return true;
  }

  editMeeting(Event event) {
    if (event.durationTo != null) {
      isEnd = true;
      width = 170;
    }
    _selectedOption = event.mode == "online"
        ? OfflineOnlineOption.online
        : OfflineOnlineOption.offline;
    _meetingIDController.text = event.meetingLink!;

    _descriptionController.text = event.description!;
// _mapController.text = event.
    _locationUrlController.text = event.address![0];
    addedTeachers = event.teachers!;
    addedTeachersName =
        event.teachersDetails!.map((name) => name.name!).toList();
    for (int i = 0; i < event.phoneNumber!.length; i++) {
      _phoneNumberControllers[i].text = event.phoneNumber![i];
    }

    _registrationLinkController.text = event.registrationLink!;
  }

  void _submitForm(
      CreateEventProvider createEventProvider, BuildContext mcontext) async {
    // final TeacherProvider teacherProvider =
    //     Provider.of<TeacherProvider>(context, listen: true);
    Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
    if (_validateFields()) {
      String phoneNumber = _phoneNumberControllers
          .map((controller) => controller.text)
          .where((number) => number.isNotEmpty)
          .first;

      createEventProvider.createEventModel.mode = _selectedOption.name;
      createEventProvider.createEventModel.meetingLink =
          _meetingIDController.text;
      createEventProvider.createEventModel.description =
          _descriptionController.text;
      // createEventProvider.createEventModel.phoneNumber = phoneNumbers;
      createEventProvider.createEventModel.registrationLink =
          _registrationLinkController.text;
      createEventProvider.createEventModel.teachers =
          //  [''] +
          addedTeachers;
      // Store coordinates directly without wrapping in a location object
      createEventProvider.createEventModel.coordinates = [
        position.longitude,
        position.latitude
      ];
      createEventProvider.createEventModel.phoneNumber = phoneNumber;
      createEventProvider.createEventModel.address = [
        _locationUrlController.text.toString()
      ];

      createEventProvider.createEventModel.aol = ["course"];
      createEventProvider.createEventModel.timeOffset = "UTC+05:30";
      if (mounted) {
        context.read<CreateEventBloc>().add(CreateEvent(
            event: createEventProvider.createEventModel,
            edit: widget.edit!.isNotEmpty ? widget.edit : "",
            eventId: widget.event!.id!.isNotEmpty ? widget.event!.id! : ""));

        // Navigate to the next screen after submitting

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const BottomNavigationScreen();
        }));
      }
    } else {
      showToast(
          text: "Please fill the details!",
          color: Colors.red,
          context: mcontext);
    }
  }

  bool isEnd = false;
  double width = 250;

  @override
  Widget build(BuildContext context) {
    final CreateEventProvider createEventProvider =
        Provider.of<CreateEventProvider>(context, listen: true);
    final TeacherProvider teacherProvider =
        Provider.of<TeacherProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
        title: Text(
          widget.edit == "Edit Meeting" ? "Edit Meeting" : "Schedule Meeting",
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
                color: Colors.black,
                fontSize: 17.sp,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _customRadioListTile(
                  title: 'Offline',
                  value: OfflineOnlineOption.offline,
                ),
                const SizedBox(width: 10),
                _customRadioListTile(
                  title: 'Online',
                  value: OfflineOnlineOption.online,
                ),
              ],
            ),
            SizedBox(height: 20.sp),
            CourseFollowupEventWidget(aol: widget.event!.aol),
            SizedBox(height: 20.sp),
            SelectCourseWidget(title: widget.event!.title![0]),
            SizedBox(height: 13.sp),
            MyDateRangePicker(
                sDate: widget.event!.dateFrom, eDate: widget.event!.dateTo),
            SizedBox(height: 13.sp),
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TimeDropdown(
                      durationFrom: widget.event!.durationFrom, width: width),
                  Visibility(
                      visible: !isEnd,
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: GestureDetector(
                          onTap: () {
                            width = 170;
                            isEnd = true;
                            setState(() {});
                          },
                          child: addIconButton(),
                        ),
                      )),
                  Visibility(
                      visible: isEnd,
                      child:
                          TimeDropdown1(durationTo: widget.event!.durationTo)),
                ]),
            SizedBox(height: 13.sp),
            _textFieldWidget(_meetingIDController, "Meeting ID",
                labelColor: AppColors.primaryColor),
            SizedBox(height: 13.sp),
            _textFieldWidget(_descriptionController, "Add Description"),
            SizedBox(height: 20.sp),
            Text(
              "Add Address",
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 13.sp),
            // _textFieldWidget(_locationUrlController, "Enter Location"),
            _textFieldWidgetLoc(_locationUrlController, "Enter Location"),
            SizedBox(height: 13.sp),
            _textFieldWidget(_mapController, "Add Map URL",
                labelColor: AppColors.primaryColor, suffixIcon: Icons.link),
            SizedBox(height: 20.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Enter Mobile Number",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500),
                    )),
                InkWell(
                    onTap: () {
                      _addPhoneNumberField();
                    },
                    child: addIconButton())
              ],
            ),
            SizedBox(height: 13.sp),
            ..._phoneNumberFields,
            textFieldWithTagsWidget(
              onTap: () {
                showModalBottomSheet<void>(
                    isDismissible: true,
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                          height: 600,
                          color: Colors.white,
                          child: TeacherSearchScreen());
                    });
                // });
              },
              _teacherNameController,
              'Add Teachers',
              userName: teacherProvider.searchTeacher!.userName != null
                  // &&
                  //         addedTeachers.isNotEmpty
                  ? teacherProvider.searchTeacher!.userName!
                  : "",
              onTagAdded: (teacher) {
                setState(() {
                  addedTeachers.add(teacherProvider.searchTeacher!.id!);

                  addedTeachersName
                      .add(teacherProvider.searchTeacher!.userName!);
                  teacherProvider.searchTeacher =
                      TData(id: "", userName: "", email: "", teacherId: "");
                });
              },
              addedTeachers: addedTeachersName,
            ),
            SizedBox(height: 6.sp),
            _textFieldWidget(_registrationLinkController, "Registration Link",
                labelColor: AppColors.primaryColor),
            SizedBox(height: 20.sp),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      // Navigate back when Cancel is pressed
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.sp),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: AppColors.primaryColor)),
                      alignment: Alignment.center,
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.manrope(
                          textStyle: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const SizedBox(width: 20),
                Expanded(
                  child: BlocBuilder<CreateEventBloc, CreateEventState>(
                    builder: (context, state) {
                      return InkWell(
                          onTap: () {
                            _submitForm(createEventProvider, context);
                          },
                          child: state is CreatingEventWait
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  ),
                                )
                              : const CommonContainerButton(
                                  labelText: "Submit"));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _customRadioListTile({
    required String title,
    required OfflineOnlineOption value,
  }) {
    return SizedBox(
      width: 102.sp,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedOption = value;
              });
            },
            child: Container(
              width: 20.sp,
              height: 20.sp,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: _selectedOption == value
                  ? Container(
                      color: AppColors.primaryColor,
                      child: Icon(
                        Icons.check,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.manrope(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textFieldWidget(TextEditingController controller, String hintText,
      {IconData? prefixIcon,
      String? Function(String?)? validator,
      Color? labelColor,
      IconData? suffixIcon}) {
    return TextFormField(
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
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 17.sp,
                color: Colors.grey.withOpacity(0.4),
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Icon(
                suffixIcon,
                size: 18.sp,
                color: Colors.grey.withOpacity(0.7),
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(6),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _textFieldWidgetLoc(TextEditingController controller, String hintText,
      {IconData? prefixIcon,
      String? Function(String?)? validator,
      Color? labelColor,
      IconData? suffixIcon}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onTap: () async {
        // Navigate to Select Location page
        final selectedLocation = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SelectLocationScreen()),
        );

        if (selectedLocation != null) {
          setState(() {
            _locationUrlController.text =
                selectedLocation; // Set the selected location
          });
        }
      },
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
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 17.sp,
                color: Colors.grey.withOpacity(0.4),
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Icon(
                suffixIcon,
                size: 18.sp,
                color: Colors.grey.withOpacity(0.7),
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(6),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  var selectedCountryCode = "";

  phoneNumberField(key, dynamic phoneController) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                CountryCodePicker(
                  onChanged: (countryCode) {
                    setState(() {
                      selectedCountryCode = countryCode.dialCode!;
                    });
                  },
                  initialSelection: 'IN',
                  favorite: const ['+91', 'US'],
                  showFlag: true,
                  showFlagDialog: true,
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  textStyle: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Container(height: 24.h, width: 1.w, color: Colors.grey),
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    onChanged: (valule) {},
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8.0),
                      hintText: '',
                      hintStyle: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  ),
                ),
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.remove, color: Colors.white, size: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
