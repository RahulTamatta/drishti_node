import 'package:flutter/material.dart';

class BottomSheetContentProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  String _tag = "sudarshan kriya";

  set tag(String newTag) {
    _tag = newTag;
  }

  set date(DateTime newDate) {
    _selectedDate = newDate;
  }

  DateTime get date => _selectedDate;

  String get tag => _tag;
}
