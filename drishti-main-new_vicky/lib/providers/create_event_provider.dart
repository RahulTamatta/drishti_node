import 'package:srisridrishti/models/create_event_model.dart';
import 'package:flutter/cupertino.dart';

class CreateEventProvider extends ChangeNotifier {
  CreateEventModel _createEventModel;

  CreateEventProvider(this._createEventModel);

  CreateEventModel get createEventModel => _createEventModel;

  set createEventModel(CreateEventModel newModel) {
    _createEventModel = newModel;
    notifyListeners();
  }

  // Update methods for individual fields
  void updateMode(String mode) {
    _createEventModel = _createEventModel.copyWith(mode: mode);
    notifyListeners();
  }

  void updateAol(List<String> aol) {
    _createEventModel = _createEventModel.copyWith(aol: aol);
    notifyListeners();
  }

  void updateTitle(List<String> title) {
    _createEventModel = _createEventModel.copyWith(title: title);
    notifyListeners();
  }

  void updateRecurring(bool recurring) {
    _createEventModel = _createEventModel.copyWith(recurring: recurring);
    notifyListeners();
  }

  void updateDurationFrom(String durationFrom) {
    _createEventModel = _createEventModel.copyWith(durationFrom: durationFrom);
    notifyListeners();
  }

  void updateDurationTo(String durationTo) {
    _createEventModel = _createEventModel.copyWith(durationTo: durationTo);
    notifyListeners();
  }

  void updateTimeOffset(String timeOffset) {
    _createEventModel = _createEventModel.copyWith(timeOffset: timeOffset);
    notifyListeners();
  }

  void updateMeetingLink(String meetingLink) {
    _createEventModel = _createEventModel.copyWith(meetingLink: meetingLink);
    notifyListeners();
  }

  void updatePhoneNumber(List<String> phoneNumber) {
    _createEventModel = _createEventModel.copyWith(phoneNumber: phoneNumber);
    notifyListeners();
  }

  void updateAddress(List<String> address) {
    _createEventModel = _createEventModel.copyWith(address: address);
    notifyListeners();
  }

  void updateDescription(String description) {
    _createEventModel = _createEventModel.copyWith(description: description);
    notifyListeners();
  }

  void updateRegistrationLink(String registrationLink) {
    _createEventModel =
        _createEventModel.copyWith(registrationLink: registrationLink);
    notifyListeners();
  }

  void updateCoordinates(List<double> coordinates) {
    _createEventModel = _createEventModel.copyWith(coordinates: coordinates);
    notifyListeners();
  }

  void updateTeachers(List<String> teachers) {
    _createEventModel = _createEventModel.copyWith(teachers: teachers);
    notifyListeners();
  }

  void updateDate(EventDateTime date) {
    _createEventModel = _createEventModel.copyWith(date: date);
    notifyListeners();
  }
}
