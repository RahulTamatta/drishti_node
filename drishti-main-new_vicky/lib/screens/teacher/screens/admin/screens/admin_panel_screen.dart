import 'package:srisridrishti/bloc/admin_panel/teacher_status_bloc.dart';
import 'package:srisridrishti/models/teacher_details_model.dart';
import 'package:srisridrishti/services/admin_panel/teacher_status.dart';
import 'package:srisridrishti/themes/theme.dart';
import 'package:srisridrishti/widgets/common_container_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => AdminPanelScreenState();
}

class AdminPanelScreenState extends State<AdminPanelScreen> {
  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  data(context) async {
    dynamic headers = <String, dynamic>{};
    dynamic body = <String, dynamic>{};
    dynamic path = "";
    dynamic type = "";
    apiBloc.add(GetApi(add: body, header: headers, path: path, type: type));

    // showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (BuildContext context) {
    //       return WillPopScope(
    //           onWillPop: () {
    //             Navigator.of(context).pop();
    //             return Future.value(false);
    //           },
    //           child: AlertDialog(
    //             shape: const RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.all(Radius.circular(5.0))),
    //             content: Builder(
    //               builder: (context) {
    //                 return SizedBox(
    //                   height: 200,
    //                   width: 200,
    //                   child: bloc(),
    //                 );
    //               },
    //             ),
    //             insetPadding: EdgeInsets.zero,
    //             contentPadding: EdgeInsets.zero,
    //             clipBehavior: Clip.antiAliasWithSaveLayer,
    //           ));
    //     });
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
              // showToast(
              //     text: "Address Created Successfully",
              //     color: Colors.red,
              //     context: context);

              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   Navigator.of(context).pushAndRemoveUntil(
              //       MaterialPageRoute(builder: (context) {
              //     return const BottomNavigationScreen();
              //   }), (_) => false);
              // });
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TeacherBloc(ApiService())..add(FetchTeachersRequest()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
          ),
          centerTitle: false,
          title: Text(
            "Admin Panel",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        body: BlocConsumer<TeacherBloc, TeacherState>(
          listener: (context, state) {
            print(state);
            if (state is TeacherActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Action completed successfully')),
              );
            } else if (state is TeacherError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is TeacherLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TeacherLoaded) {
              return _buildTeacherList(context, state.teachers);
            } else if (state is TeacherError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTeacherList(
      BuildContext context, List<TeachersDetails> teachers) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      shrinkWrap: true,
      itemCount: teachers.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        return _buildTeacherCard(context, teacher);
      },
    );
  }

  Widget _buildTeacherCard(BuildContext context, TeachersDetails teacher) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.courseBgColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                teacher.name ?? '',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                height: 60.sp,
                width: 60.sp,
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.sp),
                  color: Colors.white,
                  image: teacher.profileImage != null
                      ? DecorationImage(
                          image: NetworkImage(teacher.profileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
            ],
          ),
          _buildTeacherIdTextSpan('Teacher ID', teacher.teacherId ?? ''),
          const SizedBox(height: 5),
          _buildTeacherIdTextSpan('Mobile No', teacher.mobileNo ?? ''),
          const SizedBox(height: 5),
          _buildTeacherIdTextSpan('Email Address', teacher.email ?? ''),
          const SizedBox(height: 15),
          Text(
            "Teacher ID Card",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontSize: 13.sp,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 150.sp,
            width: 260.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.pink.withOpacity(0.2),
              image: teacher.teacherIdCard != null
                  ? DecorationImage(
                      image: NetworkImage(teacher.teacherIdCard!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          SizedBox(height: 20.sp),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    context
                        .read<TeacherBloc>()
                        .add(SuspendTeacher(teacher.sId!));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.sp),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Suspend",
                      style: GoogleFonts.manrope(
                        textStyle: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: InkWell(
                  onTap: () {
                    context
                        .read<TeacherBloc>()
                        .add(ApproveTeacher(teacher.sId!));
                  },
                  child: const CommonContainerButton(labelText: "Accept"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  RichText _buildTeacherIdTextSpan(String label, String title) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: '$label: ',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontSize: 13.sp,
              ),
            ),
          ),
          TextSpan(
            text: title,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
