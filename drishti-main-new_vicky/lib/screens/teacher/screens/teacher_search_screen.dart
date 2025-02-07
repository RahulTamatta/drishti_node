import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/models/search_user.dart';
import 'package:srisridrishti/providers/teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../themes/theme.dart';

import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';

import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';

import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherSearchScreen extends StatefulWidget {
  const TeacherSearchScreen({super.key});

  @override
  State<TeacherSearchScreen> createState() => TeacherSearchScreenState();
}

class TeacherSearchScreenState extends State<TeacherSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  data(userName) {
    apiBloc.add(GetAndSearchTeacher(userName: userName));
  }

  @override
  void initState() {
    data("vicky");
    super.initState();
  }

  Widget bloc() {
    var width = MediaQuery.of(context).size.height;
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
              SearchTeacher? searchTeacher = state.data['message'] ==
                      'No teacher found with the provided teacherName.'
                  ? null
                  : searchTeacherFromJson(state.data);

              final TeacherProvider teacherProvider =
                  Provider.of<TeacherProvider>(context, listen: true);

              return Scaffold(
                  backgroundColor: Colors.white,
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            color: Colors.white,
                            child: Wrap(spacing: 60, children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 3),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 130, vertical: 2),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: AppColors.lightgrey_BDBDBD),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search Teacher',
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  hintStyle: GoogleFonts.manrope(
                                    textStyle: TextStyle(
                                        fontSize: width * 0.017,
                                        color: AppColors.lightgrey_818181,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.search,
                                      color: AppColors.lightgrey_818181,
                                      size: 19,
                                    ),
                                    onPressed: () {
                                      data(_searchController.text);
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              searchTeacher == null
                                  ? const Center(
                                      child: Text(
                                          'No teacher found with the provided teacherName'),
                                    )
                                  : SizedBox(
                                      height: width * 2,
                                      child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: searchTeacher.data!.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                teacherProvider
                                                        .createTeacherModel =
                                                    searchTeacher.data![index];

                                                print(
                                                    searchTeacher.data![index]);

                                                Get.back();
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    // Column(
                                                    //   mainAxisAlignment:
                                                    //       MainAxisAlignment
                                                    //           .center,
                                                    //   children: [
                                                    //     searchTeacher
                                                    //                 .data
                                                    //                 // .data[index]
                                                    //                 .profileImage !=
                                                    //             ""
                                                    //         ? ClipOval(
                                                    //             child: Image(
                                                    //             image: NetworkImage(
                                                    //                 searchUser
                                                    //                     .data
                                                    //                     .data[
                                                    //                         index]
                                                    //                     .profileImage),
                                                    //             width: 60.0,
                                                    //             height: 60.0,
                                                    //             fit: BoxFit
                                                    //                 .cover,
                                                    //           ))
                                                    //         : ClipOval(
                                                    //             child:
                                                    //                 Image.asset(
                                                    //               "assets/images/user.png",
                                                    //               width: 60.0,
                                                    //               height: 60.0,
                                                    //               fit: BoxFit
                                                    //                   .cover,
                                                    //             ),
                                                    //           ),
                                                    //   ],
                                                    // ),
                                                    const SizedBox(width: 10),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: width * 0.1,
                                                      child: Text(
                                                          searchTeacher
                                                              .data![index]
                                                              .userName
                                                              .toString()
                                                          // .data[index]
                                                          ,
                                                          style: GoogleFonts
                                                              .manrope(
                                                            textStyle: TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize:
                                                                    width *
                                                                        0.02,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                            ])),
                      ],
                    ),
                  ));
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
  Widget build(BuildContext context) {
    return bloc();
  }
}
