import 'package:srisridrishti/models/search_user.dart';
import 'package:flutter/cupertino.dart';

class TeacherProvider extends ChangeNotifier {
  TData? searchTeacher;

  TeacherProvider(this.searchTeacher);

  TData? get createTeacherModel => searchTeacher;

  set createTeacherModel(TData? newModel) {
    searchTeacher = newModel;
    notifyListeners();
  }
}
