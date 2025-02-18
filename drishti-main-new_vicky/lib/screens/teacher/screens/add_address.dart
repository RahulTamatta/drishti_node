import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/models/Address.dart';
import 'package:srisridrishti/screens/teacher/screens/selectLocation.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/location_services/user_location_service.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressData? addressData;
  const AddAddressScreen({super.key, this.addressData});

  @override
  AddAddressScreenState createState() => AddAddressScreenState();
}

class AddAddressScreenState extends State<AddAddressScreen> {
  String selectedCountry = '';
  String selectedCity = '';
  String selectedState = '';
  String title = '';
  TextEditingController addressController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  List<String> cities = [];
  List<String> states = [];
  bool isLoadingCities = false;
  bool isLoadingStates = false;

  @override
  void initState() {
    super.initState();
    // Check if addressData exists and has an id before accessing its properties
    if (widget.addressData != null && widget.addressData!.id.isNotEmpty) {
      addressController.text = widget.addressData!.address;
      pincodeController.text = widget.addressData!.pin;
      // When location is selected, parse the components
      String extractCityFromAddress(String fullAddress) {
        List<String> components = fullAddress.split(',');
        // For "Texas, USA" format, we should use the first component as state
        // and set city appropriately
        if (components.length >= 1) {
          return components[0]
              .trim(); // Use first component as city if no better option
        }
        return '';
      }

      // In the data() method, before making API call:
      if (selectedCity.isEmpty) {
        // Try to extract city from address
        selectedCity = extractCityFromAddress(addressController.text);
      }

      // Validate all required fields
      if (selectedCity.isEmpty) {
        showToast(
            text: "Please select or enter a valid city",
            color: Colors.red,
            context: context);
        return;
      }
      selectedCountry = widget.addressData!.country;
      selectedCity = widget.addressData!.city;
      selectedState = widget.addressData!.state;
      title = widget.addressData!.title;
    }
    fetchStates();
  }

  Future<void> fetchStates() async {
    setState(() {
      isLoadingStates = true;
    });
    states = await LocationService.getStates(selectedCountry);
    setState(() {
      isLoadingStates = false;
    });
  }

  Future<void> fetchCities(String state) async {
    setState(() {
      isLoadingCities = true;
    });
    cities = await LocationService.getCities(state);
    setState(() {
      isLoadingCities = false;
    });
  }

  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  data(context) async {
    // Validate required fields
    if (pincodeController.text.trim().isEmpty) {
      showToast(
          text: "Please enter a valid PIN code",
          color: Colors.red,
          context: context);
      return;
    }

    if (addressController.text.trim().isEmpty) {
      showToast(
          text: "Please enter a complete address",
          color: Colors.red,
          context: context);
      return;
    }

    if (selectedCity.isEmpty ||
        selectedState.isEmpty ||
        selectedCountry.isEmpty) {
      showToast(
          text: "Please select country, state and city",
          color: Colors.red,
          context: context);
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString("UserID");

    if (userID == null) {
      showToast(
          text: "User ID not found. Please login again.",
          color: Colors.red,
          context: context);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));

      // Check if we're editing an existing address or creating a new one
      if (widget.addressData != null && widget.addressData!.id.isNotEmpty) {
        apiBloc.add(EditAddress(id: widget.addressData!.id, add: {
          "title": title,
          "address": addressController.text,
          "city": selectedCity,
          "state": selectedState,
          "country": selectedCountry,
          "pin": pincodeController.text,
          "location": {
            "type": "Point",
            "coordinates": [position.longitude, position.latitude]
          },
          "userId": userID
        }));
      } else {
        apiBloc.add(CreateAddress(add: {
          "title": title,
          "address": addressController.text,
          "city": selectedCity,
          "state": selectedState,
          "country": selectedCountry,
          "pin": pincodeController.text,
          "latlong": {
            "type": "Point",
            "coordinates": [position.longitude, position.latitude]
          },
          "userId": userID
        }));
      }

      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return PopScope(
                canPop: false,
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
    } catch (e) {
      showToast(
          text: "Error: ${e.toString()}", color: Colors.red, context: context);
    }
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SelectLocationScreen()));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Address"),
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
            DropdownButtonFormField<String>(
              value: selectedCountry.isNotEmpty ? selectedCountry : null,
              decoration: InputDecoration(
                labelText: 'Select Country',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCountry = newValue!;
                });
              },
              items: <String>['India']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedState.isNotEmpty ? selectedState : null,
              decoration: InputDecoration(
                labelText: 'Select State',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedState = newValue!;
                  fetchCities(newValue);
                });
              },
              items: states.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCity.isNotEmpty ? selectedCity : null,
              decoration: InputDecoration(
                labelText: 'Select City',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCity = newValue!;
                });
              },
              items: cities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Enter complete Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pincodeController,
              decoration: InputDecoration(
                labelText: 'ZIP/Pincode',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Handle saving the address

                data(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save Address'),
            ),
          ],
        ),
      ),
    );
  }
}
