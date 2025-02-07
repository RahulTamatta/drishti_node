import 'package:srisridrishti/bloc/auth_bloc/authentication_bloc.dart';
import 'package:srisridrishti/screens/auth/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/show_toast.dart';
import '../../../widgets/common_container_button.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is GetOTPLoaded) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return OtpScreen(
                data: state.otpResponse.data?.verificationData ??
                    "", // Now a String
                phoneNumber: _phoneNumberController.text.toString(),
              );
            }));
          }
          if (state is GetOTPError) {
            showToast(
                text: state.otpResponse.errorMessage.toString(),
                color: Colors.red,
                context: context);
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  "assets/images/splash_image.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 13, right: 15, bottom: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Enter Mobile Number",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        "We will send code to your phone number to verify.",
                        style: GoogleFonts.manrope(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(height: 15.sp),
                      TextField(
                        controller: _phoneNumberController,
                        style: TextStyle(
                            letterSpacing: 1,
                            fontSize: 16.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Phone number",
                          hintStyle:
                              TextStyle(fontSize: 16.sp, color: Colors.black),
                          contentPadding: EdgeInsets.all(5.sp),
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      BlocBuilder<AuthenticationBloc, AuthenticationState>(
                        builder: (context, state) {
                          return GestureDetector(
                            onTap: () {
                              final String phoneNumber =
                                  _phoneNumberController.text;
                              if (validatePhoneNumber(phoneNumber)) {
                                context.read<AuthenticationBloc>().add(
                                      GetOTP(
                                          phone: phoneNumber,
                                          countryCode: "+91",
                                          type: "VERIFICATION"),
                                    );
                              } else {
                                showToast(
                                    text: "Please enter valid number!",
                                    color: Colors.red,
                                    context: context);
                              }
                            },
                            child: state is AuthenticationLoading
                                ? const Center(
                                    child: SizedBox(
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const CommonContainerButton(
                                    labelText: "Get OTP"),
                          );
                        },
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool validatePhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^\+?1?\d{9,15}$');
    return regex.hasMatch(phoneNumber);
  }
}
