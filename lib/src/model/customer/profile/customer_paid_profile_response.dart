// To parse this JSON data, do
//
//     final customerPaidProfileResponse = customerPaidProfileResponseFromJson(jsonString);

import 'dart:convert';

CustomerPaidProfileResponse customerPaidProfileResponseFromJson(String str) => CustomerPaidProfileResponse.fromJson(json.decode(str));

String customerPaidProfileResponseToJson(CustomerPaidProfileResponse data) => json.encode(data.toJson());

class CustomerPaidProfileResponse {
    final bool? status;
    final Data? data;
    final String? message;

    CustomerPaidProfileResponse({
        this.status,
        this.data,
        this.message,
    });

    CustomerPaidProfileResponse copyWith({
        bool? status,
        Data? data,
        String? message,
    }) => 
        CustomerPaidProfileResponse(
            status: status ?? this.status,
            data: data ?? this.data,
            message: message ?? this.message,
        );

    factory CustomerPaidProfileResponse.fromJson(Map<String, dynamic> json) => CustomerPaidProfileResponse(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
        "message": message,
    };
}

class Data {
    final String? aboutMe;
    final String? businessDetails;
    final List<String>? businessDetailsImages;
    final String? interestsHobbies;
    final List<String>? interestsHobbiesImages;
    final List<MyPreference>? myPreferences;
    final List<int>? myPreferencesIds;
    final List<FavoriteVenue>? favoriteVenues;
    final List<int>? favoriteVenuesIds;
    final String? photo;

    Data({
        this.aboutMe,
        this.businessDetails,
        this.businessDetailsImages,
        this.interestsHobbies,
        this.interestsHobbiesImages,
        this.myPreferences,
        this.myPreferencesIds,
        this.favoriteVenues,
        this.favoriteVenuesIds,
        this.photo,
    });

    Data copyWith({
        String? aboutMe,
        String? businessDetails,
        List<String>? businessDetailsImages,
        String? interestsHobbies,
        List<String>? interestsHobbiesImages,
        List<MyPreference>? myPreferences,
        List<int>? myPreferencesIds,
        List<FavoriteVenue>? favoriteVenues,
        List<int>? favoriteVenuesIds,
        String? photo,
    }) => 
        Data(
            aboutMe: aboutMe ?? this.aboutMe,
            businessDetails: businessDetails ?? this.businessDetails,
            businessDetailsImages: businessDetailsImages ?? this.businessDetailsImages,
            interestsHobbies: interestsHobbies ?? this.interestsHobbies,
            interestsHobbiesImages: interestsHobbiesImages ?? this.interestsHobbiesImages,
            myPreferences: myPreferences ?? this.myPreferences,
            myPreferencesIds: myPreferencesIds ?? this.myPreferencesIds,
            favoriteVenues: favoriteVenues ?? this.favoriteVenues,
            favoriteVenuesIds: favoriteVenuesIds ?? this.favoriteVenuesIds,
            photo: photo ?? this.photo,
        );

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        aboutMe: json["about_me"],
        businessDetails: json["business_details"],
        businessDetailsImages: json["business_details_images"] == null ? [] : List<String>.from(json["business_details_images"]!.map((x) => x)),
        interestsHobbies: json["interests_hobbies"],
        interestsHobbiesImages: json["interests_hobbies_images"] == null ? [] : List<String>.from(json["interests_hobbies_images"]!.map((x) => x)),
        myPreferences: json["my_preferences"] == null ? [] : List<MyPreference>.from(json["my_preferences"]!.map((x) => MyPreference.fromJson(x))),
        myPreferencesIds: json["my_preferences_ids"] == null ? [] : List<int>.from(json["my_preferences_ids"]!.map((x) => x)),
        favoriteVenues: json["favorite_venues"] == null ? [] : List<FavoriteVenue>.from(json["favorite_venues"]!.map((x) => FavoriteVenue.fromJson(x))),
        favoriteVenuesIds: json["favorite_venues_ids"] == null ? [] : List<int>.from(json["favorite_venues_ids"]!.map((x) => x)),
        photo: json["photo"],
    );

    Map<String, dynamic> toJson() => {
        "about_me": aboutMe,
        "business_details": businessDetails,
        "business_details_images": businessDetailsImages == null ? [] : List<dynamic>.from(businessDetailsImages!.map((x) => x)),
        "interests_hobbies": interestsHobbies,
        "interests_hobbies_images": interestsHobbiesImages == null ? [] : List<dynamic>.from(interestsHobbiesImages!.map((x) => x)),
        "my_preferences": myPreferences == null ? [] : List<dynamic>.from(myPreferences!.map((x) => x.toJson())),
        "my_preferences_ids": myPreferencesIds == null ? [] : List<dynamic>.from(myPreferencesIds!.map((x) => x)),
        "favorite_venues": favoriteVenues == null ? [] : List<dynamic>.from(favoriteVenues!.map((x) => x.toJson())),
        "favorite_venues_ids": favoriteVenuesIds == null ? [] : List<dynamic>.from(favoriteVenuesIds!.map((x) => x)),
        "photo": photo,
    };
}

class FavoriteVenue {
    final int? id;
    final String? name;
    final bool? notification;

    FavoriteVenue({
        this.id,
        this.name,
        this.notification,
    });

    FavoriteVenue copyWith({
        int? id,
        String? name,
        bool? notification,
    }) => 
        FavoriteVenue(
            id: id ?? this.id,
            name: name ?? this.name,
            notification: notification ?? this.notification,
        );

    factory FavoriteVenue.fromJson(Map<String, dynamic> json) => FavoriteVenue(
        id: json["id"],
        name: json["name"],
        notification: json["notification"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "notification": notification,
    };
}

class MyPreference {
    final int? id;
    final String? name;
    final bool? isPreferences;

    MyPreference({
        this.id,
        this.name,
        this.isPreferences,
    });

    MyPreference copyWith({
        int? id,
        String? name,
        bool? isPreferences,
    }) => 
        MyPreference(
            id: id ?? this.id,
            name: name ?? this.name,
            isPreferences: isPreferences ?? this.isPreferences,
        );

    factory MyPreference.fromJson(Map<String, dynamic> json) => MyPreference(
        id: json["id"],
        name: json["name"],
        isPreferences: json["isPreferences"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "isPreferences": isPreferences,
    };
}
