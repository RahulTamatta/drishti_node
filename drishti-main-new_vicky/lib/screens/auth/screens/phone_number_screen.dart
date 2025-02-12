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
  String countryCode = "+91"; // Store country code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is GetOTPLoaded) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OtpScreen(
                data: state.otpResponse.data?.verificationData ?? "",
                phoneNumber: _phoneNumberController.text.toString(),
                // countryCode: countryCode, // Pass country code to OTP screen
              ),
            ));
          }
          if (state is GetOTPError) {
            showToast(
              text: state.otpResponse.errorMessage.toString(),
              color: Colors.red,
              context: context,
            );
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
            Padding(
              // Use Padding widget to wrap the Column
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 24), // Adjust padding as needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
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
                  SizedBox(height: 24.sp), // Increased spacing
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8), // Adjust padding as needed
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(countryCode,
                            style: TextStyle(
                                fontSize: 16
                                    .sp)), // Display and potentially allow change
                      ),
                      SizedBox(
                          width: 16
                              .sp), // Spacing between country code and phone number
                      Expanded(
                        // Use Expanded to take up remaining space
                        child: TextField(
                          controller: _phoneNumberController,
                          style: TextStyle(
                              letterSpacing: 1,
                              fontSize: 16.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                          maxLength: 10,
                          keyboardType:
                              TextInputType.phone, // Use TextInputType.phone
                          decoration: InputDecoration(
                            hintText: "Phone number",
                            hintStyle:
                                TextStyle(fontSize: 16.sp, color: Colors.black),
                            contentPadding:
                                EdgeInsets.all(12.sp), // Increased Padding
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors
                                      .black), // Keep border color consistent
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24), // Increased spacing
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
                                    countryCode:
                                        countryCode, // Use stored country code
                                    type: "VERIFICATION",
                                  ),
                                );
                          } else {
                            showToast(
                                text: "Please enter a valid 10-digit number!",
                                color: Colors.red,
                                context: context);
                          }
                        },
                        child: state is AuthenticationLoading
                            ? const Center(
                                child: SizedBox(
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    color:
                                        Colors.black, // Match indicator color
                                  ),
                                ),
                              )
                            : const CommonContainerButton(
                                labelText: "Get OTP",
                                // Set text color
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool validatePhoneNumber(String phoneNumber) {
    // Improved regex for a 10 digit number
    final regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(phoneNumber);
  }
}
