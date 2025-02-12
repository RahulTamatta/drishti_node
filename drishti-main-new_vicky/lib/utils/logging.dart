import 'dart:developer' as developer;

void logInfo(String message) {
  developer.log(message, level: 800); // INFO level
}

void logError(String message) {
  developer.log(message, level: 1000); // ERROR level
}
