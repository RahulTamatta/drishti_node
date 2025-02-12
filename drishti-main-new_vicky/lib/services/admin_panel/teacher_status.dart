import 'package:dio/dio.dart';
import 'package:srisridrishti/models/teacher_details_model.dart';
import 'package:srisridrishti/utils/api_constants.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.validateStatus = (status) {
      return status! < 500;
    };
  }

  Future<List<TeachersDetails>> getTeachersRequest() async {
    try {
      String? token = await SharedPreferencesHelper.getAccessToken();
      print("Token: $token");

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/user/getTeachersRequest',
        options: Options(
          headers: {
            'Authorization': token,
          },
        ),
      );
      print(response);

      if (response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => TeachersDetails.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception(
            'Unauthorized: Please check your authentication. Response: $response');
      } else if (response.statusCode == 410) {
        throw Exception(
            'The requested resource is no longer available. Please contact support or refresh your data.');
      } else {
        throw Exception(
            'Failed to load teachers: ${response.statusCode}. Response: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 410) {
        throw Exception(
            'The requested resource is no longer available. Please contact support or refresh your data.');
      }
      throw Exception(
          'Network error: ${e.message}. Status code: ${e.response?.statusCode}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> approveTeacher(String teacherId) async {
    try {
      String? token = await SharedPreferencesHelper.getAccessToken();
      print("Token: $token");

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/user/action-teacher?status=accepted&id=$teacherId',
        options: Options(
          headers: {
            'Authorization': token,
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please check your authentication');
      } else {
        throw Exception(
            'Failed to approve teacher: $teacherId. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> suspendTeacher(String teacherId) async {
    try {
      String? token = await SharedPreferencesHelper.getAccessToken();
      print("Token: $token");

      final response = await _dio.post(
        'https://collabdiary.in/user/action-teacher?status=reject&id=$teacherId',
        options: Options(
          headers: {
            'Authorization': token,
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please check your authentication');
      } else {
        throw Exception(
            'Failed to suspend teacher. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
