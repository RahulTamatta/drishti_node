import 'dart:io';

import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/models/search_user.dart';
import 'package:srisridrishti/providers/teacher_provider.dart';
import 'package:srisridrishti/screens/profile/widgets/utill_widget.dart';
import 'package:srisridrishti/screens/teacher/screens/attend_screen.dart';
import 'package:srisridrishti/screens/teacher/screens/teacher_search_screen.dart';
import 'package:srisridrishti/screens/teacher/widgets/date_ranger_picker.dart';
import 'package:srisridrishti/screens/teacher/widgets/select_course_widget.dart';
import 'package:srisridrishti/screens/teacher/widgets/textfield_tags_widget.dart';
import 'package:srisridrishti/themes/theme.dart';
import 'package:srisridrishti/utils/image_picker.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart' as dio;

class CourseFormScreen extends StatefulWidget {
  const CourseFormScreen({super.key});

  @override
  CourseFormScreenState createState() => CourseFormScreenState();
}

class CourseFormScreenState extends State<CourseFormScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  final TextEditingController _captionController = TextEditingController();
  bool isPublic = true;
  final TextEditingController _teacherNameController = TextEditingController();
  List<String> addedTeachers = [];
  List<String> addedTeachersName = [];

  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  data(context) async {
    String? token = await SharedPreferencesHelper.getAccessToken() ?? await SharedPreferencesHelper.getRefreshToken();
    print("Token: $token");

    dynamic headers = {
      'Authorization': 'Bearer ${token.toString()}'
    }; // Add 'Bearer 'token.toString()};
    // dynamic headers = <String, dynamic>{};
    if (_imageFile!.isAbsolute.toString().isNotEmpty) {
      File file1 = _imageFile!.isAbsolute.toString().isNotEmpty
          ? _imageFile!.absolute
          : File("");

      final multipartFile = await dio.MultipartFile.fromFile(file1.path,
          filename: file1.path.split('/').last,
          contentType: dio.DioMediaType('image', 'jpeg/png'));
      dio.FormData formData = dio.FormData.fromMap({
        "images": multipartFile,
        'caption': _captionController,
        'isPrivate': !isPublic,
        'date.to': "user"
      });
      dynamic path = "/event/update-teacher";
      dynamic type = "PATCH";
      apiBloc
          .add(GetApi(add: formData, header: headers, path: path, type: type));
    }
  }

  Widget bloc() {
    return BlocProvider(
      create: (_) => apiBloc,
      child: BlocListener<ApiBloc, BlocState>(
        listener: (context, state) {
          if (state is Error) {
            showToast(
                text: state.message!, color: Colors.red, context: context);
          }
        },
        child: BlocBuilder<ApiBloc, BlocState>(
          builder: (context, state) {
            if (state is Initial) {
              return buildLoading();
            } else if (state is Loading) {
              return Container(child: buildLoading());
            } else if (state is Loaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                print(state.data);
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

  @override
  Widget build(BuildContext context) {
    final TeacherProvider teacherProvider =
        Provider.of<TeacherProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Course Details',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Name Dropdown

                SelectCourseWidget(),
                SizedBox(height: 13.sp),

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

                      addedTeachersName.add(teacher);
                      teacherProvider.searchTeacher =
                          TData(id: "", userName: "", email: "", teacherId: "");
                    });
                  },
                  addedTeachers: addedTeachersName,
                ),
                SizedBox(height: 6.sp),

                const SizedBox(height: 16),

                // Date Fields
                MyDateRangePicker(),
                const SizedBox(height: 16),

                // Uploaded Images with Caption and Public/Private Toggle
                Column(
                  children: [
                    _buildImageUploadSection(),
                    _buildImageUploadSection(), // Repeat this for more images
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Save Button
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(CourseAttendDetailScreen());
                  // Save functionality here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                ],
              ),
            ),
          );
  }

  // Method to build each image upload section
  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder (replace with uploaded image)
        Stack(
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: uploadDocumentWidget(),
            ),
            Visibility(
              visible: _imageFile == null ? false : true,
              child: Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _imageFile = null;
                      // Function to remove the image
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Caption Input
        SizedBox(
          height: 48,
          child: TextFormField(
            controller: _captionController,
            decoration: InputDecoration(
              hintText: 'Add Caption',
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(6),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(6),
              ),
              // contentPadding: EdgeInsets.all(4.0),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Public/Private Toggle
        Row(
          children: [
            Radio(
              value: true,
              groupValue: isPublic,
              onChanged: (value) {
                setState(() {
                  isPublic = value!;
                });
              },
            ),
            Text('Public', style: GoogleFonts.poppins()),
            const SizedBox(width: 16),
            Radio(
              value: false,
              groupValue: isPublic,
              onChanged: (value) {
                setState(() {
                  isPublic = value!;
                });
              },
            ),
            Text('Private', style: GoogleFonts.poppins()),
          ],
        ),
      ],
    );
  }
}
