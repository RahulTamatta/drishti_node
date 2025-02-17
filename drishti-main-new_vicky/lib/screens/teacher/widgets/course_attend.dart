import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:srisridrishti/screens/teacher/screens/attend_screen.dart';

class CoursesAttendedScreen extends StatefulWidget {
  const CoursesAttendedScreen({super.key});

  @override
  State<CoursesAttendedScreen> createState() => _CoursesAttendedScreenState();
}

class _CoursesAttendedScreenState extends State<CoursesAttendedScreen> {
//flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  data(context) async {
    String? token = await SharedPreferencesHelper.getAccessToken() ?? await SharedPreferencesHelper.getRefreshToken();
    print("Token: $token");

    dynamic headers = {
      'Authorization': 'Bearer ${token.toString()}'
    }; // Add 'Bearer 'token.toString()};
    // dynamic headers = <String, dynamic>{};
    dynamic body = <String, dynamic>{};
    dynamic path = "/event/getAttendedEvents";
    dynamic type = "GET";
    apiBloc.add(GetApi(add: body, header: headers, path: path, type: type));

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
              canPop: true, // prevent back
              onPopInvokedWithResult: (bool didPop, Object? result) {
                Navigator.of(context).pop();
              },
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                content: Builder(
                  builder: (context) {
                    return SizedBox(
                      height: 200,
                      width: 200,
                      child: bloc(),
                    );
                  },
                ),
                insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
              ));
        });
  }

  Widget bloc() {
    return BlocProvider(
      create: (_) => apiBloc,
      child: BlocListener<ApiBloc, BlocState>(
        listener: (context, state) {
          if (state is Error) {
            showToast(
                text: state.message!, color: Colors.red, context: context);
          }
        },
        child: BlocBuilder<ApiBloc, BlocState>(
          builder: (context, state) {
            if (state is Initial) {
              return buildLoading();
            } else if (state is Loading) {
              return Container(child: buildLoading());
            } else if (state is Loaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                print(state.data);
              });
              return Container();
            } else if (state is Error) {
              return Container();
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const String date = "12/6/2022";
    var teachers = "Vicky and 3 more";
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(8.0),
        child: gridViewImages(
            title: 'Course 1',
            imageUrl:
                'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg',
            date: date,
            teachers: teachers),
      ),
    );
  }
}

// Course Card Widget
class CourseCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String date;
  final String teachers;

  const CourseCard(
      {super.key,
      required this.title,
      required this.imageUrl,
      required this.date,
      required this.teachers});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 150,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Text(
            "Attended on : $date",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 14,
                color: Colors.brown,
              ),
            ),
          ),
          Text(
            teachers,
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

gridViewImages({title, imageUrl, date, teachers}) => GridView.builder(
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 3 / 5,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2),
    itemCount: 2,
    itemBuilder: (BuildContext ctx, index) {
      return GestureDetector(
          onTap: () {
            Get.to(const CourseAttendDetailScreen());
          },
          child: CourseCard(
            title: title,
            imageUrl: imageUrl,
            date: date,
            teachers: teachers,
          ));
    });
