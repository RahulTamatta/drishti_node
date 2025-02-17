import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:srisridrishti/handler/responses/onboard_response.dart';
import 'package:srisridrishti/handler/responses/profile_details_response.dart';
import 'package:srisridrishti/models/user_details_model.dart';
import 'package:srisridrishti/screens/profile/screens/profile_details_screen.dart';
import 'package:srisridrishti/utils/api_constants.dart';
import 'package:srisridrishti/utils/logging.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ProfileService {
  final Dio _dio;

  ProfileService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://10.0.2.2:8080',
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
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
    required String username,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String teacherId,
    required YesNoOption isArtOfLivingTeacher,
    File? profileImageFile,
    File? teacherIdCardFile,
  }) async {
    try {
      print('=== Adding Profile START ===');

      String? token = await SharedPreferencesHelper.getAccessToken() ??
          await SharedPreferencesHelper.getRefreshToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final formData = FormData();

      // Add text fields
      formData.fields.addAll([
        MapEntry('userName', username),
        MapEntry('name', fullName),
        MapEntry('email', email),
        MapEntry('mobileNo', phoneNumber),
        MapEntry('role',
            isArtOfLivingTeacher == YesNoOption.yes ? 'teacher' : 'user'),
        MapEntry('bio', 'test'),
      ]);

      if (isArtOfLivingTeacher == YesNoOption.yes) {
        if (teacherId.isEmpty) {
          throw Exception('Teacher ID is required for teachers');
        }
        formData.fields.add(MapEntry('teacherId', teacherId));
      }

      // Handle profile image
      if (profileImageFile != null) {
        // Validate file size
        final fileSize = await profileImageFile.length();
        if (fileSize > 5 * 1024 * 1024) {
          // 5MB
          throw Exception('Profile image size must be less than 5MB');
        }

        // Compress image
        final compressedFile = await _compressImage(profileImageFile);
        final fileToUpload = compressedFile ?? profileImageFile;

        final mimeType = _getMimeType(fileToUpload.path);
        if (!['image/jpeg', 'image/png', 'image/jpg'].contains(mimeType)) {
          throw Exception('Invalid file type. Only JPG and PNG are allowed.');
        }

        formData.files.add(MapEntry(
          'profileImage',
          await MultipartFile.fromFile(
            fileToUpload.path,
            filename: path.basename(fileToUpload.path),
            contentType: _parseContentType(mimeType),
          ),
        ));
      }

      // Handle teacher ID card
      if (isArtOfLivingTeacher == YesNoOption.yes &&
          teacherIdCardFile != null) {
        // Similar validation and compression for teacher ID card
        final fileSize = await teacherIdCardFile.length();
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Teacher ID card size must be less than 5MB');
        }

        final compressedFile = await _compressImage(teacherIdCardFile);
        final fileToUpload = compressedFile ?? teacherIdCardFile;

        final mimeType = _getMimeType(fileToUpload.path);
        if (!['image/jpeg', 'image/png', 'image/jpg'].contains(mimeType)) {
          throw Exception('Invalid file type. Only JPG and PNG are allowed.');
        }

        formData.files.add(MapEntry(
          'teacherIdCard',
          await MultipartFile.fromFile(
            fileToUpload.path,
            filename: path.basename(fileToUpload.path),
            contentType: _parseContentType(mimeType),
          ),
        ));
      }

      // Make API request with timeout
      final response = await _dio.post(
        '/user/onBoard',
        data: formData,
        options: Options(
          headers: {
            'Authorization': token,
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        return OnboardResponse(
          success: true,
          message: response.data['message'],
          data: UserDetailsModel.jsonToUserDetails(response.data['data']),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Error in addProfileDetails: $e');
      return OnboardResponse(
        success: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ProfileDetailsResponse> getProfileDetails() async {
    try {
      String? token = await SharedPreferencesHelper.getAccessToken() ??
          await SharedPreferencesHelper.getRefreshToken();

      if (token == null) {
        print("No token available");
        return ProfileDetailsResponse(
          success: false,
          message: "No authentication token available",
          data: null,
        );
      }

      // Ensure token has Bearer prefix
      if (!token.startsWith('Bearer ')) {
        token = 'Bearer $token';
      }

      print("Token being sent: $token");

      final response = await _dio.get(
        ApiConstants.user,
        options: Options(
          headers: {
            'Authorization': token,
            'Content-Type': 'application/json',
          },
        ),
      );
      print('Raw API response: ${response.data}'); // Add this

      print("Raw response: ${response.data}");

      if (response.statusCode == 200) {
        final jsonBody = response.data;
        print("Response data: $jsonBody");

        if (jsonBody == null || jsonBody['data'] == null) {
          print("No data in response: $jsonBody");
          return ProfileDetailsResponse(
            success: false,
            message: "No user data received from server",
            data: null,
          );
        }

        final userDetails =
            UserDetailsModel.jsonToUserDetails(jsonBody['data']);
        print("Parsed user details: ${userDetails.toJson()}");

        return ProfileDetailsResponse(
          success: true,
          message: jsonBody['message'] ?? "Profile Details Fetched",
          data: userDetails,
        );
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to fetch profile';
        print("Error response: $errorMessage");

        return ProfileDetailsResponse(
          success: false,
          message: errorMessage.toString(),
          data: null,
        );
      }
    } catch (e, stackTrace) {
      print("Error in getProfileDetails: $e");
      print("Stack trace: $stackTrace");
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
