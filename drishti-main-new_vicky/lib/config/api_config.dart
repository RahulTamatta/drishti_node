class ApiConfig {
  static const bool useLocalHost = true; // Change to false for production

  // Local development URL
  static const String localBaseUrl =
      'https://drishtinode-production.up.railway.app'; // For Android Emulator
  static const String localIosUrl =
      'http://localhost:3000'; // For iOS Simulator

  // Production URL (Railway)
  static const String productionBaseUrl =
      'https://drishtinode-production.up.railway.app';

  // Get the appropriate base URL based on environment and platform
  static String getBaseUrl(bool isIOS) {
    if (useLocalHost) {
      return isIOS ? localIosUrl : localBaseUrl;
    }
    return productionBaseUrl;
  }
}
