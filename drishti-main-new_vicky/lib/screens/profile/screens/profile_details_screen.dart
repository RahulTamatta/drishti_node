import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart'; // Add this import for MediaType
import 'package:dio/dio.dart';
import 'package:srisridrishti/bloc/profile_bloc/profile_bloc.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_bloc.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_event.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_state.dart';
import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/models/user_details_model.dart';
import 'package:srisridrishti/screens/bottom_navigation/bottom_navigation_screen.dart';
import 'package:srisridrishti/screens/location/screens/location_screen.dart';
import 'package:srisridrishti/screens/profile/screens/user_profile_screen.dart';
import 'package:srisridrishti/screens/profile/widgets/profile_appbar.dart';
import 'package:srisridrishti/screens/profile/widgets/profile_shimmer.dart';
import 'package:srisridrishti/screens/profile/widgets/utill_widget.dart';
import 'package:srisridrishti/screens/teacher/screens/teacher_profile_screen.dart';
import 'package:srisridrishti/themes/theme.dart';
import 'package:srisridrishti/utils/image_picker.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/widgets/common_container_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

enum YesNoOption { yes, no, none }

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => ProfileDetailsScreenState();
}

class ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ValueNotifier<YesNoOption> _selectedOption =
      ValueNotifier<YesNoOption>(YesNoOption.none);

  final TextEditingController _nameController = TextEditingController();
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _numberController, _teacherIdController;
  late bool _isTeacher;

  File? profileImage;
  File? _imageFile;
  bool documentUploaded = false;
  ApiBloc apiBloc = ApiBloc();

  @override
  void dispose() {
    _selectedOption.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _numberController.dispose();
    _teacherIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize all controllers
    _usernameController = TextEditingController();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _numberController = TextEditingController();
    _teacherIdController = TextEditingController();
    _isTeacher = false;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentState = context.read<ProfileDetailsBloc>().state;
      if (currentState is! ProfileDetailsLoadedSuccessfully) {
        context.read<ProfileDetailsBloc>().add(GetProfileDetails());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: profileAppbar(context), // Replace with your app bar widget
      body: BlocBuilder<ProfileDetailsBloc, ProfileDetailsState>(
        builder: (context, state) {
          if (state is ProfileDetailsLoadedSuccessfully) {
            if (_selectedOption.value == YesNoOption.none) {
              final UserDetailsModel? userDetails = state.profileResponse.data;
              _usernameController.text = userDetails?.userName ?? "";
              _nameController.text = userDetails?.name ?? "";
              _emailController.text = userDetails?.email ?? "";
              _numberController.text = userDetails?.mobileNo ?? "";
              // Print user details to debug
              print(
                  "User Details: ${userDetails?.toJson()}"); // Assuming toJson() method exists
              print("Username: ${userDetails?.userName}");
              print("Name: ${userDetails?.name}");
              print("Email: ${userDetails?.email}");
              print("Mobile No: ${userDetails?.mobileNo}");
              print("Role: ${userDetails?.role}");

              if (userDetails?.role == "teacher" &&
                      userDetails?.teacherRoleApproved == 'accepted' ||
                  userDetails?.role == "admin") {
                return TeacherProfileScreen(userDetails: userDetails!);
              } else if (userDetails?.role == "user" &&
                      userDetails?.email != null ||
                  userDetails?.role == "teacher") {
                return buildMainForm();
              }
            }
            return buildMainForm();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildMainForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Form(
        key: _formKey,
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) async {
            if (state is ProfileDetailsAddedSuccessfully) {
              await SharedPreferencesHelper.setOnboardingComplete(
                  true); // Replace with your shared preferences helper
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) {
                  return const BottomNavigationScreen(); // Replace with your bottom navigation screen
                }),
                (_) => false,
              );
            }
            if (state is ProfileDetailsAddedFailed) {
              showToast(
                  text: state.profileRes.message,
                  color: Colors.red,
                  context: context);
            }
          },
          child: Column(
            children: [
              profileIconWidget(),
              const SizedBox(height: 20),
              buildFormFields(),
              buildTeacherSelection(),
              if (_selectedOption.value == YesNoOption.yes)
                buildTeacherFields(),
              buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFormFields() {
    return Column(
      children: [
        _textFieldWidget(
          _usernameController,
          "User Name",
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a username';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _textFieldWidget(
          _nameController,
          "Full Name",
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _textFieldWidget(
          _emailController,
          "E-mail",
          prefixIcon: Icons.email_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter e-mail';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        buildPhoneField(),
      ],
    );
  }

  Widget buildPhoneField() {
    return TextField(
      controller: _numberController,
      style: TextStyle(
          fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.w400),
      maxLength: 10,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "Phone number",
        hintStyle: TextStyle(fontSize: 14.sp, color: Colors.black54),
        contentPadding: EdgeInsets.all(5.sp),
        prefixIcon: const Icon(Icons.phone, color: Colors.black12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(7),
        ),
      ),
    );
  }

  Widget buildTeacherSelection() {
    return Column(
      children: [
        Row(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Are you an ',
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: 'Art of Living\nTeacher?',
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        Row(
          children: [
            buildRadioOption("Yes", YesNoOption.yes),
            const SizedBox(width: 30),
            buildRadioOption("No", YesNoOption.no),
          ],
        ),
      ],
    );
  }

  Widget buildRadioOption(String title, YesNoOption option) {
    return SizedBox(
      width: 100,
      child: RadioListTile<YesNoOption>(
        title: Text(
          title,
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
                color: Colors.black,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500),
          ),
        ),
        value: option,
        groupValue: _selectedOption.value,
        onChanged: (value) {
          setState(() {
            _selectedOption = ValueNotifier<YesNoOption>(value!);
          });
        },
        activeColor: Colors.blue,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget buildTeacherFields() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _textFieldWidget(
          _teacherIdController,
          "Teacher ID Number",
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your teacher ID';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        uploadDocumentWidget(),
      ],
    );
  }

  Widget buildSubmitButton() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => profileApi(context),
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: state is ProfileDetailsAddingWait
                ? const Center(
                    child: SizedBox(
                      height: 40,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )
                : const CommonContainerButton(labelText: "Save & Next"),
          ),
        );
      },
    );
  }

  Widget _textFieldWidget(TextEditingController controller, String hintText,
      {IconData? prefixIcon, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.manrope(
        textStyle: TextStyle(
          color: Colors.black,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        hintText: hintText,
        labelText: hintText,
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
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 17.sp,
                color: Colors.grey.withOpacity(0.4),
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
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(6),
        ),
        errorStyle: const TextStyle(height: 0),
      ),
    );
  }

  Future<void> profileApi(BuildContext context1) async {
    try {
      if (!_formKey.currentState!.validate()) {
        showToast(
            text: "Please fill all required fields",
            color: Colors.red,
            context: context1);
        return;
      }

      // Validate email format
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(_emailController.text.trim())) {
        showToast(
            text: "Please enter a valid email address",
            color: Colors.red,
            context: context1);
        return;
      }

      if (_numberController.text.length != 10) {
        showToast(
            text: "Phone number must be 10 digits",
            color: Colors.red,
            context: context1);
        return;
      }

      if (profileImage == null) {
        showToast(
            text: "Please select a profile image",
            color: Colors.red,
            context: context1);
        return;
      }

      // Create FormData instance
      final formData = FormData();

      // Process profile image
      if (profileImage != null && await profileImage!.exists()) {
        print('Processing profile image: ${profileImage!.path}');
        String? mimeType = lookupMimeType(profileImage!.path);
        if (mimeType == null) {
          // Default to image/jpeg if MIME type can't be determined
          mimeType = 'image/jpeg';
        }
        print('Profile image MIME type: $mimeType');

        final profileImageFile = await MultipartFile.fromFile(
          profileImage!.path,
          filename:
              'profile_${DateTime.now().millisecondsSinceEpoch}.${mimeType.split('/').last}',
          contentType: MediaType.parse(mimeType),
        );
        formData.files.add(MapEntry('profileImage', profileImageFile));
      }

      // Trim and validate fields
      final username = _usernameController.text.trim();
      final name = _nameController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final mobileNo = _numberController.text.trim();

      if (username.isEmpty ||
          name.isEmpty ||
          email.isEmpty ||
          mobileNo.isEmpty) {
        showToast(
            text: "All fields must be filled",
            color: Colors.red,
            context: context1);
        return;
      }

      // Add basic user data
      formData.fields.addAll([
        MapEntry('userName', username),
        MapEntry('name', name),
        MapEntry('email', email),
        MapEntry('mobileNo', mobileNo),
        MapEntry('role',
            _selectedOption.value == YesNoOption.yes ? 'teacher' : 'user'),
      ]);

      // Handle teacher-specific data
      if (_selectedOption.value == YesNoOption.yes) {
        if (_imageFile == null || !await _imageFile!.exists()) {
          showToast(
              text: "Please select a valid teacher ID document",
              color: Colors.red,
              context: context1);
          return;
        }

        String? teacherIdMimeType = lookupMimeType(_imageFile!.path);
        if (teacherIdMimeType == null) {
          teacherIdMimeType = 'application/octet-stream';
        }
        print('Teacher ID MIME type: $teacherIdMimeType');

        final teacherIdFile = await MultipartFile.fromFile(
          _imageFile!.path,
          filename:
              'teacher_id_${DateTime.now().millisecondsSinceEpoch}.${teacherIdMimeType.split('/').last}',
          contentType: MediaType.parse(teacherIdMimeType),
        );
        formData.files.add(MapEntry('teacherIdCard', teacherIdFile));

        if (_teacherIdController.text.trim().isEmpty) {
          showToast(
              text: "Please enter your teacher ID",
              color: Colors.red,
              context: context1);
          return;
        }
        formData.fields
            .add(MapEntry('teacherId', _teacherIdController.text.trim()));
        formData.fields.add(MapEntry('role', "teacher"));
      } else {
        formData.fields.add(MapEntry('role', "user"));
      }

      // Extensive logging
      print("Form Data Fields: ${formData.fields}");
      print("Form Data Files: ${formData.files}");

      await data(formData);
    } catch (e) {
      print("Error in profileApi: $e");
      showToast(
          text: "Error processing request: $e",
          color: Colors.red,
          context: context1);
    }
  }

  Future<void> data(FormData formData) async {
    String? token = await SharedPreferencesHelper.getAccessToken() ??
        await SharedPreferencesHelper.getRefreshToken();

    if (token!.isEmpty) {
      showToast(
          text: "Authentication failed. Please login again.",
          color: Colors.red,
          context: context);
      return;
    }

    final headers = {
      'Authorization': token,
      'Content-Type': 'multipart/form-data'
    };

    print("Sending request with headers: $headers"); // Debug print

    apiBloc.add(AddProfile(add: formData, header: headers));

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            Navigator.of(context).pop();
          },
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            content: Builder(
              builder: (context) {
                return SizedBox(
                  height: 200,
                  width: 200,
                  child: bloc(),
                );
              },
            ),
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
          ),
        );
      },
    );
  }

  Widget bloc() {
    return BlocProvider(
      create: (_) => apiBloc,
      child: BlocListener<ApiBloc, BlocState>(
        listener: (context, state) {
          if (state is Error) {
            print("API Error: ${state.message}"); // Debug print
          }
        },
        child: BlocBuilder<ApiBloc, BlocState>(
          builder: (context, state) {
            if (state is Initial) {
              return buildLoading();
            } else if (state is Loading) {
              return Container(child: buildLoading());
            } else if (state is Loaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await SharedPreferencesHelper.setOnboardingComplete(true);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) {
                    return const LocationScreen();
                  }),
                  (_) => false,
                );
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

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(), // Or any other loading indicator
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage =
          await ImagePickerService.pickImage(ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          profileImage = pickedImage;
        });
      }
    } catch (e) {
      print("Error picking image: $e"); // Debug print
      showToast(
          text: "Error picking image: $e", color: Colors.red, context: context);
    }
  }

  Widget profileIconWidget() {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          InkWell(
            onTap: _pickImage,
            child: Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.sp),
                color: Colors.grey.shade200,
              ),
              child: profileImage == null
                  ? Icon(
                      Icons.person,
                      color: Colors.grey[400],
                      size: 70.sp,
                    )
                  : ClipOval(
                      child: Image.file(
                        profileImage!,
                        width: 70.sp,
                        height: 70.sp,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 5.sp,
            right: 1.sp,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(20.sp),
              ),
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.camera_alt_outlined,
                color: Colors.grey[400],
                size: 15.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget uploadDocumentWidget() {
    return documentUploaded
        ? Column(
            children: [
              Container(
                width: double.infinity,
                height: 200.sp,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        width: double.maxFinite,
                        fit: BoxFit.fitWidth,
                      )
                    : const Placeholder(),
              ),
              Text(
                "File has been uploaded successfully.",
                style: GoogleFonts.manrope(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          )
        : InkWell(
            onTap: () async {
              try {
                final pickedImage =
                    await ImagePickerService.pickImage(ImageSource.gallery);
                if (pickedImage != null) {
                  setState(() {
                    _imageFile = pickedImage;
                    documentUploaded = true;
                  });
                }
              } catch (e) {
                print("Error picking document: $e"); // Debug print
                showToast(
                    text: "Error picking document: $e",
                    color: Colors.red,
                    context: context);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  uploadDocument(),
                  const SizedBox(height: 10),
                  bulletTexts("We support PNG, JPG, JPEG only"),
                  bulletTexts("The image size should be less than 500 KB"),
                  bulletTexts("The dimension of the image should be x*y."),
                ],
              ),
            ),
          );
  }

  Widget bulletTexts(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.manrope(
              textStyle: TextStyle(
                color: Colors.black54,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
