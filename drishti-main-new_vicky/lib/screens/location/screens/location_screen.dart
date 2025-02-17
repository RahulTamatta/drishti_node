import 'dart:convert';

import 'package:srisridrishti/bloc/user_location_bloc/user_location_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/screens/bottom_navigation/bottom_navigation_screen.dart';
import 'package:srisridrishti/screens/location/widgets/location_appbar.dart';
import 'package:srisridrishti/themes/theme.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final searchController = TextEditingController();
  final String token = '1234567890';
  var uuid = const Uuid();
  List<dynamic> listOfLocation = [];

  _onChange() {
    print("Search input changed: ${searchController.text}");
    placeSuggestion(searchController.text);
  }

  void placeSuggestion(String input) async {
    if (input.isEmpty) {
      print("Input is empty, skipping API call.");
      return;
    }

    const String apiKey = "AIzaSyDBjiwvS69uqWRXdAD4c1oF6Qobsfqj5Rg";
    try {
      String baseUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request = '$baseUrl?input=$input&key=$apiKey&sessiontoken=$token';

      print("Making API call to: $request");

      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      print("Response received: $data");

      if (response.statusCode == 200) {
        setState(() {
          listOfLocation = data['predictions'];
          print(
              "Locations updated: ${listOfLocation.length} predictions found.");
        });
      } else {
        print(
            "Failed to load suggestions. Status code: ${response.statusCode}");
        throw Exception("Failed to load suggestions");
      }
    } catch (e) {
      print("Error during API call: ${e.toString()}");
    }
  }

  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  data(context) async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();

    // var userID = prefs.getString("UserID");
    String? token = await SharedPreferencesHelper.getAccessToken() ?? await SharedPreferencesHelper.getRefreshToken();
    print("Token: $token");

    dynamic headers = {
      'Authorization': 'Bearer ${token.toString()}'
    }; // Add 'Bearer 'token.toString()};
    Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high));

    List<Placemark> addresses =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    var first = addresses.first;
    String address =
        '${first.name!} ${first.subLocality!} ${first.administrativeArea} ${first.postalCode!}';

    apiBloc.add(
      UpdateUserLocation(add: {
        "lat": position.latitude,
        "long": position.longitude,
        "location": address
      }, header: headers),
    );
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
              // showToast(
              //     text: "Address Created Successfully",
              //     color: Colors.red,
              //     context: context);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) {
                  return const BottomNavigationScreen();
                }), (_) => false);
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
    getLocation(context);
    super.initState();

    searchController.addListener(() {
      _onChange();
    });
  }

  getLocation(BuildContext context) {
    context.read<UserLocationBloc>().add(GetUserLocation(context: context));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: locationAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Stack(
          children: [
            bloc(),
            Column(
              children: [
                TextField(
                  controller: searchController,
                  style: const TextStyle(
                      fontSize: 16, decoration: TextDecoration.none),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    hintText: "Enter your Location",
                    fillColor: Colors.white,
                    filled: true,
                    hintStyle: TextStyle(fontSize: 14.sp),
                    prefixIcon: Icon(Icons.gps_fixed_sharp,
                        size: 17.sp, color: Colors.grey.withOpacity(0.4)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black38),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black38),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Or",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    data(context);
                  },
                  child: Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black38),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Use Current Location",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: searchController.text.isNotEmpty,
                  child: Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemCount: listOfLocation.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            print(
                                "Location selected: ${listOfLocation[index]["description"]}");
                            // You can handle selection here
                          },
                          child: ListTile(
                            title: Text(listOfLocation[index]["description"]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
