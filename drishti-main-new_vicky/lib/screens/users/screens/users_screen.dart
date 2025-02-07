import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/models/search_user.dart';
import 'package:srisridrishti/screens/home/widgets/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../themes/theme.dart';

import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';

import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';

import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => UsersScreenState();
}

class UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  ApiBloc apiBloc = ApiBloc();

  data(userName) {
    apiBloc.add(GetAndSearch(userName: userName));
  }

  @override
  void initState() {
    data("");
    super.initState();
  }

  Widget _buildUserAvatar(String? profileImage) {
    if (profileImage != null &&
        profileImage.isNotEmpty &&
        Uri.tryParse(profileImage)?.hasScheme == true) {
      return ClipOval(
        child: Image.network(
          profileImage,
          width: 60.0,
          height: 60.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return ClipOval(
      child: Image.asset(
        "assets/images/user.png",
        width: 60.0,
        height: 60.0,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget bloc() {
    var height = MediaQuery.of(context).size.height;
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
              SearchUser? searchUser = state.data['data']['data'] ==
                      'No user found with the provided userName.'
                  ? null
                  : searchUserFromJson(state.data);
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
                                    fontSize: height * 0.017,
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
                              ? const Center(
                                  child: Text(
                                      'No user found with the provided userName'),
                                )
                              : SizedBox(
                                  height: height * 2,
                                  child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: searchUser.data.data.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        final user =
                                            searchUser.data.data[index];
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
                                                  _buildUserAvatar(
                                                      user.profileImage),
                                                ],
                                              ),
                                              const SizedBox(width: 10),
                                              Container(
                                                alignment: Alignment.center,
                                                height: height * 0.1,
                                                child: Text(user.name,
                                                    style: GoogleFonts.manrope(
                                                      textStyle: TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontSize:
                                                              height * 0.02,
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
