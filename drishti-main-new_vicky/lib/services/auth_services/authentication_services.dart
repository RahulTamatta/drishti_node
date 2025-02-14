import 'dart:async';
import 'dart:convert';
import 'package:srisridrishti/repos/auth_repo/encrytion';
import 'package:srisridrishti/utils/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import '../../handler/responses/otp_login_response.dart';
import '../../handler/responses/verify_otp_response.dart';
import '../../models/otp_model.dart';
import '../../utils/logging.dart';

class AuthenticationServices {
  final http.Client client;

  AuthenticationServices({http.Client? httpClient})
      : client = httpClient ?? http.Client();
  Future<OTPLoginResponse?> getOTP(
      String phone, String countryCode, String type) async {
    final Map<String, dynamic> requestBody = {
      "mobileNo": phone,
      "countryCode": countryCode,
      "type": type
    };
    final String rawBody = jsonEncode(requestBody);

    try {
      final http.Response response = await client
          .post(
            Uri.parse(ApiConstants.loginUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: rawBody,
          )
          .timeout(const Duration(seconds: 30));

      // Inside AuthenticationService's getOTP method
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Processing 200 success response");
        return OTPLoginResponse(
          success: true,
          errorMessage: "",
          message: data['message'] is String
              ? data['message']
              : data['message'].toString(),
          data: data['data'] != null ? OtpData.fromJson(data['data']) : null,
        );
      } else if (response.statusCode == 409) {
        // Handle the 409 Conflict error
        var data = jsonDecode(response.body);
        return OTPLoginResponse(
          success: false,
          errorMessage:
              'Conflict: ${data['message'] ?? 'An OTP has already been sent recently'}',
          message: data['message'],
          data: null,
        );
      } else {
        logError(
            'Failed to get OTP: ${response.statusCode} ${response.reasonPhrase}');
        return OTPLoginResponse(
          success: false,
          errorMessage:
              'Failed to get OTP: ${response.statusCode} ${response.reasonPhrase}',
          message: null,
          data: null,
        );
      }
    } on http.ClientException catch (e) {
      logError('Client exception: $e');
      return OTPLoginResponse(
        success: false,
        errorMessage: 'Client exception: $e',
        message: null,
        data: null,
      );
    } on TimeoutException catch (e) {
      logError('Request timeout: $e');
      return OTPLoginResponse(
        success: false,
        errorMessage: 'Request timeout: $e',
        message: null,
        data: null,
      );
    } catch (e) {
      logError('Unexpected error: $e');
      return OTPLoginResponse(
        success: false,
        errorMessage: 'Unexpected error: $e',
        message: null,
        data: null,
      );
    }
  }

  Future<VerifyOtpResponse?> verifyOTP(String otp, String phone,
      String encryptedData, String deviceToken) async {
    try {
      // Decrypt the data
      print('Encrypted data received: $encryptedData');
      final decryptedData = EncryptionUtil.decryptData(encryptedData);
      print('Decrypted data: $decryptedData');

      Map<String, dynamic> decodedObj;
      try {
        decodedObj = json.decode(decryptedData);
      } catch (e) {
        print('JSON parse error: $e');
        return VerifyOtpResponse(
          success: false,
          message: "Invalid encrypted data format",
        );
      }

      final String? accessToken =
          await SharedPreferencesHelper.getAccessToken();
      final String? refreshToken =
          await SharedPreferencesHelper.getRefreshToken();

      final response = await client.post(
        Uri.parse(ApiConstants.loginVerify),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'otp': otp,
          'mobileNo': phone,
          'deviceToken': deviceToken,
          'data': decodedObj, // Send decoded data
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return VerifyOtpResponse.fromJson(responseData);
      } else if (response.statusCode == 401 && refreshToken != null) {
        return _handleTokenExpiration(otp, phone, decodedObj, deviceToken);
      } else {
        return VerifyOtpResponse(
          success: false,
          message: "Verification failed: ${response.statusCode}",
        );
      }
    } catch (e) {
      print('Verification error: $e');
      return VerifyOtpResponse(
        success: false,
        message: "Error during verification: $e",
      );
    }
  }

  Future<VerifyOtpResponse?> _handleTokenExpiration(
      String otp, String phone, dynamic data, String deviceToken) async {
    String? refreshToken = await SharedPreferencesHelper.getRefreshToken();

    if (refreshToken == null) {
      return VerifyOtpResponse(
          success: false, message: "Session expired, please log in again");
    }

    try {
      final http.Response refreshResponse = await client
          .post(
            Uri.parse(
                ApiConstants.refreshToken), // Dedicated refresh token endpoint
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 30));

      if (refreshResponse.statusCode == 200) {
        var refreshData = jsonDecode(refreshResponse.body);
        if (refreshData['success'] == true) {
          // Check for success in the response.
          String newAccessToken = refreshData['data']['accessToken'];
          String newRefreshToken = refreshData['data']['refreshToken'];
          String accessTokenExpire =
              refreshData['data']['accessTokenExpiresAt'];
          String refreshTokenExpire =
              refreshData['data']['refreshTokenExpiresAt'];

          await SharedPreferencesHelper.saveAccessToken(newAccessToken);
          await SharedPreferencesHelper.saveAccessTokenExpiry(
              accessTokenExpire);
          await SharedPreferencesHelper.saveRefreshToken(newRefreshToken);
          await SharedPreferencesHelper.saveRefreshTokenExpiry(
              refreshTokenExpire);

          // Retry the original OTP verification with the new access token
          return verifyOTP(otp, phone, data, deviceToken);
        } else {
          // Refresh failed, clear tokens and return error
          await SharedPreferencesHelper.clearAccessToken();
          await SharedPreferencesHelper.clearRefreshToken();
          return VerifyOtpResponse(
              success: false,
              message: refreshData['message'] ?? "Refresh token failed");
        }
      } else {
        // Refresh failed, clear tokens and return error
        await SharedPreferencesHelper.clearAccessToken();
        await SharedPreferencesHelper.clearRefreshToken();
        return VerifyOtpResponse(
            success: false,
            message:
                "Refresh token request failed: ${refreshResponse.statusCode}");
      }
    } on TimeoutException catch (e) {
      return VerifyOtpResponse(
          success: false, message: "Refresh token request timed out: $e");
    } catch (e) {
      return VerifyOtpResponse(
          success: false, message: "Error refreshing token: $e");
    }
  }
}
