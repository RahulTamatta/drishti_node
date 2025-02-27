class ApiConstants {
  static String get baseUrl => "http://drishtinode-production.up.railway.app";

  static String get loginUrl => "$baseUrl/user/login";
  static String get loginVerify => "$baseUrl/user/verify";
  static String get refreshToken => "$baseUrl/user/refreshToken";
  static String get allEvents => "$baseUrl/event/all-events";
  // static String get onboard => "https://10.0.2.2:8000/user/onBoard";
  static String get user => "$baseUrl/user";
  static String get userUpdate => "$baseUrl/user/update";

// http://drishtinode-production.up.railway.app/course/get
  static String get createEvent => "$baseUrl/event";
  static String get notifyMe => "$baseUrl/event/notifyme";
}
