// profile_screen.dart
import 'package:dio/dio.dart' as dio;
import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_bloc.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_event.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_state.dart';
import 'package:srisridrishti/models/user_details_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:srisridrishti/utils/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srisridrishti/screens/profile/widgets/utill_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isOnboarded = false; // Add this variable
  final _formKey = GlobalKey<FormState>();
  bool _isRefreshing = false;

  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController, _teacherIdController;
  late bool _isTeacher;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _teacherIdController = TextEditingController();
    _isTeacher = false;

    _fetchProfileDetails();
    _checkOnboardingStatus();
    super.initState();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final userDetails =
          await context.read<ProfileDetailsBloc>().getUserDetails();
      setState(() {
        _isOnboarded = userDetails?.isOnboarded ?? false;
        _isEditing =
            !_isOnboarded; // Automatically enable editing for new users
      });
    } catch (e) {
      print('Error checking onboarding status: $e');
    }
  }

  Future<void> _fetchProfileDetails() async {
    if (_isRefreshing) return;

    try {
      context.read<ProfileDetailsBloc>().add(GetProfileDetails());
    } catch (e) {
      if (e is dio.DioException && e.response?.statusCode == 401) {
        // Token expired, try to refresh
        await _handleTokenRefresh();
      }
    }
  }

  Future<void> _handleTokenRefresh() async {
    _isRefreshing = true;
    try {
      final refreshToken = await SharedPreferencesHelper.getRefreshToken();

      if (refreshToken == null) {
        // No refresh token available, redirect to login
        _navigateToLogin();
        return;
      }

      final newAccessToken =
          await SharedPreferencesHelper.refreshAccessToken(refreshToken);

      if (newAccessToken != null) {
        // Token refresh successful, retry fetching profile
        context.read<ProfileDetailsBloc>().add(GetProfileDetails());
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      print('Token refresh failed: $e');
      _navigateToLogin();
    } finally {
      _isRefreshing = false;
    }
  }

  void _navigateToLogin() {
    // Clear tokens
    SharedPreferencesHelper.clearTokens();
    // Navigate to login screen
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: _isOnboarded
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
            _isOnboarded
                ? (_isEditing ? 'Edit Profile' : 'My Profile')
                : 'Complete Profile',
            style: const TextStyle(color: Colors.black)),
        actions: [
          if (_isOnboarded)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileDetailsBloc, ProfileDetailsState>(
        listener: (context, state) {
          if (state is ProfileDetailsUpdatedSuccessfully) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            setState(() => _isEditing = false);
          } else if (state is FailedToUpdateProfileDetails) {
            if (state.profileResponse.statusCode == 422) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please provide a user name')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Failed to update profile: ${state.profileResponse.message}')),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is ProfileDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileDetailsLoadedSuccessfully) {
            if (!_isOnboarded) {
              // Show registration form for new users
              return _buildRegistrationForm();
            }
            // Show existing profile for onboarded users
            _updateControllers(state.profileResponse.data!);
            return _buildProfileForm();
          } else if (state is FailedToFetchProfileDetails) {
            if (state.profileResponse.statusCode == 401 && !_isRefreshing) {
              _handleTokenRefresh();
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      'Failed to load profile: ${state.profileResponse.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchProfileDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome! Please complete your profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            _buildMandatoryTextField(_usernameController, 'Username*'),
            _buildMandatoryTextField(_fullNameController, 'Full Name*'),
            _buildMandatoryTextField(_emailController, 'Email*'),
            _buildMandatoryTextField(_mobileController, 'Mobile No*'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveChanges(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Complete Registration',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMandatoryTextField(
      TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildProfileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                profileImage != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(profileImage!),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(profile),
                      ),
                if (_isEditing)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.edit, size: 20, color: Colors.blue),
                      onPressed: () {
                        _pickImage();
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(_usernameController, 'Enter Username'),
            _buildTextField(_fullNameController, 'Enter Full Name'),
            _buildTextField(_emailController, 'Enter Email'),
            _buildTextField(_mobileController, 'Enter Mobile No'),
            const SizedBox(height: 10),
            const Text(
              'Are you an Art of Living Teacher?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRadioButton('No', false),
                const SizedBox(width: 20),
                _buildRadioButton('Yes', true),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(_teacherIdController, 'Enter Teacher Id',
                readOnly: true),
            const SizedBox(height: 10),
            teacherIdCard.toString().isNotEmpty
                ? Image(
                    image: NetworkImage(teacherIdCard),
                    height: 200.sp,
                    fit: BoxFit.fill,
                  )
                : uploadDocumentWidget(),
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () {
                    _saveChanges(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  File? profileImage;

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
      showToast(
          text: "Error picking image: $e", color: Colors.red, context: context);
    }
  }

  File? _imageFile;
  bool documentUploaded = false;
  uploadDocumentWidget() {
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
              Text("File has been uploaded successfully.",
                  style: GoogleFonts.manrope(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
            ],
          )
        : InkWell(
            onTap: () async {
              _imageFile =
                  await ImagePickerService.pickImage(ImageSource.gallery);
              setState(() {
                documentUploaded = true;
              });
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
                  bulletTexts("We support PNG, JPG, JPEG,  only "),
                  bulletTexts("The image size should be less than 500 KB"),
                  bulletTexts("The dimension of the image should be x*y."),
                ],
              ),
            ),
          );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {readOnly}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly ?? false,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        enabled: readOnly == true ? false : _isEditing,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRadioButton(String label, bool value) {
    return OutlinedButton(
      onPressed: _isEditing ? () => setState(() => _isTeacher = value) : null,
      style: OutlinedButton.styleFrom(
        backgroundColor: _isTeacher == value ? Colors.blue : Colors.white,
        side: BorderSide(
            color: _isTeacher == value ? Colors.blue : Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _isTeacher == value ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  var profile;
  var teacherIdCard;

  void _updateControllers(UserDetailsModel userDetails) {
    profile = userDetails.profileImage!;
    teacherIdCard = userDetails.teacherIdCard;

    _usernameController.text = userDetails.userName!;
    _fullNameController.text = userDetails.name!;
    _emailController.text = userDetails.email!;
    _mobileController.text = userDetails.mobileNo!;
    _teacherIdController.text = userDetails.teacherId!;
    _isTeacher = userDetails.role == 'teacher';
  }

  void _saveChanges(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Existing form data
      Map<String, dynamic> formDataMap = {
        'userName': _usernameController.text.trim(),
        'name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobileNo': _mobileController.text.trim(),
        'role': _isTeacher ? "teacher" : "user",
        'bio': '',
        'youtubeUrl': '',
        'xUrl': '',
        'instagramUrl': '',
        'nearByVisible': false,
        'locationSharing': false,
        'isOnboarded': true, // Set this to true when saving
      };

      // Add profile image
      final profileMultipart = await dio.MultipartFile.fromFile(
        profileImage!.path,
        filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpeg',
        contentType: dio.DioMediaType('image', 'jpeg'),
      );

      dio.FormData formData = dio.FormData.fromMap(formDataMap);
      formData.files.add(
        MapEntry('profileImage', profileMultipart),
      );

      // Add teacher specific data if user is a teacher
      if (_isTeacher) {
        if (_imageFile == null) {
          showToast(
            text: "Please select teacher ID card image",
            color: Colors.red,
            context: context,
          );
          return;
        }

        final teacherIdMultipart = await dio.MultipartFile.fromFile(
          _imageFile!.path,
          filename: 'teacher_id_${DateTime.now().millisecondsSinceEpoch}.jpeg',
          contentType: dio.DioMediaType('image', 'jpeg'),
        );

        formData.fields
            .add(MapEntry('teacherId', _teacherIdController.text.trim()));
        formData.files.add(MapEntry('teacherIdCard', teacherIdMultipart));
      }

      // Send data to API
      data(formData); // Correct invocation with one argument
    }
  }

  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  data(formData) async {
    String? token = await SharedPreferencesHelper.getAccessToken();
    print("Token: $token");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString("UserID");

    // Debug: Print token and userID for verification
    print("Token: $token");
    print("[DEBUG] UserID: $userID");

    // Handle missing token/userID
    if (token!.isEmpty) {
      print("[ERROR] Token is missing or empty!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Authentication failed. Please login again.")),
      );
      return;
    }

    if (userID == null || userID.isEmpty) {
      print("[ERROR] UserID is missing!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User session expired. Please relogin.")),
      );
      return;
    }

    dynamic headers = {
      'Authorization': 'Bearer ${token.toString()}'
    }; // Correctly formatted Authorization header

    apiBloc.add(UpdateProfile(add: formData, header: headers, id: userID));

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
              canPop: false, // prevent back
              onPopInvokedWithResult: (bool didPop, Object? result) {
                Navigator.of(context).pop();
              },
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
              ));
        });
  }

  Widget bloc() {
    return BlocProvider(
      create: (_) => apiBloc,
      child: BlocListener<ApiBloc, BlocState>(
        listener: (context, state) {
          if (state is Error) {
            // Optionally handle errors
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
                Get.back();
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

  Future<void> profileApi(context1) async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      showToast(
        text: "Please fill all required fields",
        color: Colors.red,
        context: context1,
      );
      return;
    }

    if (_mobileController.text.length != 10) {
      showToast(
        text: "Mobile number must be 10 digits",
        color: Colors.red,
        context: context1,
      );
      return;
    }

    // Check if profile image is selected
    if (profileImage == null) {
      showToast(
        text: "Please select a profile image",
        color: Colors.red,
        context: context1,
      );
      return;
    }

    try {
      // Create base form data
      Map<String, dynamic> formDataMap = {
        'userName': _usernameController.text.trim(),
        'name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobileNo': _mobileController.text.trim(),
        'role': _isTeacher ? "teacher" : "user",
        'bio': '',
        'youtubeUrl': '',
        'xUrl': '',
        'instagramUrl': '',
        'nearByVisible': false,
        'locationSharing': false,
      };

      // Add profile image
      final profileMultipart = await dio.MultipartFile.fromFile(
        profileImage!.path,
        filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpeg',
        contentType: dio.DioMediaType('image', 'jpeg'),
      );

      // Create form data
      dio.FormData formData = dio.FormData.fromMap(formDataMap);
      formData.files.add(
        MapEntry('profileImage', profileMultipart),
      );

      // Add teacher specific data if user is a teacher
      if (_isTeacher) {
        if (_imageFile == null) {
          showToast(
            text: "Please select teacher ID card image",
            color: Colors.red,
            context: context1,
          );
          return;
        }

        final teacherIdMultipart = await dio.MultipartFile.fromFile(
          _imageFile!.path,
          filename: 'teacher_id_${DateTime.now().millisecondsSinceEpoch}.jpeg',
          contentType: dio.DioMediaType('image', 'jpeg'),
        );

        formData.fields
            .add(MapEntry('teacherId', _teacherIdController.text.trim()));
        formData.files.add(MapEntry('teacherIdCard', teacherIdMultipart));
      }

      // Send data to API
      data(formData); // Correct invocation with one argument
    } catch (e) {
      print("Error preparing form data: $e");
      showToast(
        text: "Error updating profile. Please try again.",
        color: Colors.red,
        context: context1,
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _teacherIdController.dispose();
    super.dispose();
  }
}
