// import 'package:flutter/cupertino.dart';

// import '../../handler/responses/otp_login_response.dart';
// import '../../handler/responses/verify_otp_response.dart';

// @immutable
// abstract class AuthRepository {
//   Future<OTPLoginResponse?> getOTP(
//       String phoneNumber, String countryCode, String type);

//   Future<VerifyOtpResponse?> verifyOTP(
//       String otp, String data, String deviceToken, String phone);
// }

import 'package:flutter/cupertino.dart';

import '../../handler/responses/otp_login_response.dart';
import '../../handler/responses/verify_otp_response.dart';

@immutable
abstract class AuthRepository {
  Future<OTPLoginResponse?> getOTP(
      String phoneNumber, String countryCode, String type);

  Future<VerifyOtpResponse?> verifyOTP(
      String otp, String data, String deviceToken);
}
