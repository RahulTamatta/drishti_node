import 'dart:io';
import 'package:srisridrishti/config/api_config.dart';

class ApiConstants {
  static String get baseUrl => "http://10.0.2.2:8080";

  static String get loginUrl => "$baseUrl/user/login";
  static String get loginVerify => "$baseUrl/user/verify";
  static String get allEvents => "$baseUrl/event/all-events";
  // static String get onboard => "http://10.0.2.2:8080/user/onBoard";
  static String get user => "$baseUrl/user";
  static String get userUpdate => "$baseUrl/user/update";

// https://collabdiary.in/course/get
  static String get createEvent => "$baseUrl/event";
  static String get notifyMe => "$baseUrl/event/notifyme";
}
