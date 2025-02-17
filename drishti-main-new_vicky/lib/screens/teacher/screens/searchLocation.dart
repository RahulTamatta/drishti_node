import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class LocationAutoComplete extends StatefulWidget {
  const LocationAutoComplete({super.key});

  @override
  LocationAutoCompleteState createState() => LocationAutoCompleteState();
}

class LocationAutoCompleteState extends State<LocationAutoComplete> {
  final searchController = TextEditingController();
  final String token = '1234567890';
  var uuid = const Uuid();
  List<dynamic> listOfLocation = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      _onChange();
    });
    print("LocationAutoComplete initialized");
  }

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
              physics: const NeverScrollableScrollPhysics(),
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
        Visibility(
          visible: searchController.text.isEmpty,
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () {
                print("My Location button pressed");
                // Handle 'My Location' button action
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.my_location,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "My Location",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
