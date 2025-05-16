// To parse this JSON data, do
//
//     final googleLoginRequestResponse = googleLoginRequestResponseFromJson(jsonString);

import 'dart:convert';

GoogleLoginRequestResponse googleLoginRequestResponseFromJson(String str) => GoogleLoginRequestResponse.fromJson(json.decode(str));

String googleLoginRequestResponseToJson(GoogleLoginRequestResponse data) => json.encode(data.toJson());

class GoogleLoginRequestResponse {
  final bool? status;
  final String? token;
  final User? user;
  final int? type;
  final String? message;

  GoogleLoginRequestResponse({
    this.status,
    this.token,
    this.user,
    this.type,
    this.message,
  });

  factory GoogleLoginRequestResponse.fromJson(Map<String, dynamic> json) => GoogleLoginRequestResponse(
    status: json["status"],
    token: json["token"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    type: json["type"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "token": token,
    "user": user?.toJson(),
    "type": type,
    "message": message,
  };
}

class User {
  final int? id;
  final String? userLogin;
  final String? name;
  final dynamic firstName;
  final dynamic lastName;
  final String? email;
  final String? phone;
  final String? loginType;
  final int? isSuperAdmin;
  final int? isActive;
  final int? isDeleted;
  final int? isEmailVerified;
  final DateTime? emailVerifiedAt;
  final dynamic avatar;
  final dynamic address;
  final dynamic city;
  final String? state;
  final String? country;
  final dynamic zipCode;
  final dynamic latitude;
  final dynamic longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final dynamic emailOtp;
  final dynamic otpExpiresAt;

  User({
    this.id,
    this.userLogin,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.loginType,
    this.isSuperAdmin,
    this.isActive,
    this.isDeleted,
    this.isEmailVerified,
    this.emailVerifiedAt,
    this.avatar,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.emailOtp,
    this.otpExpiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    userLogin: json["user_login"],
    name: json["name"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    phone: json["phone"],
    loginType: json["login_type"],
    isSuperAdmin: json["is_super_admin"],
    isActive: json["is_active"],
    isDeleted: json["is_deleted"],
    isEmailVerified: json["is_email_verified"],
    emailVerifiedAt: json["email_verified_at"] == null ? null : DateTime.parse(json["email_verified_at"]),
    avatar: json["avatar"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    zipCode: json["zip_code"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    emailOtp: json["email_otp"],
    otpExpiresAt: json["otp_expires_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_login": userLogin,
    "name": name,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "login_type": loginType,
    "is_super_admin": isSuperAdmin,
    "is_active": isActive,
    "is_deleted": isDeleted,
    "is_email_verified": isEmailVerified,
    "email_verified_at": emailVerifiedAt?.toIso8601String(),
    "avatar": avatar,
    "address": address,
    "city": city,
    "state": state,
    "country": country,
    "zip_code": zipCode,
    "latitude": latitude,
    "longitude": longitude,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "email_otp": emailOtp,
    "otp_expires_at": otpExpiresAt,
  };
}