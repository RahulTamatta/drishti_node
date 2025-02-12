import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:srisridrishti/bloc/auth_bloc/authentication_bloc.dart';
import 'package:srisridrishti/screens/profile/screens/profile_details_screen.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import '../../../themes/theme.dart';
import '../../../utils/shared_preference_helper.dart';
import '../../../widgets/common_container_button.dart';

class OtpScreen extends StatefulWidget {
  final String data;
  final String phoneNumber;
  const OtpScreen({super.key, required this.data, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController pinCodeController = TextEditingController();
  Timer? _timer;
  int _start = 45;
  bool _resendEnabled = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    pinCodeController.dispose();
  }

  void startTimer() {
    _start = 45;
    _resendEnabled = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _resendEnabled = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void resendOTP() {
    if (_resendEnabled) {
      // startTimer();
      // context.read<AuthenticationBloc>().add(
      //       ResendOTP(phoneNumber: widget.phoneNumber), // Dispatch ResendOTP event
      //     );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) async {
          if (state is AuthenticationFailed) {
            showToast(
                text: state.verifyOtpResponse.message.toString() ??
                    "Verification Failed", // Safe navigation
                color: Colors.red,
                context: context);
          }
          if (state is AuthenticationSuccessfull) {
            // Check VerifyOtpResponse
            if (state.verifyOtpResponse!.data != null) {
              // Check data
              if (state.verifyOtpResponse!.data!.accessToken != null) {
                // Check accessToken
                String accessToken = state.verifyOtpResponse!.data!
                    .accessToken!; // Access with ! (because of null check)
                await SharedPreferencesHelper.saveAccessToken(accessToken);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) {
                  return const ProfileDetailsScreen();
                }), (_) => false);
              } else {
                print("Access Token is null");
                showToast(
                    text: "Login data is incomplete.",
                    color: Colors.red,
                    context: context);
              }
            } else {
              print("VerifyOtpData is null");
              showToast(
                  text: "Login data is incomplete.",
                  color: Colors.red,
                  context: context);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0, left: 15, right: 8),
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: SingleChildScrollView(
              // Added for scrollability
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15.0, left: 13, right: 15, bottom: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Verify with OTP sent to",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          widget.phoneNumber,
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(height: 25.sp),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: PinCodeTextField(
                            controller: pinCodeController,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(5),
                              fieldHeight: 50,
                              fieldWidth: 45, // Adjusted field width
                              inactiveColor: Colors.grey.withOpacity(0.5),
                              activeColor: AppColors.primaryColor,
                              selectedColor: AppColors.primaryColor,
                            ),
                            length: 6, // 6-digit OTP
                            obscureText: false,
                            animationDuration:
                                const Duration(milliseconds: 300),
                            onChanged: (value) {},
                            appContext: context,
                          ),
                        ),
                        SizedBox(height: 10.sp),
                        Text(
                          "Auto Fetching... OTP",
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(height: 55.sp),
                        BlocBuilder<AuthenticationBloc, AuthenticationState>(
                          builder: (context, state) {
                            return GestureDetector(
                              onTap: () {
                                FirebaseMessaging.instance
                                    .getToken()
                                    .then((token) {
                                  print("token is $token");
                                  context.read<AuthenticationBloc>().add(
                                        OTPVerification(
                                            otp: pinCodeController.text,
                                            data: widget.data,
                                            deviceToken: token.toString()),
                                      );
                                });
                              },
                              child: state is AuthenticationLoading
                                  ? const Center(
                                      child: SizedBox(
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    )
                                  : const CommonContainerButton(
                                      labelText: "Continue"),
                            );
                          },
                        ),
                        SizedBox(height: 15.sp),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Resend OTP in',
                                style: GoogleFonts.manrope(
                                  textStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              TextSpan(
                                text: ' 00:$_start ? ',
                                style: GoogleFonts.manrope(
                                  textStyle: TextStyle(
                                      color: Colors.green,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              TextSpan(
                                text: ' RESEND',
                                style: GoogleFonts.manrope(
                                  textStyle: TextStyle(
                                      color: _resendEnabled
                                          ? AppColors.primaryColor
                                          : Colors.grey,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _resendEnabled ? resendOTP : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:srisridrishti/bloc/auth_bloc/authentication_bloc.dart';

// import 'package:srisridrishti/screens/profile/screens/profile_details_screen.dart';
// import 'package:srisridrishti/themes/theme.dart';
// import 'package:srisridrishti/utils/shared_preference_helper.dart';
// import 'package:srisridrishti/utils/show_toast.dart';

// import 'package:srisridrishti/widgets/common_container_button.dart';

// class OtpScreen extends StatefulWidget {
//   final String data;
//   final String phoneNumber;
//   const OtpScreen({super.key, required this.data, required this.phoneNumber});

//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> {
//   final TextEditingController pinCodeController = TextEditingController();
//   Timer? _timer;
//   int _start = 60;

//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     pinCodeController.dispose();
//     super.dispose();
//   }

//   void startTimer() {
//     _start = 60;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_start == 0) {
//         setState(() => timer.cancel());
//       } else {
//         setState(() => _start--);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: BlocListener<AuthenticationBloc, AuthenticationState>(
//         listener: (context, state) {
//           Future.microtask(() async {
//             final savedToken = await SharedPreferencesHelper.getAccessToken();
//             if (savedToken?.isNotEmpty == true) {
//               Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (_) => const ProfileDetailsScreen()),
//                 (route) => false,
//               );
//             }
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.only(top: 100.0, left: 15, right: 8),
//           child: SizedBox(
//             height: double.infinity,
//             width: double.infinity,
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     top: 15.0,
//                     left: 13,
//                     right: 15,
//                     bottom: 7,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Verify with OTP sent to",
//                         style: GoogleFonts.poppins(
//                           textStyle: TextStyle(
//                             color: Colors.black,
//                             fontSize: 20.sp,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         widget.phoneNumber,
//                         style: GoogleFonts.manrope(
//                           textStyle: TextStyle(
//                             color: Colors.black,
//                             fontSize: 15.sp,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 25.sp),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                         child: PinCodeTextField(
//                           controller: pinCodeController,
//                           animationType: AnimationType.fade,
//                           pinTheme: PinTheme(
//                             shape: PinCodeFieldShape.box,
//                             borderRadius: BorderRadius.circular(5),
//                             fieldHeight: 50,
//                             fieldWidth: 50,
//                             inactiveColor: Colors.grey.withOpacity(0.5),
//                             activeColor: AppColors.primaryColor,
//                           ),
//                           length: 6,
//                           obscureText: false,
//                           animationDuration: const Duration(milliseconds: 300),
//                           onChanged: (value) {
//                             if (value.length == 6) {
//                               _verifyOtp();
//                             }
//                           },
//                           appContext: context,
//                         ),
//                       ),
//                       SizedBox(height: 10.sp),
//                       Text(
//                         "Auto Fetching OTP...",
//                         style: GoogleFonts.manrope(
//                           textStyle: TextStyle(
//                             color: Colors.black,
//                             fontSize: 12.sp,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 55.sp),
//                       BlocBuilder<AuthenticationBloc, AuthenticationState>(
//                         builder: (context, state) {
//                           return GestureDetector(
//                             onTap: _start > 0 ? null : _verifyOtp,
//                             child: state is AuthenticationLoading
//                                 ? const Center(
//                                     child: SizedBox(
//                                       height: 40,
//                                       child: CircularProgressIndicator(
//                                         color: AppColors.primaryColor,
//                                       ),
//                                     ),
//                                   )
//                                 : const CommonContainerButton(
//                                     labelText: "Continue",
//                                   ),
//                           );
//                         },
//                       ),
//                       SizedBox(height: 15.sp),
//                       RichText(
//                         text: TextSpan(
//                           children: [
//                             TextSpan(
//                               text: 'Resend OTP in ',
//                               style: GoogleFonts.manrope(
//                                 textStyle: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 15.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             TextSpan(
//                               text: '00:${_start.toString().padLeft(2, '0')}',
//                               style: GoogleFonts.manrope(
//                                 textStyle: TextStyle(
//                                   color: Colors.green,
//                                   fontSize: 15.sp,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                             TextSpan(
//                               text: _start == 0 ? ' RESEND' : '',
//                               style: GoogleFonts.manrope(
//                                 textStyle: TextStyle(
//                                   color: AppColors.primaryColor,
//                                   fontSize: 15.sp,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _verifyOtp() async {
//     if (pinCodeController.text.length != 6) {
//       showToast(
//         text: "Please enter a valid 6-digit OTP",
//         color: Colors.red,
//         context: context,
//       );
//       return;
//     }

//     final firebaseMessaging = FirebaseMessaging.instance;
//     final token = await firebaseMessaging.getToken();

//     if (token == null) {
//       showToast(
//         text: "Failed to get device token",
//         color: Colors.red,
//         context: context,
//       );
//       return;
//     }

//     context.read<AuthenticationBloc>().add(
//           OTPVerification(
//             otp: pinCodeController.text,
//             data: widget.data,
//             deviceToken: token,
//             phone: widget.phoneNumber,
//           ),
//         );
//   }
// }
