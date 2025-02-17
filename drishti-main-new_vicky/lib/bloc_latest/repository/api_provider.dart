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

  Future<BaseModel<dynamic>> addProfile(FormData formData) async {
    try {
      print('=== Adding Profile START ===');
      print('Form Data Fields: ${formData.fields}');
      print('Form Data Files: ${formData.files}');

      final token = await SharedPreferencesHelper.getAccessToken();
      print('Authorization Token: $token');

      // Create proper headers
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      };

      // Ensure the URL is correct
      final response = await _dio!.post(
        'http://10.0.2.2:8080/user/onBoard',
        data: formData,
        options: Options(
          headers: headers,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Data: ${response.data}');

      return BaseModel()..data = response.data;
    } catch (error) {
      print('=== Add Profile ERROR ===');
      print('Error Type: ${error.runtimeType}');
      print('Error Details: $error');
      return BaseModel()
        ..setException(ServerError.withError(
            error: error is DioException
                ? error
                : DioException(
                    requestOptions: RequestOptions(path: ''), error: error)));
    }
  }

  Future<BaseModel<dynamic>> updateProfile(add, dynamic header, id) async {
    var logger = Logger();
    dynamic response;
    try {
      response = await apiClient!.updateProfile(add, header, id);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
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
      final response = await apiClient!.getAndSearchUser(userName);
      return BaseModel()..data = response;
    } catch (error, stacktrace) {
      logger.e("Search user error:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
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
