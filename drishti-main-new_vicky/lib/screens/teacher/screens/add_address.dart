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

class AddAddressScreen extends StatefulWidget {
  final AddressData? addressData;
  const AddAddressScreen({super.key, this.addressData});

  @override
  AddAddressScreenState createState() => AddAddressScreenState();
}

class AddAddressScreenState extends State<AddAddressScreen> {
  String selectedCountry = 'India';
  String selectedCity = 'Patna';
  String selectedState = 'Bihar';
  String title = 'Home';
  TextEditingController addressController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.addressData!.id.isNotEmpty) {
      addressController.text = widget.addressData!.address;
      pincodeController.text = widget.addressData!.pin;
      selectedCountry = widget.addressData!.country;
      selectedCity = widget.addressData!.city;
      selectedState = widget.addressData!.state;
    }
  }

  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  data(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var userID = prefs.getString("UserID");

    Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high));

    if (widget.addressData!.id.isNotEmpty) {
      // object id should be send

      apiBloc.add(EditAddress(id: widget.addressData!.id, add: {
        "title": title,
        "address": addressController.text,
        "city": selectedCity,
        "state": selectedState,
        "country": selectedCountry,
        "pin": pincodeController.text,
        "location": {
          "type": "Point",
          "coordinates": [position.latitude, position.longitude]
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
          "coordinates": [position.latitude, position.longitude]
        },
        "userId": userID
      }));
    }

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
              canPop: false, // prevent back
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
              value: selectedCountry,
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
              value: selectedCity,
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
              items: <String>['Patna']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedState,
              decoration: InputDecoration(
                labelText: 'Select State',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedState = newValue!;
                });
              },
              items: <String>['Patna']
                  .map<DropdownMenuItem<String>>((String value) {
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
