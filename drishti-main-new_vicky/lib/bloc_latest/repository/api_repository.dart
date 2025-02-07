import 'dart:async';

import 'package:srisridrishti/bloc_latest/repository/base_model.dart';

import 'api_provider.dart';
// import 'base_model.dart';

class ApiRepository {
  final _provider = ApiProvider();

  Future<BaseModel<dynamic>> addProfile(add, header) {
    return _provider.addProfile(add, header);
  }

  Future<BaseModel<dynamic>> updateProfile(add, header, id) {
    return _provider.updateProfile(add, header, id);
  }

  Future<BaseModel<dynamic>> getNotificationById(dynamic id, dynamic token) {
    return _provider.getNotificationById(id, token);
  }

  Future<BaseModel<dynamic>> getAndSearchUser(dynamic userName) {
    return _provider.getAndSearchUser(userName);
  }

  Future<BaseModel<dynamic>> getSearchTeacher(dynamic userName) {
    return _provider.getSearchTeacher(userName);
  }

  Future<BaseModel<dynamic>> notifyMe(dynamic id, dynamic header) {
    return _provider.notifyMe(id, header);
  }

  Future<BaseModel<dynamic>> nearUser(dynamic add) {
    return _provider.nearUser(add);
  }

  Future<BaseModel<dynamic>> nearByEvent(dynamic add) {
    return _provider.nearByEvent(add);
  }

  Future<BaseModel<dynamic>> updateUserLocation(dynamic add, dynamic header) {
    return _provider.updateUserLocation(add, header);
  }

  Future<BaseModel<dynamic>> createAddress(dynamic add) {
    return _provider.createAddress(add);
  }

  Future<BaseModel<dynamic>> deleteAddress(dynamic id) {
    return _provider.deleteAddress(id);
  }

  Future<BaseModel<dynamic>> editAddress(dynamic id, add) {
    return _provider.editAddress(id, add);
  }

  Future<BaseModel<dynamic>> getAddress(dynamic id) {
    return _provider.getAddress(id);
  }

  Future<BaseModel<dynamic>> getApi(
      dynamic add, dynamic header, dynamic path, dynamic type) async {
    return _provider.getApi(add, header, path, type);
  }
}

class NetworkError extends Error {}
