import 'package:country_code_picker/country_code_picker.dart';
import 'package:srisridrishti/bloc/create_event_bloc/create_event_bloc.dart';
import 'package:srisridrishti/models/search_user.dart';
import 'package:srisridrishti/providers/create_event_provider.dart';
import 'package:srisridrishti/providers/location_provider.dart';
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
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../widgets/add_icon_button.dart';
import '../../../widgets/common_container_button.dart';
import '../widgets/date_ranger_picker.dart';
import '../widgets/textfield_tags_widget.dart';

enum OfflineOnlineOption { offline, online }

class ScheduleMeetingScreen extends StatefulWidget {
  const ScheduleMeetingScreen({super.key});

  @override
  State<ScheduleMeetingScreen> createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  Set<OfflineOnlineOption> _selectedOption = {}; // Changed to a Set

  final TextEditingController _meetingIDController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _mapController = TextEditingController();
  final TextEditingController _locationUrlController = TextEditingController();
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _registrationLinkController = TextEditingController();

  final List<TextEditingController> _phoneNumberControllers = [TextEditingController()];
  List<String> addedTeachers = [];
  List<String> addedTeachersName = [];

  final List<Widget> _phoneNumberFields = [];

  int count = 0;

<<<<<<< HEAD
<<<<<<< HEAD
  @override
  void initState() {
    super.initState();
    _addPhoneNumberField();
    
    // Initialize providers with nullable fields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final createEventProvider = Provider.of<CreateEventProvider>(context, listen: false);
      
      // Initialize event model with null values for optional fields
      createEventProvider.createEventModel;
    });
  }

=======
>>>>>>> parent of 283b956a (latest update .create course is remaining)
=======
>>>>>>> parent of 283b956a (latest update .create course is remaining)
  void _addPhoneNumberField() {
    setState(() {
      _phoneNumberControllers.add(TextEditingController());
      _phoneNumberFields.add(phoneNumberField(
        UniqueKey(),
        _phoneNumberControllers[_phoneNumberControllers.length - 1],
      ));
    });
  }

  @override
  void initState() {
    _addPhoneNumberField();

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

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
  void _submitForm(
      CreateEventProvider createEventProvider, BuildContext mcontext) async {
    final addressProvider =
        Provider.of<AddressProvider>(context, listen: false);
    final lat = addressProvider.latitude;
    final lng = addressProvider.longitude;

    if (!_validateFields()) {
      showToast(
        text: "Please fill all required fields",
        color: Colors.red,
        context: mcontext,
      );
      return;
=======
=======
>>>>>>> parent of 283b956a (latest update .create course is remaining)
  bool _validateFields() {
    if (_meetingIDController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationUrlController.text.isEmpty ||
        _mapController.text.isEmpty) {
      return false;
<<<<<<< HEAD
>>>>>>> parent of 283b956a (latest update .create course is remaining)
=======
>>>>>>> parent of 283b956a (latest update .create course is remaining)
    }
    return true;
  }

  void _submitForm(
      CreateEventProvider createEventProvider, BuildContext mcontext) async {
    final AddressProvider addressProvider =
        Provider.of<AddressProvider>(context, listen: true);

    if (_validateFields()) {
      List<String> phoneNumbers =
          _phoneNumberControllers.map((controller) => controller.text).toList();

<<<<<<< HEAD
<<<<<<< HEAD
    if (phoneNumber == null) {
      showToast(
        text: "Please enter at least one phone number",
=======

void _submitForm(CreateEventProvider createEventProvider, BuildContext mcontext) async {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final lat = addressProvider.latitude;
    final lng = addressProvider.longitude;

    if (!_validateFields()) {
      showToast(
        text: "Please fill all required fields",
>>>>>>> parent of f9353431 (bug)
        color: Colors.red,
        context: mcontext,
      );
      return;
    }

<<<<<<< HEAD
    try {
      createEventProvider.createEventModel.aol = ['course'];
      createEventProvider.createEventModel.mode =
          _selectedOption.map((option) => option.name).join(',');
      createEventProvider.createEventModel.meetingLink =
          _selectedOption.contains(OfflineOnlineOption.online)
              ? _meetingIDController.text
              : null;

      // Validate duration fields
      if (createEventProvider.createEventModel.durationFrom == null ||
          createEventProvider.createEventModel.durationTo == null) {
=======
    // Validate mode selection
    if (_selectedOption.isEmpty) {
      showToast(
        text: "Please select either Online or Offline mode",
        color: Colors.red,
        context: mcontext,
      );
      return;
    }

    // Filter out empty phone numbers
    String? phoneNumber = _phoneNumberControllers
        .map((controller) => controller.text.trim())
        .where((number) => number.isNotEmpty)
        .firstOrNull;

    if (phoneNumber == null) {
      showToast(
        text: "Please enter at least one phone number",
        color: Colors.red,
        context: mcontext,
      );
      return;
    }

    try {
      // Update event model with validated data
      createEventProvider.createEventModel.mode = _selectedOption.map((option) => option.name).join(',');
      createEventProvider.createEventModel.meetingLink = _selectedOption.contains(OfflineOnlineOption.online) ? _meetingIDController.text : null;
      createEventProvider.createEventModel.description = _descriptionController.text;
      createEventProvider.createEventModel.registrationLink = _registrationLinkController.text;
      createEventProvider.createEventModel.teachers = addedTeachers;
      createEventProvider.createEventModel.phoneNumber = [phoneNumber];
      createEventProvider.createEventModel.address = [_locationUrlController.text];

      // Only include coordinates if location is provided
      if (lat != null && lng != null) {
        createEventProvider.createEventModel.coordinates = [lng, lat]; // Note: API expects [longitude, latitude]
      }

      if (mounted) {
        context.read<CreateEventBloc>().add(CreateEvent(
            event: createEventProvider.createEventModel,
            edit: "",
            eventId: ""));

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavigationScreen()),
        );
      }
    } catch (e) {
      showToast(
        text: "Error creating event: ${e.toString()}",
        color: Colors.red,
        context: mcontext,
      );
    }
  }

  bool _validateFields() {
    // Basic validation for required fields
    if (_descriptionController.text.isEmpty) {
      showToast(
        text: "Please add a description",
        color: Colors.red,
        context: context,
      );
      return false;
    }

    // Validate phone numbers
    bool hasValidPhoneNumber = false;
    for (var controller in _phoneNumberControllers) {
      String phone = controller.text.trim();
      if (phone.isNotEmpty) {
        String digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
        if (digitsOnly.length < 10) {
          showToast(
            text: "Phone numbers must have at least 10 digits",
            color: Colors.red,
            context: context,
          );
          return false;
        }
        hasValidPhoneNumber = true;
      }
    }

    if (!hasValidPhoneNumber) {
      showToast(
        text: "Please enter at least one valid phone number",
        color: Colors.red,
        context: context,
      );
      return false;
    }

    // Validate location for offline events
    if (_selectedOption.contains(OfflineOnlineOption.offline)) {
      if (_locationUrlController.text.isEmpty) {
>>>>>>> parent of f9353431 (bug)
        showToast(
          text: "Please select duration (start and end time)",
          color: Colors.red,
          context: mcontext,
        );
        return;
      }

      createEventProvider.createEventModel.description =
          _descriptionController.text;
      createEventProvider.createEventModel.registrationLink =
          _registrationLinkController.text;
      createEventProvider.createEventModel.teachers = addedTeachers;
      createEventProvider.createEventModel.phoneNumber = [phoneNumber];
      createEventProvider.createEventModel.address = [
        _locationUrlController.text
      ];

      if (lat != null && lng != null) {
        createEventProvider.createEventModel.coordinates = [lng, lat];
      }

      debugPrint(
          "Submitting event with data: ${createEventProvider.createEventModel.toJson()}");
=======
      // Handle mode selection from Set<OfflineOnlineOption>
      if (_selectedOption.isNotEmpty) {
        // Convert Set to List of names
        List<String> modeNames =
            _selectedOption.map((option) => option.name).toList();
        createEventProvider.createEventModel.mode = modeNames as String?;
      } else {
        createEventProvider.createEventModel.mode = [] as String?;
      }

=======
      // Handle mode selection from Set<OfflineOnlineOption>
      if (_selectedOption.isNotEmpty) {
        // Convert Set to List of names
        List<String> modeNames =
            _selectedOption.map((option) => option.name).toList();
        createEventProvider.createEventModel.mode = modeNames as String?;
      } else {
        createEventProvider.createEventModel.mode = [] as String?;
      }

>>>>>>> parent of 283b956a (latest update .create course is remaining)
      createEventProvider.createEventModel.meetingLink =
          _meetingIDController.text;
      createEventProvider.createEventModel.description =
          _descriptionController.text;
      createEventProvider.createEventModel.registrationLink =
          _registrationLinkController.text;
      createEventProvider.createEventModel.teachers = addedTeachers;
      createEventProvider.createEventModel.coordinates = [
        addressProvider.latitude,
        addressProvider.longitude
      ];
      createEventProvider.createEventModel.mapUrl = _mapController.text;
      createEventProvider.createEventModel.phoneNumber = phoneNumbers;
      createEventProvider.createEventModel.address = [
        _locationUrlController.text
      ];
      createEventProvider.createEventModel.aol = ["course"];
      createEventProvider.createEventModel.timeOffset = "UTC+05:30";
<<<<<<< HEAD
>>>>>>> parent of 283b956a (latest update .create course is remaining)
=======
>>>>>>> parent of 283b956a (latest update .create course is remaining)

      if (mounted) {
        context.read<CreateEventBloc>().add(CreateEvent(
            event: createEventProvider.createEventModel,
            edit: "",
            eventId: ""));

        Navigator.push(
<<<<<<< HEAD
            context,
            MaterialPageRoute(
                builder: (context) => const BottomNavigationScreen()));
      }
    } catch (e, stackTrace) {
      debugPrint("Error creating event: $e");
      debugPrint("Stack trace: $stackTrace");
      showToast(
        text: "Error creating event: $e",
=======
          context,
          MaterialPageRoute(
              builder: (context) => const BottomNavigationScreen()),
        );
      }
    } else {
      showToast(
        text: "Please fill the details!",
<<<<<<< HEAD
>>>>>>> parent of 283b956a (latest update .create course is remaining)
=======
>>>>>>> parent of 283b956a (latest update .create course is remaining)
        color: Colors.red,
        context: mcontext,
      );
    }
  }

  bool isEnd = false;
  double width = 250;

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
<<<<<<< HEAD
    // Get providers with null safety
    final addressProvider = Provider.of<AddressProvider>(context, listen: true);
    final createEventProvider = Provider.of<CreateEventProvider>(context, listen: true);
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: true);

    // Safely handle addresses
    final addresses = addressProvider.address;
    if (addresses != null && addresses.isNotEmpty) {
      final firstAddress = addresses.first;
      final addressComponents = [
        firstAddress.name,
        firstAddress.subLocality,
        firstAddress.administrativeArea,
        firstAddress.postalCode,
      ].where((component) => component != null && component.isNotEmpty).join(' ');
      
      if (addressComponents.isNotEmpty) {
        _locationUrlController.text = addressComponents;
      }
=======
=======
>>>>>>> parent of 283b956a (latest update .create course is remaining)
    final AddressProvider addressProvider =
        Provider.of<AddressProvider>(context, listen: true);
    final List<Placemark>? addresses = addressProvider.address;
    if (addresses != null) {
      String address =
          '${addresses.first.name!} ${addresses.first.subLocality!} ${addresses.first.administrativeArea!} ${addresses.first.postalCode!}';
      _locationUrlController.text = address;
<<<<<<< HEAD
>>>>>>> parent of 283b956a (latest update .create course is remaining)
=======
>>>>>>> parent of 283b956a (latest update .create course is remaining)
    }
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
          "Schedule Meeting",
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
                _customCheckboxListTile(
                  title: 'Offline',
                  value: _selectedOption.contains(OfflineOnlineOption.offline),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        _selectedOption.add(OfflineOnlineOption.offline);
                      } else {
                        _selectedOption.remove(OfflineOnlineOption.offline);
                      }
                    });
                  },
                ),
                const SizedBox(width: 10),
                _customCheckboxListTile(
                  title: 'Online',
                  value: _selectedOption.contains(OfflineOnlineOption.online),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        _selectedOption.add(OfflineOnlineOption.online);
                      } else {
                        _selectedOption.remove(OfflineOnlineOption.online);
                      }
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20.sp),
            CourseFollowupEventWidget(),
            SizedBox(height: 20.sp),

            SelectCourseWidget(),
            SizedBox(height: 13.sp),
            const MyDateRangePicker(),

            SizedBox(height: 13.sp),
            Row(
                // crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TimeDropdown(width: width),
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
                  Visibility(visible: isEnd, child: TimeDropdown1()),
                ]),
            SizedBox(height: 13.sp),
            _textFieldWidget(_meetingIDController, "Meeting ID",
                labelColor: AppColors.primaryColor),
            SizedBox(height: 13.sp),
            _textFieldWidget(
              _descriptionController,
              "Add Description",
              maxLines: null,
              textInputAction: TextInputAction.newline,
            ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                        onTap: () {
                          setState(() {
                            count + 1;
                            _addPhoneNumberField();
                          });
                        },
                        child: addIconButton()),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        _phoneNumberFields.removeLast();
                        setState(() {});
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                          ),
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.remove,
                            color: Colors.white, size: 16.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 13.sp),

            SizedBox(
              height: (70 * _phoneNumberFields.length).toDouble(),
              child: ListView.builder(
                  itemCount: _phoneNumberFields.length,
                  itemBuilder: (c, i) {
                    return _phoneNumberFields[i];
                  }),
            ),
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

  Widget _customCheckboxListTile({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return SizedBox(
      width: 150.sp,
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
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

  Widget _textFieldWidget(
    TextEditingController controller,
    String hintText, {
    IconData? prefixIcon,
    String? Function(String?)? validator,
    Color? labelColor,
    IconData? suffixIcon,
    int? maxLines,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines ?? 1,
      keyboardType:
          maxLines == null ? TextInputType.text : TextInputType.multiline,
      textInputAction: textInputAction ?? TextInputAction.done,
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

<<<<<<< HEAD
  Widget _textFieldWidgetLoc(TextEditingController controller, String hintText,
      {IconData? prefixIcon,
      String? Function(String?)? validator,
      Color? labelColor,
      IconData? suffixIcon}) {
<<<<<<< HEAD
<<<<<<< HEAD
=======
  Widget _textFieldWidgetLoc(TextEditingController controller, String hintText, {
    IconData? prefixIcon,
    String? Function(String?)? validator,
    Color? labelColor,
    IconData? suffixIcon
  }) {
>>>>>>> parent of f9353431 (bug)
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: labelColor ?? Colors.grey,
                )
              : null,
          suffixIcon: IconButton(
            icon: Icon(suffixIcon ?? Icons.location_on),
            onPressed: () async {
              try {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectLocationScreen()),
                );

                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _locationUrlController.text = result['formattedAddress'] ?? '';
                    
                    // Store the coordinates in the provider for later use
                    final AddressProvider addressProvider = Provider.of<AddressProvider>(context, listen: false);
                    addressProvider.updatePosition(
                      lat: result['coordinates']?['lat'] ?? 0.0,
                      long: result['coordinates']?['lng'] ?? 0.0,
                      address: result['fullAddress'] != null ? [Placemark(
                        name: result['street'] ?? '',
                        locality: result['city'] ?? '',
                        administrativeArea: result['state'] ?? '',
                        postalCode: result['postalCode'] ?? '',
                        country: result['country'] ?? ''
                      )] : []
                    );

                    // Update map URL after location is selected
                    final lat = result['coordinates']?['lat'];
                    final lng = result['coordinates']?['lng'];
                    if (lat != null && lng != null) {
                      _mapController.text = 'https://www.google.com/maps?q=$lat,$lng';
                    }
                  });
                }
              } catch (e) {
                showToast(
                  text: "Error selecting location: ${e.toString()}",
                  color: Colors.red,
                  context: context
                );
              }
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
=======
    return TextFormField(
      controller: controller,
      validator: validator,
      onTap: () async {
        // Navigate to Select Location page

=======
    return TextFormField(
      controller: controller,
      validator: validator,
      onTap: () async {
        // Navigate to Select Location page

>>>>>>> parent of 283b956a (latest update .create course is remaining)
        Get.to(SelectLocationScreen());
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
<<<<<<< HEAD
>>>>>>> parent of 283b956a (latest update .create course is remaining)
=======
>>>>>>> parent of 283b956a (latest update .create course is remaining)
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
  Widget phoneNumberField(
      UniqueKey key, TextEditingController phoneController) {
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
<<<<<<< HEAD
<<<<<<< HEAD
                      // Store country code without + symbol for consistency
                      selectedCountryCode = countryCode.dialCode?.replaceAll('+', '') ?? '';
                      
                      // Update the phone number with new country code if there's already a number
                      if (phoneController.text.isNotEmpty) {
                        String number = phoneController.text.replaceAll(RegExp(r'^\+?\d+\s*'), '');
                        phoneController.text = selectedCountryCode + number;
                      }
=======
                      selectedCountryCode = countryCode.dialCode!;
>>>>>>> parent of 283b956a (latest update .create course is remaining)
=======
                      selectedCountryCode = countryCode.dialCode!;
>>>>>>> parent of 283b956a (latest update .create course is remaining)
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
                Container(
                  height: 24.h,
                  width: 1.w,
                  color: Colors.grey,
                ),
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
<<<<<<< HEAD
<<<<<<< HEAD
                    onChanged: (value) {
                      // Remove any non-digit characters from input
                      String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                      if (selectedCountryCode.isNotEmpty && !digitsOnly.startsWith(selectedCountryCode)) {
                        digitsOnly = selectedCountryCode + digitsOnly;
                      }
                      if (value != digitsOnly) {
                        phoneController.text = digitsOnly;
                        phoneController.selection = TextSelection.fromPosition(
                          TextPosition(offset: digitsOnly.length),
                        );
                      }
                    },
=======
>>>>>>> parent of 283b956a (latest update .create course is remaining)
=======
>>>>>>> parent of 283b956a (latest update .create course is remaining)
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      hintText: 'Enter phone number',
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
        ],
      ),
    );
  }
}
