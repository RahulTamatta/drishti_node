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
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) => AddressData(
        id: json["_id"].toString(),
        title: json["title"].toString(),
        address: json["address"].toString(),
        city: json["city"].toString(),
        state: json["state"].toString(),
        country: json["country"].toString(),
        pin: json["pin"].toString(),
        userId: json["userId"].toString(),
        createdAt: DateTime.parse(json["createdAt"].toString()),
        updatedAt: DateTime.parse(json["updatedAt"].toString()),
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
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}
