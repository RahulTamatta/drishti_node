import 'dart:convert';

import 'package:srisridrishti/handler/responses/otp_login_response.dart';
import 'package:srisridrishti/handler/responses/verify_otp_response.dart';
import 'package:srisridrishti/services/auth_services/authentication_services.dart';

import 'package:http/http.dart' as http;
import 'package:srisridrishti/utils/api_constants.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'auth_repository.dart';

class AuthRepositoryImp extends AuthRepository {
  @override
  Future<OTPLoginResponse?> getOTP(
      String phoneNumber, String countryCode, String type) async {
    final otpResponse =
        await AuthenticationServices().getOTP(phoneNumber, countryCode, type);
    return otpResponse;
  }

  @override
  Future<VerifyOtpResponse?> verifyOTP(
      String otp, String phone, dynamic data, String deviceToken) async {
    try {
      print('Starting OTP Verification');
      print('OTP: $otp');
      print('Phone: $phone');
      print('Device Token: $deviceToken');

      final requestBody = json.encode({
        'otp': otp,
        'mobileNo': phone,
        'deviceToken': deviceToken,
        'data': data,
      });

      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(ApiConstants.loginVerify),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print('Parsed Response Body: $responseBody');

        final accessToken = responseBody['data']['data']['accessToken'];
        final refreshToken = responseBody['data']['data']['refreshToken'];
        final accessTokenExpiresAt =
            responseBody['data']['data']['accessTokenExpiresAt'];
        final refreshTokenExpiresAt =
            responseBody['data']['data']['refreshTokenExpiresAt'];

        print('Access Token: $accessToken');
        print('Refresh Token: $refreshToken');

        if (accessToken != null && refreshToken != null) {
          print('Saving Tokens');

          await SharedPreferencesHelper.saveAccessToken(accessToken);
          await SharedPreferencesHelper.saveRefreshToken(refreshToken);
          await SharedPreferencesHelper.saveAccessTokenExpiry(
              accessTokenExpiresAt);
          await SharedPreferencesHelper.saveRefreshTokenExpiry(
              refreshTokenExpiresAt);

          String? savedAccessToken =
              await SharedPreferencesHelper.getAccessToken();
          String? savedRefreshToken =
              await SharedPreferencesHelper.getRefreshToken();
          print('Saved Access Token: $savedAccessToken');
          print('Saved Refresh Token: $savedRefreshToken');
        }

        final verifyResponse = VerifyOtpResponse.fromJson(responseBody);
        print('Verify Response: ${verifyResponse.toString()}');

        return verifyResponse;
      }

      return VerifyOtpResponse(
        success: false,
        message: "Verification failed: ${response.statusCode}",
      );
    } catch (e) {
      print('OTP Verification Error: $e');
      return null;
    }
  }
}
