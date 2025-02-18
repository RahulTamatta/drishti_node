import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:srisridrishti/handler/responses/onboard_response.dart';
import 'package:srisridrishti/handler/responses/profile_details_response.dart';
import 'package:srisridrishti/models/user_details_model.dart';
import 'package:srisridrishti/screens/profile/screens/profile_details_screen.dart';
import 'package:srisridrishti/utils/api_constants.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';

class ProfileService {
  final Dio _dio;

  ProfileService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            ));

  String _getMimeType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  MediaType? _parseContentType(String mimeType) {
    final parts = mimeType.split('/');
    if (parts.length == 2) {
      return MediaType(parts[0], parts[1]);
    }
    return null;
  }

  Future<File?> _compressImage(File file) async {
    try {
      final filePath = file.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
      final splitted = filePath.substring(0, lastIndex);
      final outPath = "${splitted}_compressed.jpg";

      final compressedBytes = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 1000,
        minHeight: 1000,
        quality: 85,
      );

      if (compressedBytes == null) return null;

      final compressedFile = File(outPath)..writeAsBytesSync(compressedBytes);
      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  Future<OnboardResponse?> addProfileDetails({
    required String userName,  // Changed from username to userName
    required String fullName,
    required String email,
    required String phoneNumber,
    required String teacherId,
    required YesNoOption isArtOfLivingTeacher,
    File? profileImageFile,
    File? teacherIdCardFile,
  }) async {
    try {
      // Validate input
      if (userName.isEmpty ||
          fullName.isEmpty ||
          email.isEmpty ||
          phoneNumber.isEmpty) {
        return OnboardResponse(
          success: false,
          message: 'All fields are required',
          data: null,
        );
      }

      // Get authentication token
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        return OnboardResponse(
          success: false,
          message: 'Authentication failed',
          data: null,
        );
      }

      final formData = FormData();

      // Add basic profile data
      formData.fields.addAll([
        MapEntry('userName', userName),  // Using consistent field name
        MapEntry('name', fullName),
        MapEntry('email', email),
        MapEntry('mobileNo', phoneNumber),
        MapEntry('role',
            isArtOfLivingTeacher == YesNoOption.yes ? 'teacher' : 'user'),
      ]);

      // Process profile image
      if (profileImageFile != null) {
        await _addImageToFormData(formData, profileImageFile, 'profileImage');
      }

      // Handle teacher specific data
      if (isArtOfLivingTeacher == YesNoOption.yes) {
        formData.fields.add(MapEntry('teacherId', teacherId));
        if (teacherIdCardFile != null) {
          await _addImageToFormData(
              formData, teacherIdCardFile, 'teacherIdCard');
        }
      }

      // Make API request
      final response = await _dio.post(
        '/user/onBoard',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return OnboardResponse(
          success: true,
          message: response.data['message'] ?? 'Profile created successfully',
          data: UserDetailsModel.jsonToUserDetails(response.data['data']),
        );
      }

      throw Exception(response.data['message'] ?? 'Failed to create profile');
    } on DioError catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return OnboardResponse(
        success: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<void> _addImageToFormData(
      FormData formData, File file, String fieldName) async {
    final compressedFile = await _compressImage(file);
    final fileToUpload = compressedFile ?? file;

    final mimeType = _getMimeType(fileToUpload.path);
    if (!['image/jpeg', 'image/png'].contains(mimeType)) {
      throw Exception('Invalid file type. Only JPG and PNG are allowed.');
    }

    formData.files.add(MapEntry(
      fieldName,
      await MultipartFile.fromFile(
        fileToUpload.path,
        filename: path.basename(fileToUpload.path),
        contentType: _parseContentType(mimeType),
      ),
    ));
  }

  OnboardResponse _handleDioError(DioError e) {
    String message;
    switch (e.type) {
      case DioErrorType.connectionTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioErrorType.badResponse:
        message = e.response?.data['message'] ?? 'Server error';
        break;
      default:
        message = 'An unexpected error occurred';
    }
    return OnboardResponse(success: false, message: message, data: null);
  }

  Future<ProfileDetailsResponse> getProfileDetails() async {
    try {
      print('Fetching profile details...');

      String? token = await SharedPreferencesHelper.getActiveToken();
      if (token == null) {
        print('No valid authentication token found');
        return ProfileDetailsResponse(
          success: false,
          message: "Authentication failed",
          data: null,
        );
      }

      print('Making API request with token: ${token.substring(0, 20)}...');
      final response = await _dio.get(
        ApiConstants.user,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> jsonBody = response.data;
        print('Full response body: $jsonBody');

        if (jsonBody['data'] != null) {
          try {
            // Transform the data to ensure id field is present
            final Map<String, dynamic> userData = Map<String, dynamic>.from(jsonBody['data']);
            
            // Handle both _id and id fields
            if (userData['_id'] != null && userData['id'] == null) {
              userData['id'] = userData['_id'];
            }

            print('Transformed user data before parsing: $userData');
            final userModel = UserDetailsModel.fromJson(userData);
            print('Parsed user model: ${userModel.toJson()}');

            return ProfileDetailsResponse(
              success: true,
              message: jsonBody['message'] ?? "Profile retrieved successfully",
              data: userModel,
            );
          } catch (e, stackTrace) {
            print('Error parsing user data: $e');
            print('Stack trace: $stackTrace');
            print('Raw user data: ${jsonBody['data']}');
            return ProfileDetailsResponse(
              success: false,
              message: "Error parsing profile data: ${e.toString()}",
              data: null,
            );
          }
        } else {
          print('Response data is empty or null: ${jsonBody}');
          return ProfileDetailsResponse(
            success: false,
            message: "No profile data found",
            data: null,
          );
        }
      }

      // Add a default return for when response status code is not 200
      return ProfileDetailsResponse(
        success: false,
        message: "Unexpected response: ${response.statusCode}",
        data: null,
      );
    } on DioException catch (e) {
      print('DioException in getProfileDetails: ${e.message}');
      if (e.response?.statusCode == 401) {
        // Try to refresh token
        final newToken = await SharedPreferencesHelper.getActiveToken();
        if (newToken != null) {
          // Retry the request with new token
          return getProfileDetails();
        }
        return ProfileDetailsResponse(
          success: false,
          message: "Authentication failed",
          data: null,
        );
      }
      return ProfileDetailsResponse(
        success: false,
        message: e.message ?? "Network error occurred",
        data: null,
      );
    } catch (e) {
      print('Error in getProfileDetails: $e');
      return ProfileDetailsResponse(
        success: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ProfileDetailsResponse> updateProfile(
      UserDetailsModel updatedProfile) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.user}/${updatedProfile.id}',
        data: updatedProfile.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonBody = response.data;
        return ProfileDetailsResponse(
          success: true,
          message: "Profile Updated Successfully",
          data: UserDetailsModel.jsonToUserDetails(jsonBody['data']),
        );
      } else {
        final errorMessage = response.data['message'];
        return ProfileDetailsResponse(
          success: false,
          message: errorMessage.toString(),
          data: null,
        );
      }
    } catch (e) {
      return ProfileDetailsResponse(
        success: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ProfileDetailsResponse> deleteProfile() async {
    try {
      String? token = await SharedPreferencesHelper.getAccessToken() ??
          await SharedPreferencesHelper.getRefreshToken();
      print("Token: $token");

      final response = await _dio.delete(
        ApiConstants.user,
        options: Options(
          headers: {
            'Authorization': token ?? "",
          },
        ),
      );

      if (response.statusCode == 200) {
        return ProfileDetailsResponse(
          success: true,
          message: "Profile Deleted Successfully",
          data: null,
        );
      } else {
        final errorMessage = response.data['message'];
        return ProfileDetailsResponse(
          success: false,
          message: errorMessage.toString(),
          data: null,
        );
      }
    } catch (e) {
      return ProfileDetailsResponse(
        success: false,
        message: e.toString(),
        data: null,
      );
    }
  }
}
