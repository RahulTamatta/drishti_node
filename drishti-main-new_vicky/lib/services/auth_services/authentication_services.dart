import 'dart:async';
import 'dart:convert';
import 'package:srisridrishti/services/auth_services/token_service.dart';
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

  Future<VerifyOtpResponse?> verifyOTP(
      String otp, String phone, dynamic data, String deviceToken) async {
    String? accessToken = await SharedPreferencesHelper.getAccessToken();
    String? refreshToken = await SharedPreferencesHelper.getRefreshToken();

    try {
      final http.Response response = await client
          .post(
            Uri.parse(ApiConstants.loginVerify),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'otp': otp,
              'mobileNo': phone,
              'deviceToken': deviceToken,
              'data': data,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Successful response, return the VerifyOtpResponse
        return VerifyOtpResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        // If access token is expired, try refreshing it
        return _handleTokenExpiration(
            refreshToken, otp, phone, data, deviceToken);
      } else {
        return VerifyOtpResponse(
          success: false,
          message:
              "Verification failed with status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      return VerifyOtpResponse(
        success: false,
        message: "Error: $e",
      );
    }
  }

  Future<VerifyOtpResponse?> _handleTokenExpiration(String? refreshToken,
      String otp, String phone, dynamic data, String deviceToken) async {
    if (refreshToken == null) {
      // Handle the case when refresh token is also not available
      return VerifyOtpResponse(
          success: false, message: "Session expired, please log in again");
    }

    try {
      // Use verify API to refresh the access token using the refresh token
      final http.Response refreshResponse = await client
          .post(
            Uri.parse(ApiConstants
                .loginVerify), // Using the same verify URL for token refresh
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 30));

      if (refreshResponse.statusCode == 200) {
        // New tokens returned, save them using SharedPreferencesHelper directly
        var refreshData = jsonDecode(refreshResponse.body);
        String newAccessToken = refreshData['accessToken'];
        String newRefreshToken = refreshData['refreshToken'];
        String accessTokenExpire = refreshData['accessTokenExpire'];
        String refreshTokenExpire = refreshData['refreshTokenExpire'];

        // Save access token and its expiry, refresh token and its expiry separately
        await SharedPreferencesHelper.saveAccessToken(newAccessToken);
        await SharedPreferencesHelper.saveAccessTokenExpiry(accessTokenExpire);
        await SharedPreferencesHelper.saveRefreshToken(newRefreshToken);
        await SharedPreferencesHelper.saveRefreshTokenExpiry(
            refreshTokenExpire);

        // Retry the original OTP verification with the new access token
        return verifyOTP(otp, phone, data, deviceToken);
      } else {
        return VerifyOtpResponse(
            success: false, message: "Session expired, please log in again");
      }
    } catch (e) {
      return VerifyOtpResponse(
          success: false, message: "Error refreshing token: $e");
    }
  }
}
