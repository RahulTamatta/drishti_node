import 'package:flutter/cupertino.dart';

class CourseSelectionProvider extends ChangeNotifier {
  String courseSelection = "";

  updateCourse(String course) {
    courseSelection = course;
    notifyListeners();
  }
}
