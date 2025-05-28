// To parse this JSON data, do
//
//     final customerGetProfileResponse = customerGetProfileResponseFromJson(jsonString);

import 'dart:convert';

CustomerGetProfileResponse customerGetProfileResponseFromJson(String str) => CustomerGetProfileResponse.fromJson(json.decode(str));

String customerGetProfileResponseToJson(CustomerGetProfileResponse data) => json.encode(data.toJson());

class CustomerGetProfileResponse {
  final bool? status;
  final CustomerProfileData? data;
  final String? message;

  CustomerGetProfileResponse({
    this.status,
    this.data,
    this.message,
  });

  CustomerGetProfileResponse copyWith({
    bool? status,
    CustomerProfileData? data,
    String? message,
  }) =>
      CustomerGetProfileResponse(
        status: status ?? this.status,
        data: data ?? this.data,
        message: message ?? this.message,
      );

  factory CustomerGetProfileResponse.fromJson(Map<String, dynamic> json) => CustomerGetProfileResponse(
    status: json["status"],
    data: json["data"] == null ? null : CustomerProfileData.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "message": message,
  };
}

class CustomerProfileData {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? country;
  final String? state;

  CustomerProfileData({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.country,
    this.state,
  });

  CustomerProfileData copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? country,
    String? state,
  }) =>
      CustomerProfileData(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        country: country ?? this.country,
        state: state ?? this.state,
      );

  factory CustomerProfileData.fromJson(Map<String, dynamic> json) => CustomerProfileData(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    country: json["country"],
    state: json["state"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "country": country,
    "state": state,
  };
}
