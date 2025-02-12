import 'dart:async';
import 'dart:convert';
import 'package:srisridrishti/handler/responses/onboard_response.dart';
import 'package:srisridrishti/handler/responses/profile_details_response.dart';
import 'package:srisridrishti/models/user_details_model.dart';
import 'package:srisridrishti/screens/profile/screens/profile_details_screen.dart';
import 'package:srisridrishti/utils/api_constants.dart';
import 'package:srisridrishti/utils/logging.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  final http.Client client;

  ProfileService({http.Client? httpClient})
      : client = httpClient ?? http.Client();
  Future<OnboardResponse?> addProfileDetails({
    required String username,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String teacherId,
    required YesNoOption isArtOfLivingTeacher,
  }) async {
    // Build the request body
    final Map<String, dynamic> requestBody = {
      'userName': username,
      'name': fullName,
      'email': email,
      'mobileNo': phoneNumber,
      'role': 'user',
      'bio': 'test', // added to satisfy server expectation
    };

    // Include teacherId only if applicable
    if (isArtOfLivingTeacher == YesNoOption.yes) {
      requestBody['teacherId'] = teacherId;
    }

    print("🚀 Request Body: $requestBody");

    // JSON encode the request body
    final String rawBody = jsonEncode(requestBody);

    try {
      String? token = await SharedPreferencesHelper.getAccessToken();
      print(
          "🔑 Retrieved Token from SharedPreferences: $token"); // ADD THIS LINE
      final http.Response response = await client
          .post(
            Uri.parse("http://10.0.2.2:8080/user/onBoard"),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer ${token.toString()}'
            },
            body: rawBody,
          )
          .timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        OnboardResponse onboardResponse = OnboardResponse(
          success: true,
          message: data['message'],
          data: UserDetailsModel.jsonToUserDetails(data['data']),
        );
        return onboardResponse;
      } else {
        logError(
            'Failed to add profile details: ${response.statusCode} ${response.reasonPhrase}');
        return OnboardResponse(
          success: false,
          message:
              'Failed to add profile details: ${response.statusCode} ${response.reasonPhrase}',
          data: null,
        );
      }
    } on http.ClientException catch (e) {
      logError('Client exception: $e');
      return OnboardResponse(
        success: false,
        message: 'Client exception: $e',
        data: null,
      );
    } on TimeoutException catch (e) {
      logError('Request timeout: $e');
      return OnboardResponse(
        success: false,
        message: 'Request timeout: $e',
        data: null,
      );
    } catch (e) {
      logError('Unexpected error: $e');
      return OnboardResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  Future<ProfileDetailsResponse> getProfileDetails() async {
    try {
      final url = Uri.parse(ApiConstants.user);
      String? token = await SharedPreferencesHelper.getAccessToken();

      print("Token: $token");

      print("/user");
      print(token);
      final response = await client.get(url, headers: {
        'Authorization': token ?? "",
      });

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        print(jsonBody);
        return ProfileDetailsResponse(
            success: true,
            message: "Profile Details Fetched",
            data: UserDetailsModel.jsonToUserDetails(jsonBody['data']));
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        return ProfileDetailsResponse(
          success: false,
          message: errorMessage.toString(),
          data: null,
        );
      }
    } catch (e) {
      return ProfileDetailsResponse(
          success: false, message: 'Exception: $e', data: null);
    }
  }

  Future<ProfileDetailsResponse> updateProfileDetails(
      UserDetailsModel updatedProfile) async {
    print("hiiii1");
    try {
      final url = Uri.parse('${ApiConstants.user}/${updatedProfile.id}');

      final response = await client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedProfile.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return ProfileDetailsResponse(
          success: true,
          message: "Profile Updated Successfully",
          data: UserDetailsModel.jsonToUserDetails(jsonBody['data']),
        );
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        return ProfileDetailsResponse(
          success: false,
          message: errorMessage.toString(),
          data: null,
        );
      }
    } catch (e) {
      return ProfileDetailsResponse(
        success: false,
        message: 'Exception: $e',
        data: null,
      );
    }
  }

  Future<ProfileDetailsResponse> deleteProfile() async {
    try {
      final url = Uri.parse(ApiConstants.user);
      String? token = await SharedPreferencesHelper.getAccessToken();
      print("Token: $token");

      final response = await client.delete(
        url,
        headers: {
          'Authorization': token ?? "",
        },
      );

      if (response.statusCode == 200) {
        return ProfileDetailsResponse(
          success: true,
          message: "Profile Deleted Successfully",
          data: null,
        );
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        return ProfileDetailsResponse(
          success: false,
          message: errorMessage.toString(),
          data: null,
        );
      }
    } catch (e) {
      return ProfileDetailsResponse(
        success: false,
        message: 'Exception: $e',
        data: null,
      );
    }
  }
}
