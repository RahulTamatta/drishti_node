import 'package:srisridrishti/screens/auth/screens/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> verifyPhoneNumber(String phoneNumber) async {
  await _auth.verifyPhoneNumber(
    phoneNumber: '+91$phoneNumber',
    verificationCompleted: (PhoneAuthCredential credential) async {
      // Auto-retrieve verification code
      print("GGG3");
      print(credential);
      await _auth.signInWithCredential(credential);
    },
    verificationFailed: (FirebaseAuthException e) {
      print("GGG");
      print(e);
      // Verification failed
    },
    codeSent: (String verificationId, int? resendToken) async {
      print("GGG2");
      print(verificationId);
      Get.to(OtpScreen(data: verificationId, phoneNumber: phoneNumber));
    },
    codeAutoRetrievalTimeout: (String verificationId) {},
    timeout: const Duration(seconds: 60),
  );
}

verifiedOtp(verificationId, sms) async {
  // Save the verification ID for future use
  String smsCode = sms; // Code input by the user
  PhoneAuthCredential credential = PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: smsCode,
  );
  // Sign the user in with the credential
  await _auth.signInWithCredential(credential);

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    //  String accessToken =
    //       state.data['data']!['accessToken'].toString();
    //   await SharedPreferencesHelper.saveAccessToken(accessToken);
    // Get.offAll(const BottomNav());
  });
}

signOut() async {
  await FirebaseAuth.instance.signOut();
}
