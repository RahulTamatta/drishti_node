// To parse this JSON data, do
//
//     final address = addressFromJson(jsonString);

import 'dart:convert';

Address addressFromJson(dynamic str) => Address.fromJson(str);

String addressToJson(Address data) => json.encode(data.toJson());

class Address {
  String message;
  List<AddressData> data;

  Address({
    required this.message,
    required this.data,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        message: json["message"],
        data: List<AddressData>.from(
            json["data"].map((x) => AddressData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class AddressData {
  String id;
  String title;
  String address;
  String city;
  String state;
  String country;
  String pin;
  String userId;
  LatLong? latlong;  // Add this field
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  AddressData({
    required this.id,
    required this.title,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pin,
    required this.userId,
    this.latlong,  // Add this parameter
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) => AddressData(
        id: json["_id"],
        title: json["title"],
        address: json["address"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        pin: json["pin"],
        userId: json["userId"],
        latlong: json["latlong"] != null ? LatLong.fromJson(json["latlong"]) : null,  // Add this line
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "address": address,
        "city": city,
        "state": state,
        "country": country,
        "pin": pin,
        "userId": userId,
        "latlong": latlong?.toJson(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}

class LatLong {
  String type;
  List<double> coordinates;

  LatLong({
    required this.type,
    required this.coordinates,
  });

  factory LatLong.fromJson(Map<String, dynamic> json) => LatLong(
        type: json["type"],
        coordinates: List<double>.from(json["coordinates"].map((x) => x.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
      };
}