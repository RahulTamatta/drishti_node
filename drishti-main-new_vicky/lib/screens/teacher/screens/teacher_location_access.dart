import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/widgets/common_container_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/utill.dart';

class TeacherLocationAccess extends StatefulWidget {
  const TeacherLocationAccess({super.key});

  @override
  State<TeacherLocationAccess> createState() => _TeacherLocationAccessState();
}

class _TeacherLocationAccessState extends State<TeacherLocationAccess> {
  bool _isLocationOn = false;
  bool _isNearbyVisibility = false;

  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  data(context) async {
    String? token = await SharedPreferencesHelper.getAccessToken() ?? await SharedPreferencesHelper.getRefreshToken();
    print("Token: $token");

    dynamic headers = {
      'Authorization': 'Bearer ${token.toString()}'
    }; // Add 'Bearer 'token.toString()};
    // dynamic headers = <String, dynamic>{};
    dynamic body = {
      "nearByVisible": _isLocationOn,
      "locationSharing": _isNearbyVisibility
    };
    dynamic path = "/user/locationSharing";
    dynamic type = "PATCH";
    apiBloc.add(GetApi(add: body, header: headers, path: path, type: type));

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
              canPop: true, // prevent back
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

              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Navigator.of(context).pushAndRemoveUntil(
                //     MaterialPageRoute(builder: (context) {
                //   return const BottomNavigationScreen();
                // }), (_) => false);
                Navigator.of(context).pop();
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
    return Scaffold(
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
          "Location Access",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Location Sharing",
                  style: GoogleFonts.manrope(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 30),
                Radio(
                  value: true,
                  groupValue: _isLocationOn,
                  onChanged: (value) {
                    setState(() {
                      _isLocationOn = value!;
                    });
                  },
                ),
                Text(
                  'On',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(width: 10),
                Radio(
                  value: false,
                  groupValue: _isLocationOn,
                  onChanged: (value) {
                    setState(() {
                      _isLocationOn = value!;
                    });
                  },
                ),
                Text(
                  'Off',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Location Sharing",
                  style: GoogleFonts.manrope(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 30),
                Radio(
                  value: true,
                  groupValue: _isNearbyVisibility,
                  onChanged: (value) {
                    setState(() {
                      _isNearbyVisibility = value!;
                    });
                  },
                ),
                Text(
                  'On',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(width: 10),
                Radio(
                  value: false,
                  groupValue: _isNearbyVisibility,
                  onChanged: (value) {
                    setState(() {
                      _isNearbyVisibility = value!;
                    });
                  },
                ),
                Text(
                  'Off',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
            const Spacer(),
            InkWell(
                onTap: () {
                  data(context);
                },
                child: const CommonContainerButton(labelText: "Save Changes")),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
