import 'dart:convert';
import 'package:srisridrishti/handler/responses/onboard_response.dart';
import 'package:srisridrishti/handler/responses/profile_details_response.dart';
import 'package:srisridrishti/models/user_details_model.dart';
import 'package:srisridrishti/screens/profile/screens/profile_details_screen.dart';
import 'package:srisridrishti/utils/api_constants.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  final http.Client client;

  ProfileService({http.Client? httpClient})
      : client = httpClient ?? http.Client();
  Future<OnboardResponse> addProfileDetails({
    required String username,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String teacherId,
    required YesNoOption isArtOfLivingTeacher,
  }) async {
    try {
      final url = Uri.parse("http://10.0.2.2:8080/user/onBoard");
      String? token = await SharedPreferencesHelper.getAccessToken();

      Map<String, dynamic> body = {
        'userName': username,
        'name': fullName,
        'email': email,
        'mobileNo': phoneNumber,
        'role': 'user',
      };

      if (isArtOfLivingTeacher == YesNoOption.yes) {
        body['teacherId'] = teacherId;
      }

      print("🚀 Sending request to: $url");
      print("📦 Request Body: ${jsonEncode(body)}");
      print("🔑 Authorization: $token");

      final response =
          await client.patch(url, body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
        'Authorization': token ?? "",
      });

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return OnboardResponse(
          success: true,
          message: "User Added Successfully",
          data: UserDetailsModel.jsonToUserDetails(jsonBody['data']),
        );
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        print("❌ Error: $errorMessage");
        return OnboardResponse(
          success: false,
          message: errorMessage.toString(),
        );
      }
    } catch (e, stacktrace) {
      print("💥 Exception: $e");
      print("🛑 Stacktrace: $stacktrace");
      return OnboardResponse(
        success: false,
        message: 'Exception: $e',
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
