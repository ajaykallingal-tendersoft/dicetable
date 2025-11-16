// To parse this JSON data, do
//
//     final tokenRefreshResponse = tokenRefreshResponseFromJson(jsonString);

import 'dart:convert';

TokenRefreshResponse tokenRefreshResponseFromJson(String str) => TokenRefreshResponse.fromJson(json.decode(str));

String tokenRefreshResponseToJson(TokenRefreshResponse data) => json.encode(data.toJson());

class TokenRefreshResponse {
    final bool? status;
    final String? token;
    final String? tokenType;
    final int? expiresIn;
    final String? message;

    TokenRefreshResponse({
        this.status,
        this.token,
        this.tokenType,
        this.expiresIn,
        this.message,
    });

    factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) => TokenRefreshResponse(
        status: json["status"],
        token: json["token"],
        tokenType: json["token_type"],
        expiresIn: json["expires_in"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "token": token,
        "token_type": tokenType,
        "expires_in": expiresIn,
        "message": message,
    };
}
