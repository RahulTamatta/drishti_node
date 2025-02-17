import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:srisridrishti/models/otp_model.dart';
import 'package:srisridrishti/utils/api_constants.dart';

class AuthenticationService {
  final http.Client _client = http.Client();

  Future<OTPLoginResponse?> getOTP(
      String phone, String countryCode, String type) async {
    print("=== Starting getOTP function ===");
    print(
        "Input params - phone: $phone, countryCode: $countryCode, type: $type");

    final Map<String, dynamic> requestBody = {
      "mobileNo": phone,
      "countryCode": countryCode,
      "type": type
    };
    final String rawBody = jsonEncode(requestBody);
    print("Request body: $rawBody");

    try {
      print("Making HTTP request to: ${ApiConstants.loginUrl}");
      final http.Response response = await _client
          .post(
            Uri.parse(ApiConstants.loginUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: rawBody,
          )
          .timeout(const Duration(seconds: 30));

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      Map<String, dynamic> data = jsonDecode(response.body);
      print("Decoded data type: ${data.runtimeType}");
      print("Message field type: ${data['message']?.runtimeType}");
      print("Raw message value: ${data['message']}");

      if (response.statusCode == 200) {
        print("Processing 200 success response");
        return OTPLoginResponse(
          success: true,
          errorMessage: "",
          message: data['message'],
          data: data['data'] != null ? OtpData.fromJson(data['data']) : null,
        );
      } else if (response.statusCode == 409) {
        print("Processing 409 conflict response");
        return OTPLoginResponse(
          success: false,
          errorMessage: 'Conflict: ${data['message']}',
          message: data['message'],
          data: null,
        );
      } else {
        print("Processing error response with status: ${response.statusCode}");
        return OTPLoginResponse(
          success: false,
          errorMessage:
              'Failed to get OTP: ${response.statusCode} ${response.reasonPhrase}',
          message: null,
          data: null,
        );
      }
    } on FormatException catch (e) {
      print("JSON parsing error: $e");
      return OTPLoginResponse(
        success: false,
        errorMessage: 'Invalid response format: $e',
        message: null,
        data: null,
      );
    } on http.ClientException catch (e) {
      print("HTTP client error: $e");
      return OTPLoginResponse(
        success: false,
        errorMessage: 'Network error: $e',
        message: null,
        data: null,
      );
    } on TimeoutException catch (e) {
      print("Request timeout: $e");
      return OTPLoginResponse(
        success: false,
        errorMessage: 'Request timeout: $e',
        message: null,
        data: null,
      );
    } catch (e, stackTrace) {
      print("Caught unexpected error: $e");
      print("Stack trace: $stackTrace");
      return OTPLoginResponse(
        success: false,
        errorMessage: 'System error: $e',
        message: null,
        data: null,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class OTPLoginResponse {
  final bool success;
  final String? errorMessage;
  final String? message;
  final OtpData? data;

  OTPLoginResponse({
    required this.success,
    this.errorMessage,
    this.message,
    this.data,
  });
}
