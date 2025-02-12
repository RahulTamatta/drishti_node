import 'dart:async';
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

  Future<VerifyOtpResponse?> verifyOTP(
      String otp, String data, String deviceToken) async {
    try {
      print('Starting OTP Verification');

      final requestBody = {
        'otp': otp,
        'deviceToken': deviceToken,
        'data': data,
      };

      print('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(ApiConstants.loginVerify),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Full Response Body: $responseBody');

        final verifyResponse = VerifyOtpResponse.fromJson(responseBody);

        if (verifyResponse.data?.accessToken == null ||
            verifyResponse.data?.refreshToken == null) {
          print('Response data structure: ${json.encode(responseBody)}');
          throw Exception('Token data missing or invalid');
        }

        // Save tokens
        await SharedPreferencesHelper.saveAccessToken(
            verifyResponse.data!.accessToken!);
        await SharedPreferencesHelper.saveRefreshToken(
            verifyResponse.data!.refreshToken!);

        // Save expiry times if available
        if (verifyResponse.data?.accessTokenExpiresAt != null) {
          await SharedPreferencesHelper.saveAccessTokenExpiry(
              verifyResponse.data!.accessTokenExpiresAt!);
        }
        if (verifyResponse.data?.refreshTokenExpiresAt != null) {
          await SharedPreferencesHelper.saveRefreshTokenExpiry(
              verifyResponse.data!.refreshTokenExpiresAt!);
        }

        return verifyResponse;
      } else {
        print('Error response: ${response.body}');
        final errorBody = jsonDecode(response.body);
        return VerifyOtpResponse(
          success: false,
          message: errorBody['message'] ??
              "Verification failed: ${response.statusCode}",
        );
      }
    } catch (e, stackTrace) {
      print('OTP Verification Error: $e');
      print('Stack trace: $stackTrace');
      return VerifyOtpResponse(
        success: false,
        message: "Error: ${e.toString()}",
      );
    }
  }
}
