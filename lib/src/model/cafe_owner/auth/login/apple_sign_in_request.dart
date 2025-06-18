

import 'package:meta/meta.dart';
import 'dart:convert';

AppleSignInRequest appleSignInRequestFromJson(String str) => AppleSignInRequest.fromJson(json.decode(str));

String appleSignInRequestToJson(AppleSignInRequest data) => json.encode(data.toJson());

class AppleSignInRequest {
  final String identityToken;
  final String loginType;

  AppleSignInRequest({
    required this.identityToken,
    required this.loginType,
  });

  factory AppleSignInRequest.fromJson(Map<String, dynamic> json) => AppleSignInRequest(
    identityToken: json["identity_token"],
    loginType: json["login_type"],
  );

  Map<String, dynamic> toJson() => {
    "identity_token": identityToken,
    "login_type": loginType,
  };
}
