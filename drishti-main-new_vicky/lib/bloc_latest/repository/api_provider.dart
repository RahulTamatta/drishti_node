import 'package:dio/dio.dart';
import 'package:srisridrishti/bloc_latest/retrofit/rest_client.dart';
import 'package:logger/logger.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'base_model.dart';
import 'server_error.dart';

class ApiProvider {
  RestClient? apiClient;

  ApiProvider() {
    apiClient = RestClient();
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

  Future<BaseModel<dynamic>> addProfile(add, dynamic header) async {
    var logger = Logger();
    dynamic response;

    try {
      logger.d("Request Data: $add");
      logger.d("Request Headers: $header");

      response = await apiClient!.addProfile(add, header);

      logger.d("Response Data: $response");
    } catch (error, stacktrace) {
      logger.e("Exception occurred:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }

    logger.d("Returning Response: $response");
    return BaseModel()..data = response;
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

  Future<BaseModel<dynamic>> nearUser(dynamic add) async {
    var logger = Logger();
    dynamic response;
    try {
      response = await apiClient!.nearByUser(add);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
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

  Future<BaseModel<dynamic>> getAndSearchUser(userName) async {
    var logger = Logger();
    dynamic response;
    try {
      response = await apiClient!.getAndSearchUser(userName);
    } catch (error, stacktrace) {
      logger.f("Exception occured:", error: error, stackTrace: stacktrace);
      return BaseModel()
        ..setException(ServerError.withError(error: error as DioException));
    }
    return BaseModel()..data = response;
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
