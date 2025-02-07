import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../models/display_course_model.dart';
import '../repos/auth_repo/course_repository.dart';

class CourseListProvider extends ChangeNotifier {
  int selectedTagPosition = 0;

  setTagColor(int position) {
    selectedTagPosition = position;
    notifyListeners();
  }

  List<String> tagsList = ["all"];

  String _selectedTagg = 'all'; // Set "yoga" as the default selected tag
  DateTime _selectedDateT =
      DateTime.now(); // Set today's date as the default selected date

  var onlyDateSelected;

  CourseListProvider() {
    onlyDateSelected =
        DateTime(_selectedDateT.year, _selectedDateT.month, _selectedDateT.day);
  }

  //set only selected date when _selected date is changed
  setOnlySelectedDate() {
    onlyDateSelected =
        DateTime(_selectedDateT.year, _selectedDateT.month, _selectedDateT.day);
  }

//
  String get selectedTag => _selectedTagg;

  DateTime get selectedDate => _selectedDateT;

  void setSelectedTag(String tag) {
    _selectedTagg = tag;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDateT = date;
    notifyListeners();
  }

  //

// below list will contain all courses from today date to future courses
  List<Course> defaultCourses = [];

  //only similar Date course i.e selected date all courses list
  List<Course> selectedDateCoursesList = [];

  Map<String, List<Course>> myMap = {};

  void sortCourseBasedOnDateOnly() {
    selectedDateCoursesList.clear();
    myMap.clear();

    DateTime today = DateTime.now();
    DateTime onlyTodayDate = DateTime(today.year, today.month, today.day);

    for (Course item in defaultCourses) {
      var dateFormatted = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
          .parse(item.date!.from!); // Parse date from string
      var onlyCourseDate =
          DateTime(dateFormatted.year, dateFormatted.month, dateFormatted.day);
      if (onlyTodayDate.isAtSameMomentAs(onlyCourseDate)) {
        selectedDateCoursesList.add(item);
      }
    }

    // Sort the list of courses by time
    selectedDateCoursesList.sort((a, b) {
      var aDateTime = DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(a.date!.from!);
      var bDateTime = DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(b.date!.from!);
      return aDateTime.compareTo(bDateTime);
    });

    notifyListeners();
  }

  final List<Marker> markers = <Marker>[];
  Uint8List? markIcons;

  LatLng? newCo_ordinates;

  setNewCoordinates(LatLng latLng) {
    newCo_ordinates = latLng;

    notifyListeners();
  }

  //image to marker method
  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // to get courses on the basis of users location
  getCoursesAndSaveInList(BuildContext context) async {
    // convert image to marker icon
    defaultCourses.clear();

    markers.clear();
    // notifyListeners();

    markIcons = await getImages("assets/images/marker_tag.png", 190);

    // ignore: use_build_context_synchronously
    courseRepo.getCourses(context).then(
      (value) {
        // defaultCourses.clear();
        defaultCourses = value.data!;
        sortCourseBasedOnDateOnly();
        for (int i = 0; i < defaultCourses.length; i++) {
          // makers added according to index
          var lat = defaultCourses[i].location!.coordinates?[0];
          var lng = defaultCourses[i].location!.coordinates?[1];
          if (lat == null || lng == null) {
            continue;
          }

          BitmapDescriptor? customIcon;

// make sure to initialize before map loading
          BitmapDescriptor.asset(const ImageConfiguration(size: Size(18, 18)),
                  'assets/images/call.png')
              .then((d) {
            print("object");
            customIcon = d;
            print(customIcon);
          });
          // markers.add(
          //   Marker(
          //     markerId: MarkerId(i.toString()),
          //     icon: customIcon!,
          //     position: LatLng(latitu, longitu),
          //     infoWindow: InfoWindow(
          //       title: defaultCourses[i].title,
          //     ),
          //   ),
          // );

          markers.add(Marker(
              markerId: const MarkerId("marker_2"),
              position: const LatLng(28.613279, 77.028557),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue)));

          markers.add(const Marker(
            markerId: MarkerId('1'),
            position: LatLng(13.007488, 77.598656),
            infoWindow: InfoWindow(
              title: 'Marker Title Second ',
              snippet: 'My Custom Subtitle',
            ),
          ));
          markers.add(const Marker(
            markerId: MarkerId('2'),
            position: LatLng(13.007481, 77.598651),
            infoWindow: InfoWindow(
              title: 'Marker Title Third ',
              snippet: 'My Custom Subtitle',
            ),
          ));
          markers.add(const Marker(
            markerId: MarkerId('3'),
            position: LatLng(13.001916, 77.588849),
            infoWindow: InfoWindow(
              title: 'Marker Title Fourth ',
              snippet: 'My Custom Subtitle',
            ),
          ));

          // notifyListeners();
        }
        notifyListeners();
      },
    );
  }

  getVisibleMapCoursesAndSaveInList(BuildContext context) async {
    // convert image to marker icon
    defaultCourses.clear();
    tagsList.clear();
    tagsList.add("all");
    markers.clear();
    notifyListeners();

    markIcons = await getImages("assets/images/marker_tag.png", 190);
    courseRepo.getMapBasedCourses(context).then(
      (value) {
        defaultCourses = value.data!;

        // generateTagsList();

        sortCourseBasedOnDateOnly();

        for (int i = 0; i < defaultCourses.length; i++) {
          // makers added according to index
          var lat = defaultCourses[i].location!.coordinates?[0];
          var lng = defaultCourses[i].location!.coordinates?[1];

          if (lat == null || lng == null) {
            continue;
          }

          double latitu = lat;
          double longitu = lng;
          markers.add(
            Marker(
              // given marker id
              markerId: MarkerId(i.toString()),
              // given marker icon
              icon: BitmapDescriptor.fromBytes(markIcons!),
              // given position
              position: LatLng(latitu, longitu),
              infoWindow: InfoWindow(
                // given title for marker
                title: defaultCourses[i].title,
              ),
            ),
          );
          notifyListeners();
        }

        notifyListeners();
      },
    );
  }
}
