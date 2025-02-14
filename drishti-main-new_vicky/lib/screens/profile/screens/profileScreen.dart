// profile_screen.dart
import 'package:dio/dio.dart' as dio;
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_bloc.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_event.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_state.dart';
import 'package:srisridrishti/models/user_details_model.dart';
import 'dart:io';
import 'package:srisridrishti/utils/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srisridrishti/screens/profile/widgets/utill_widget.dart';
import 'package:http_parser/http_parser.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

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

    context.read<ProfileDetailsBloc>().add(GetProfileDetails());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditing ? 'Edit Profile' : 'My Profile',
            style: const TextStyle(color: Colors.black)),
        actions: [
          if (!_isEditing)
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Failed to update profile: ${state.profileResponse.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileDetailsLoadedSuccessfully) {
            _updateControllers(state.profileResponse.data!);
            return _buildProfileForm();
          } else if (state is FailedToFetchProfileDetails) {
            return Center(
                child: Text(
                    'Failed to load profile: ${state.profileResponse.message}'));
          }
          return const Center(child: Text('Something went wrong'));
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
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        // Check file size
        final int fileSize = await imageFile.length();
        if (fileSize > 500 * 1024) {
          // 500 KB limit
          throw Exception('Image size should be less than 500 KB');
        }

        setState(() {
          profileImage = imageFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
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
    if (userDetails.profileImage != null) {
      profile = userDetails.profileImage!; // Store the URL
    }
    if (userDetails.teacherIdCard != null) {
      teacherIdCard = userDetails.teacherIdCard!; // Store the URL
    }

    _usernameController.text = userDetails.userName ?? "";
    _fullNameController.text = userDetails.name ?? "";
    _emailController.text = userDetails.email ?? "";
    _mobileController.text = userDetails.mobileNo ?? "";
    _teacherIdController.text = userDetails.teacherId ?? "";
    _isTeacher = userDetails.role == 'teacher';
  }

  Future<void> _saveChanges(BuildContext context1) async {
    if (_formKey.currentState!.validate()) {
      try {
        final formData = dio.FormData();

        // Add text fields
        formData.fields.addAll([
          MapEntry('userName', _usernameController.text.trim()),
          MapEntry('name', _fullNameController.text.trim()),
          MapEntry('email', _emailController.text.trim()),
          MapEntry('mobileNo', _mobileController.text.trim()),
          MapEntry('role', _isTeacher ? 'teacher' : 'user'),
          MapEntry('bio', 'Hello!'), // Add default bio
          MapEntry('nearByVisible', 'false'),
          MapEntry('locationSharing', 'false')
        ]);

        // Add teacher specific fields if teacher role selected
        if (_isTeacher) {
          formData.fields
              .add(MapEntry('teacherId', _teacherIdController.text.trim()));
        }

        // Add profile image if selected
        if (profileImage != null) {
          String fileName = profileImage!.path.split('/').last;
          formData.files.add(MapEntry(
            'profileImage',
            await dio.MultipartFile.fromFile(
              profileImage!.path,
              filename: fileName,
              contentType: MediaType('image', 'jpeg'),
            ),
          ));
        }

        print('Sending form data:');
        print('Fields: ${formData.fields}');
        print('Files: ${formData.files}');

        // Get access token
        final token = await SharedPreferencesHelper.getAccessToken();

        final response = await dio.Dio().post(
          'http://10.0.2.2:8080/user/onBoard',
          data: formData,
          options: dio.Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'multipart/form-data',
            },
            validateStatus: (status) => status! < 500,
          ),
        );

        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');

        if (response.statusCode == 200) {
          if (!context1.mounted) return;
          showToast(
              text: "Profile updated successfully",
              color: Colors.green,
              context: context1);
        } else {
          throw Exception(
              'Failed to update profile: ${response.data['message']}');
        }
      } catch (error) {
        print('Error updating profile: $error');
        if (!context1.mounted) return;
        showToast(
            text: "Error updating profile: $error",
            color: Colors.red,
            context: context1);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }
}
