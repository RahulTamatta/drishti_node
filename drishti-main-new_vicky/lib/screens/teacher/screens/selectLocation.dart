import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/models/Address.dart';
import 'package:srisridrishti/providers/location_provider.dart';
import 'package:srisridrishti/themes/theme.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';
import 'package:flutter/material.dart';
import 'package:srisridrishti/screens/teacher/screens/add_address.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  SelectLocationScreenState createState() => SelectLocationScreenState();
}

class SelectLocationScreenState extends State<SelectLocationScreen> {
  List<Map<String, String>> savedAddresses = [
    {
      "type": "Home",
      "address":
          "J46J+4Q4, Jawaharlal Nehru Marg, Adalatganj, Kidwaipuri, Patna, Bihar 800001"
    },
    {
      "type": "Office",
      "address":
          "J46J+4Q4, Jawaharlal Nehru Marg, Adalatganj, Kidwaipuri, Patna, Bihar 800001"
    },
  ];

  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  Future<void> api() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var userID = prefs.getString("UserID");
    apiBloc.add(GetAddress(id: userID));
  }

  @override
  void initState() {
    api();
    super.initState();
    searchController.addListener(() {
      _onChange();
    });
    print("LocationAutoComplete initialized");
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Select Location"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Replacing the TextField with LocationAutoComplete widget

              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "Search place...",
                ),
                onChanged: (value) {
                  setState(() {});
                },
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

              Center(
                  child: Text(
                "OR",
                style: TextStyle(fontSize: 16, color: AppColors.primaryColor),
              )),
              ElevatedButton.icon(
                onPressed: () {
                  // Handle using current location

                  getLocation(context);
                },
                icon: const Icon(Icons.my_location),
                label: const Text("Use Current Location"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Saved Address",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddAddressScreen()),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add New Address"),
                    style: TextButton.styleFrom(foregroundColor: Colors.purple),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              bloc()
            ],
          ),
        ));
  }

  getLocation(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var userID = prefs.getString("UserID");

    Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high));

    List<Placemark> addresses =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    var first = addresses.first;
    String address =
        '${first.name!} ${first.subLocality!} ${first.administrativeArea} ${first.postalCode!}';

    final AddressProvider addressProvider =
        Provider.of<AddressProvider>(context, listen: false);
    addressProvider.updatePosition(
        lat: position.latitude, long: position.longitude, address: addresses);

    apiBloc.add(CreateAddress(add: {
      "title": "Home",
      "address": address,
      "city": "",
      "state": "",
      "country": first.country,
      "pin": first.country,
      "latlong": {
        "coordinates": [position.latitude, position.longitude]
      },
      "userId": userID
    }));
  }

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

  addressLayout(Address address) {
    return Expanded(
      child: ListView.builder(
        itemCount: address.data.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(address.data[index].title.toString()),
              subtitle: Text(address.data[index].address.toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Handle share functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddAddressScreen(
                                  addressData: address.data[index])));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      // Handle delete functionality

//object id
                      apiBloc.add(DeleteAddress(id: address.data[index].id));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget bloc() {
    return BlocProvider(
      create: (_) => apiBloc,
      child: BlocListener<ApiBloc, BlocState>(
        listener: (context, state) {
          if (state is Error && state.message != null) {
            showToast(
                text: state.message ?? 'Unknown error', // Provide a default value
                color: Colors.red,
                context: context);
          }
        },
        child: BlocBuilder<ApiBloc, BlocState>(
          builder: (context, state) {
            if (state is Initial) {
              return buildLoading();
            } else if (state is Loading) {
              return Container(child: buildLoading());
            } else if (state is Loaded) {
              dynamic add = state.data;
              print(add);

              if (add['message'] == 'address.ADDRESS_CREATED') {
                Get.back();
              }

              if (add['message'] == 'address.ADDRESS_DELETED') {
                api();
              }

              if (add['message'] == 'address.ADDRESSES_FOUND') {
                Address address = addressFromJson(add);

                return addressLayout(address);
              } else {
                return Container();
              }
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
}
