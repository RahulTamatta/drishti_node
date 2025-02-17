import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_state.dart';
import 'package:srisridrishti/screens/teacher/screens/teacher_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/profile_details_bloc/profile_details_bloc.dart';
import '../../../models/user_details_model.dart';

PreferredSizeWidget profileAppbar(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: BlocBuilder<ProfileDetailsBloc, ProfileDetailsState>(
      builder: (context, state) {
        if (state is ProfileDetailsLoadedSuccessfully) {
          final UserDetailsModel? userDetails = state.profileResponse.data;
          if (userDetails?.role == "teacher" || userDetails?.role == "admin") {
            return _teacherAppBar(context, userDetails);
          } else if (userDetails?.role == "user" &&
              userDetails?.email != null) {
            return _teacherAppBar(context, userDetails);
          } else {
            return _userAppBar(context);
          }
        } else {
          return _userAppBar(context);
        }
      },
    ),
  );
}

Widget _teacherAppBar(context, UserDetailsModel? userDetails) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    centerTitle: false,
    title: Text(
      "${userDetails?.userName}",
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
            color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
    ),
    actions: [
      IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return TeacherSettingScreen(
                userDetails: userDetails,
              );
            }));
          },
          icon: const Icon(
            Icons.settings,
            color: Colors.black,
          ))
    ],
  );
}

Widget _userAppBar(BuildContext context) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    centerTitle: false,
    title: Text(
      "Profile",
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
            color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
