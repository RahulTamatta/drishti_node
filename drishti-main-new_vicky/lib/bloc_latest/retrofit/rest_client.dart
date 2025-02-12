import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'rest_client.g.dart';

const String baseUrl1 =
// 'https://rest-rosy.vercel.app';

    'http://10.0.2.2:8080';

// "https://collabdiary.in";

@RestApi(baseUrl: baseUrl1)
abstract class RestClient {
  factory RestClient({String? baseUrl, required Dio dio}) {
    Dio dio = Dio();
    dio.options = BaseOptions(
        receiveTimeout: const Duration(seconds: 1000),
        connectTimeout: const Duration(seconds: 1000),
        baseUrl: baseUrl1);
    dio.options.headers["Content-Type"] = "application/json";

    // intercptors are use to display api response body and request body
    dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: true));

    // InterceptorsWrapper makes it possible to observe or intercept everything that is API request.
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      return handler.next(options);
    }, onResponse: (response, handler) {
      log("interceptor${response.data}");
      return handler.next(response);
    }, onError: (DioException e, handler) {
      return handler.next(e);
    }));
    return _RestClient(dio, baseUrl: baseUrl);
  }

  @POST("/user/onBoard")
  Future<dynamic> addProfile(@Body() add, dynamic header);

  @PATCH("/user/onBoard/{id}")
  Future<dynamic> updateProfile(
    @Body() add,
    dynamic header,
    @Path() dynamic id,
  );

  @PATCH("/notifications/{id}")
  Future<dynamic> notifyMe(@Path() dynamic id, dynamic header);

  @POST("/address/nearUser")
  Future<dynamic> nearByUser(@Body() dynamic add);

  @POST("/event/nearEvent")
  Future<dynamic> nearByEvent(@Body() dynamic add);

  @POST("/address/create")
  Future<dynamic> createAddress(@Body() dynamic add);

  @DELETE("/address/delete/{id}")
  Future<dynamic> deleteAddress(@Path() dynamic id);

  @PATCH("/address/edit/{id}")
  Future<dynamic> editAddress(@Path() dynamic id, @Body() dynamic add);

  @GET("/address/user/{id}")
  Future<dynamic> getAllAddress(@Path() dynamic id);

  @PUT("/user/location")
  Future<dynamic> updateUserLocation(@Body() dynamic body, dynamic header);

  @GET("/notifyme/{id}")
  Future<dynamic> getNotificationByID(@Path() dynamic id, dynamic token);

  @GET("/user/search-user?userName={userName}")
  Future<dynamic> getAndSearchUser(@Path() dynamic userName);

  @GET("/user/search-teacher?userName={userName}")
  Future<dynamic> getSearchTeacher(@Path() dynamic userName);

  @GET("/{path}")
  Future<dynamic> getApi(
      @Body() dynamic add, dynamic header, @Path() dynamic path, dynamic type);
}
