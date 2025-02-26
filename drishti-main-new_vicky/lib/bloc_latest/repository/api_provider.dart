import 'package:dio/dio.dart';
import 'package:srisridrishti/bloc_latest/repository/server_error.dart';
import 'package:srisridrishti/bloc_latest/retrofit/rest_client.dart';
import 'package:logger/logger.dart';
import 'package:srisridrishti/interceptors/token_interceptor.dart';
// ignore: depend_on_referenced_packages
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'base_model.dart';
// import 'server_error.dart';
// import '../repos/auth_repo/encrytion.dart';

class ApiProvider {
  static final ApiProvider _singleton = ApiProvider._internal();
  static Dio? _dio;
  static RestClient? apiClient;

  factory ApiProvider() {
    return _singleton;
  }

  ApiProvider._internal() {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: 'http://10.0.2.2:8080',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));

      // Add token interceptor
      _dio!.interceptors.add(TokenInterceptor(_dio!));

      apiClient = RestClient(dio: _dio!);
    }
  }

  Future<BaseModel<dynamic>> getNotificationById(
      dynamic id, dynamic token) async {
    var logger = Logger();
    dynamic response;
    try {
      String? token = await SharedPreferencesHelper.getAccessToken();
      print("Access token $token");
      response = await apiClient!.getNotificationByID(id, token);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel> addProfile(FormData formData) async {
    try {
      print('=== Adding Profile START ===');

      // Log all fields in the form data
      print('Form Data Fields:');
      for (var field in formData.fields) {
        print('  ${field.key}: ${field.value}');
      }

      // Log all files in the form data
      print('Form Data Files:');
      for (var file in formData.files) {
        print('  ${file.key}: ${file.value.filename}');
      }

      // Check if 'userName' is present and not empty
      bool hasUserName = formData.fields
          .any((field) => field.key == 'userName' && field.value.isNotEmpty);
      if (!hasUserName) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: 'userName is required and cannot be empty',
        );
      } else {
        print("'userName' is present in the payload.");
        String userName = formData.fields
            .firstWhere((field) => field.key == 'userName',
                orElse: () => MapEntry('', ''))
            .value;
        print("'userName' value: $userName");
      }

      // Get token and validate
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: 'Authentication token is missing',
        );
      }
      print('Authorization Token: $token');

      // Validate required fields before making request
      bool hasRequiredFields = formData.fields.any(
              (field) => field.key == 'userName' && field.value.isNotEmpty) &&
          formData.fields
              .any((field) => field.key == 'name' && field.value.isNotEmpty);

      if (!hasRequiredFields) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: 'userName and name are required fields',
        );
      }

      // Check if teacher role has required fields
      bool isTeacher = formData.fields
          .any((field) => field.key == 'role' && field.value == 'teacher');

      if (isTeacher) {
        bool hasTeacherId = formData.fields
            .any((field) => field.key == 'teacherId' && field.value.isNotEmpty);
        bool hasTeacherIdCard =
            formData.files.any((file) => file.key == 'teacherIdCard');

        if (!hasTeacherId || !hasTeacherIdCard) {
          throw DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Teacher ID and ID Card are required for teacher role',
          );
        }
      }

      // Create proper headers with correct content type
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json', // Remove 'Content-Type' from here
      };

      // Reconstruct form data to ensure proper formatting
      final newFormData = FormData();

      // Add text fields first
      for (var field in formData.fields) {
        newFormData.fields.add(MapEntry(field.key, field.value));
      }

      // Add files
      for (var file in formData.files) {
        newFormData.files.add(MapEntry(file.key, file.value));
      }

      // Log the final form data
      print('=== Final Form Data ===');
      print('Fields:');
      for (var field in newFormData.fields) {
        print('  ${field.key}: ${field.value}');
      }
      print('Files:');
      for (var file in newFormData.files) {
        print('  ${file.key}: ${file.value.filename}');
      }

      // Make the API request
      final response = await _dio?.post(
        '/user/onBoard',
        data: newFormData,
        options: Options(
          headers: headers,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Response Status: ${response?.statusCode}');
      print('Response Data: ${response?.data}');

      // Handle different response status codes
      if (response?.statusCode == 422) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: response?.data['message'] ?? 'Validation failed',
        );
      }

      if (response?.statusCode != 200) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: response?.data['message'] ?? 'Request failed',
        );
      }

      return BaseModel()..data = response?.data;
    } catch (error) {
      print('=== Add Profile ERROR ===');
      print('Error Type: ${error.runtimeType}');
      print('Error Details: $error');

      return BaseModel()
        ..setException(ServerError.withError(
          error: error is DioException
              ? error
              : DioException(
                  requestOptions: RequestOptions(path: ''),
                  error: error,
                ),
        ));
    }
  }

  Future<BaseModel> updateProfile(
      FormData add, Map<String, dynamic> header, String id) async {
    var logger = Logger();
    try {
      // Validate input
      if (id.isEmpty) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: 'User ID is required',
        );
      }

      // Create proper headers with type safety
      final Map<String, dynamic> headers = {
        ...Map<String, dynamic>.from(header),
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      };

      // Make API request
      final response = await _dio?.put(
        '/user/$id',
        data: add,
        options: Options(
          headers: headers,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response?.statusCode != 200) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: response?.data['message'] ?? 'Update failed',
        );
      }

      return BaseModel()..data = response?.data;
    } catch (error, stacktrace) {
      logger.f("Exception occurred:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(
          error: error is DioException
              ? error
              : DioException(
                  requestOptions: RequestOptions(path: ''),
                  error: error,
                ),
        ));
    }
  }

  Future<BaseModel<dynamic>> notifyMe(dynamic id, dynamic header) async {
    var logger = Logger();
    dynamic response;
    try {
      response = await apiClient!.notifyMe(id, header);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<dynamic>> nearByEvent(dynamic add) async {
    var logger = Logger();
    dynamic response;
    try {
      response = await apiClient!.nearByEvent(add);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<dynamic>> nearUser(Map<String, dynamic> location) async {
    var logger = Logger();
    try {
      final response = await apiClient!.nearByUser(location);
      return BaseModel()..data = response;
    } catch (error, stacktrace) {
      logger.e("Get nearby users error:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
  }

  Future<BaseModel<dynamic>> createAddress(dynamic add) async {
    var logger = Logger();
    dynamic response;
    try {
      response = await apiClient!.createAddress(add);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<dynamic>> updateUserLocation(
      dynamic add, final dynamic header) async {
    var logger = Logger();
    dynamic response;
    try {
      response = await apiClient!.updateUserLocation(add, header);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<dynamic>> deleteAddress(dynamic id) async {
    var logger = Logger();
    dynamic response;
    try {
      response = await apiClient!.deleteAddress(id);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<dynamic>> editAddress(dynamic id, add) async {
    var logger = Logger();
    dynamic response;
    try {
      response = await apiClient!.editAddress(id, add);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<dynamic>> getAddress(dynamic id) async {
    var logger = Logger();
    dynamic response;
    try {
      response = await apiClient!.getAllAddress(id);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<dynamic>> getAndSearchUser(String userName) async {
    var logger = Logger();
    try {
      // Validate input to prevent sending empty queries
      if (userName.trim().isEmpty) {
        return BaseModel()
          ..data = {
            "message": "Search term cannot be empty",
            "data": {"message": "No results", "data": []}
          };
      }

      final response = await apiClient!.getAndSearchUser(userName);
      return BaseModel()..data = response;
    } catch (error, stacktrace) {
      logger.e("Search user error:", error: error, stackTrace: stacktrace);

      // Create a friendly error response when the API fails
      if (error is DioException && error.response?.statusCode == 500) {
        return BaseModel()
          ..data = {
            "message": "No users found",
            "data": {"message": "No results", "data": []}
          };
      }

      return BaseModel()
        ..setException(ServerError.withError(
            error: error is DioException
                ? error
                : DioException(
                    requestOptions: RequestOptions(path: ''),
                    error: error,
                  )));
    }
  }

  Future<BaseModel<dynamic>> getSearchTeacher(userName) async {
    var logger = Logger();
    dynamic response;
    try {
      response = await apiClient!.getSearchTeacher(userName);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<dynamic>> getApi(
      dynamic add, dynamic header, dynamic path, dynamic type) async {
    var logger = Logger();
    dynamic response;
    try {
      response = await apiClient!.getApi(add, header, path, type);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
  }
}

class EncryptionUtil {
  // Existing methods and properties

  static String encryptMap(Map<String, dynamic> data) {
    // Implement your encryption logic here
    // For example, converting the map to a JSON string and then encrypting it
    final jsonString = jsonEncode(data);
    final encrypted = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromLength(32)))
        .encrypt(jsonString, iv: encrypt.IV.fromLength(16));
    return encrypted.base64;
  }
}
