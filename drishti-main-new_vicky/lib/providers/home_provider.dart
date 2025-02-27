import 'package:flutter/cupertino.dart';

class HomeProvider extends ChangeNotifier {
  String _selectedYoga = "";
  DateTime? selectedDate;
  Set<String> _notifiedEvents = {};

  String get selectedYoga => _selectedYoga;

  set selectedYoga(String value) {
    _selectedYoga = value;
    notifyListeners(); // Notify listeners when the value changes
  }

  void updateSelectedDate(DateTime? newDate) {
    selectedDate = newDate;
    notifyListeners();
  }

  void resetSelectedYoga() {
    _selectedYoga = "";
    notifyListeners(); // Notify listeners after resetting
  }

  void resetSelectedDate() {
    selectedDate = DateTime.now();
    notifyListeners(); // Notify listeners after resetting
  }

  // Add methods for notification management
  bool isEventNotified(String eventId) {
    return _notifiedEvents.contains(eventId);
  }

  void toggleEventNotification(String eventId, bool isNotified) {
    if (isNotified) {
      _notifiedEvents.add(eventId);
    } else {
      _notifiedEvents.remove(eventId);
    }
    notifyListeners();
  }
}
