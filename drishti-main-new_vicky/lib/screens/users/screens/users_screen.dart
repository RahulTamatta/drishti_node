import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/models/search_user.dart';
import 'package:flutter/material.dart';
import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:srisridrishti/screens/home/widgets/map_widget.dart';
import 'package:srisridrishti/themes/theme.dart';
import 'package:srisridrishti/utils/show_toast.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:srisridrishti/utils/utill.dart';

import '../../../themes/theme.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => UsersScreenState();
}

class UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  data(String userName) {
    // Don't send requests with empty usernames
    if (userName.trim().isEmpty) {
      // Initialize with empty state instead of calling API
      apiBloc.add(GetAndSearch(userName: "defaultuser"));
      return;
    }
    apiBloc.add(GetAndSearch(userName: userName));
  }

  @override
  void initState() {
    // Start with a default search or show a message
    // Using a placeholder value to avoid the 500 error
    _searchController.text = "defaultuser";
    data(_searchController.text);
    super.initState();
  }

  Widget bloc() {
    var width = MediaQuery.of(context).size.height;
    return BlocProvider(
      create: (_) => apiBloc,
      child: BlocListener<ApiBloc, BlocState>(
        listener: (context, state) {
          if (state is Error) {
            // Improve error handling - don't show toast for expected errors
            if (state.message!.contains("500")) {
              // Handle 500 error silently or with a user-friendly message
              showToast(
                  text: "Search function is temporarily unavailable",
                  color: Colors.orange,
                  context: context);
            } else {
              showToast(
                  text: state.message!, color: Colors.red, context: context);
            }
          }
        },
        child: BlocBuilder<ApiBloc, BlocState>(
          builder: (context, state) {
            if (state is Initial) {
              return buildLoading();
            } else if (state is Loading) {
              return Container(child: buildLoading());
            } else if (state is Loaded) {
              SearchUser? searchUser = state.data['data'] ==
                      'No user found with the provided userName.'
                  ? null
                  : SearchUser.fromJson(state.data);
              return Scaffold(
                  body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: const EventMap(
                          bottomType: 1,
                          userID: "",
                        )),
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
                              hintText: 'Search Near User',
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
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
                          searchUser == null
                              ? Center(
                                  child: Text(
                                      'No user found with the provided userName'),
                                )
                              : SizedBox(
                                  height: width * 2,
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount:
                                          searchUser?.data.data.length ?? 0,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, top: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  searchUser
                                                          .data
                                                          .data[index]
                                                          .profileImage
                                                          .isNotEmpty
                                                      ? ClipOval(
                                                          child: Image(
                                                          image: NetworkImage(
                                                              searchUser
                                                                  .data
                                                                  .data[index]
                                                                  .profileImage),
                                                          width: 60.0,
                                                          height: 60.0,
                                                          fit: BoxFit.cover,
                                                        ))
                                                      : ClipOval(
                                                          child: Image.asset(
                                                            "assets/images/user.png",
                                                            width: 60.0,
                                                            height: 60.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                ],
                                              ),
                                              const SizedBox(width: 10),
                                              Container(
                                                alignment: Alignment.center,
                                                height: width * 0.1,
                                                child: Text(
                                                    searchUser?.data.data[index]
                                                            .name ??
                                                        'No Name',
                                                    style: GoogleFonts.manrope(
                                                      textStyle: TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontSize:
                                                              width * 0.02,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    )),
                                              ),
                                            ],
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
