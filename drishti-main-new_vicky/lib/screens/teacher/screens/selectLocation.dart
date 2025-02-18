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

              // TextField(
              //   controller: searchController,
              //   decoration: const InputDecoration(
              //     hintText: "Search place...",
              //   ),
              //   onChanged: (value) {
              //     setState(() {});
              //   },
              // ),
              // Visibility(
              //   visible: searchController.text.isNotEmpty,
              //   child: Expanded(
              //     child: ListView.builder(
              //       shrinkWrap: true,
              //       // physics: const NeverScrollableScrollPhysics(),
              //       itemCount: listOfLocation.length,
              //       itemBuilder: (context, index) {
              //         return GestureDetector(
              //           onTap: () async {
              //             print(
              //                 "Location selected: ${listOfLocation[index]["description"]}");

              //             final placeId = listOfLocation[index]["place_id"];
              //             final details = await getPlaceDetails(placeId);

              //             if (details != null) {
              //               // Extract address components
              //               String street = '';
              //               String city = '';
              //               String state = '';
              //               String country = '';
              //               String postalCode = '';
              //               String formattedAddress =
              //                   details['formatted_address'] ?? '';

              //               // Parse address components
              //               for (var component
              //                   in details['address_components']) {
              //                 final List types = component['types'];
              //                 if (types.contains('sublocality_level_1') ||
              //                     types.contains('locality')) {
              //                   city = component['long_name'];
              //                 } else if (types
              //                     .contains('administrative_area_level_1')) {
              //                   state = component['long_name'];
              //                 } else if (types.contains('country')) {
              //                   country = component['long_name'];
              //                 } else if (types.contains('postal_code')) {
              //                   postalCode = component['long_name'];
              //                 } else if (types.contains('route')) {
              //                   street = component['long_name'];
              //                 }
              //               }

              //               // If no postal code found, show error and return
              //               if (postalCode.isEmpty) {
              //                 showToast(
              //                   text:
              //                       "Please select a location with a valid PIN code",
              //                   color: Colors.red,
              //                   context: context,
              //                 );
              //                 return;
              //               }

              //               // Get user ID from SharedPreferences
              //               final SharedPreferences prefs =
              //                   await SharedPreferences.getInstance();
              //               var userID = prefs.getString("UserID");

              //               if (userID == null) {
              //                 showToast(
              //                   text:
              //                       "User ID not found. Please login again.",
              //                   color: Colors.red,
              //                   context: context,
              //                 );
              //                 return;
              //               }

              //               // Create properly structured address data for API
              //               final addressData = {
              //                 "title": "Home",
              //                 "address": formattedAddress,
              //                 "street": street,
              //                 "city": city,
              //                 "state": state,
              //                 "country": country,
              //                 "pin": postalCode,
              //                 "latlong": {
              //                   "type": "Point",
              //                   "coordinates": [
              //                     details['geometry']['location']['lng'],
              //                     details['geometry']['location']['lat']
              //                   ]
              //                 },
              //                 "userId": userID
              //               };

              //               // Validate required fields
              //               if (city.isEmpty ||
              //                   state.isEmpty ||
              //                   country.isEmpty ||
              //                   formattedAddress.isEmpty) {
              //                 showToast(
              //                   text:
              //                       "Unable to get complete address details. Please try another location.",
              //                   color: Colors.red,
              //                   context: context,
              //                 );
              //                 return;
              //               }

              //               // Update provider
              //               final addressProvider =
              //                   Provider.of<AddressProvider>(context,
              //                       listen: false);
              //               addressProvider.updatePosition(
              //                   lat: details['geometry']['location']['lat'],
              //                   long: details['geometry']['location']['lng'],
              //                   address: [
              //                     Placemark(
              //                       name: "Home",
              //                       street: formattedAddress,
              //                       locality: city,
              //                       administrativeArea: state,
              //                       country: country,
              //                       postalCode: postalCode,
              //                     )
              //                   ]);

              //               // Add to API bloc with proper structure
              //               apiBloc.add(CreateAddress(add: addressData));
              //               Navigator.pop(context);
              //             }
              //           },
              //           child: ListTile(
              //             title: Text(listOfLocation[index]["description"]),
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              // ),

              // Center(
              //     child: Text(
              //   "OR",
              //   style: TextStyle(fontSize: 16, color: AppColors.primaryColor),
              // )),

              ElevatedButton.icon(
                onPressed: () {
                  // Handle using current location
                  getLocation(context);
                  Navigator.pop(
                      context); // Return to previous screen after getting location
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
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var userID = prefs.getString("UserID");
      if (userID == null) {
        showToast(
          text: "User ID not found. Please login again.",
          color: Colors.red,
          context: context
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));

      List<Placemark> addresses = await placemarkFromCoordinates(position.latitude, position.longitude);
      var first = addresses.first;

      // Ensure we have a valid postal code
      if (first.postalCode == null || first.postalCode!.isEmpty) {
        showToast(
          text: "Could not determine PIN code for this location. Please select a different location.",
          color: Colors.red,
          context: context
        );
        return;
      }

      // Format address components, filtering out null or empty values
      List<String?> addressComponents = [
        first.name,
        first.subLocality,
        first.locality,
        first.administrativeArea,
        first.postalCode,
        first.country
      ];
      String address = addressComponents
          .where((component) => component != null && component.isNotEmpty)
          .join(', ');

      // Update the address provider
      final AddressProvider addressProvider = Provider.of<AddressProvider>(context, listen: false);
      addressProvider.updatePosition(
        lat: position.latitude,
        long: position.longitude,
        address: addresses
      );

      // Create the address object
      final Map<String, dynamic> addressData = {
        "title": "Home",
        "address": address,
        "city": first.locality ?? first.subLocality ?? "",
        "state": first.administrativeArea ?? "",
        "country": first.country ?? "",
        "pin": first.postalCode,
        "latlong": {
          "type": "Point",
          "coordinates": [position.longitude, position.latitude]
        },
        "userId": userID
      };

      apiBloc.add(CreateAddress(add: addressData));

      // Return to previous screen with location data
      Navigator.pop(context, {
        'formattedAddress': address,
        'coordinates': {'lat': position.latitude, 'lng': position.longitude},
        'street': first.name,
        'city': first.locality,
        'state': first.administrativeArea,
        'country': first.country,
        'postalCode': first.postalCode,
        'fullAddress': addresses
      });
    } catch (e) {
      showToast(
        text: "Error getting location: ${e.toString()}",
        color: Colors.red,
        context: context
      );
    }
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

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final sessionToken = const Uuid().v4();
    final String request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyDBjiwvS69uqWRXdAD4c1oF6Qobsfqj5Rg&sessiontoken=$sessionToken';

    try {
      final response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          return result['result'];
        }
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
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
              onTap: () {
                // Return the selected address data to the previous screen
                final locationData = {
                  'formattedAddress': address.data[index].address,
                  'street': address.data[index].address,
                  'city': address.data[index].city,
                  'state': address.data[index].state,
                  'country': address.data[index].country,
                  'postalCode': address.data[index].pin,
                  'coordinates': {
                    'lat': address.data[index].latlong?.coordinates?[1] ?? 0.0,
                    'lng': address.data[index].latlong?.coordinates?[0] ?? 0.0
                  },
                  'fullAddress': address.data[index]
                };
                Navigator.pop(context, locationData);
              },
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
                text:
                    state.message ?? 'Unknown error', // Provide a default value
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

  void showLocationConfirmationDialog(BuildContext context, Map<String, dynamic> locationData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address: ${locationData['formattedAddress']}'),
              const SizedBox(height: 8),
              Text('City: ${locationData['city']}'),
              Text('State: ${locationData['state']}'),
              Text('PIN: ${locationData['postalCode']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Pop dialog
                Navigator.pop(context);
                // Return location data to previous screen
                Navigator.pop(context, locationData);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Removed duplicate build method.
}
