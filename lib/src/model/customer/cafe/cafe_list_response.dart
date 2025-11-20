// // To parse this JSON data, do
// //
// //     final cafeListResponse = cafeListResponseFromJson(jsonString);

// import 'dart:convert';

// CafeListResponse cafeListResponseFromJson(String str) => CafeListResponse.fromJson(json.decode(str));

// String cafeListResponseToJson(CafeListResponse data) => json.encode(data.toJson());

// class CafeListResponse {
//     final bool? status;
//     final String? message;
//     final List<Cafe>? cafes;

//     CafeListResponse({
//         this.status,
//         this.message,
//         this.cafes,
//     });

//     CafeListResponse copyWith({
//         bool? status,
//         String? message,
//         List<Cafe>? cafes,
//     }) => 
//         CafeListResponse(
//             status: status ?? this.status,
//             message: message ?? this.message,
//             cafes: cafes ?? this.cafes,
//         );

//     factory CafeListResponse.fromJson(Map<String, dynamic> json) => CafeListResponse(
//         status: json["status"],
//         message: json["message"],
//         cafes: json["cafes"] == null ? [] : List<Cafe>.from(json["cafes"]!.map((x) => Cafe.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "cafes": cafes == null ? [] : List<dynamic>.from(cafes!.map((x) => x.toJson())),
//     };
// }

// class Cafe {
//     final int? id;
//     final String? name;
//     final String? venueDescription;
//     final List<String>? tableTypes;
//     final String? photo;
//     final List<String>? gallery;
//     final bool? favourites;
//     final bool? bookingStatus;
//     final List<WorkingHour>? workingHours;
//     final String? latitude;
//     final String? longitude;
//     final List<Attende>? attendes;

//     Cafe({
//         this.id,
//         this.name,
//         this.venueDescription,
//         this.tableTypes,
//         this.photo,
//         this.gallery,
//         this.favourites,
//         this.bookingStatus,
//         this.workingHours,
//         this.latitude,
//         this.longitude,
//         this.attendes,
//     });

//     Cafe copyWith({
//         int? id,
//         String? name,
//         String? venueDescription,
//         List<String>? tableTypes,
//         String? photo,
//         List<String>? gallery,
//         bool? favourites,
//         bool? bookingStatus,
//         List<WorkingHour>? workingHours,
//         String? latitude,
//         String? longitude,
//         List<Attende>? attendes,
//     }) => 
//         Cafe(
//             id: id ?? this.id,
//             name: name ?? this.name,
//             venueDescription: venueDescription ?? this.venueDescription,
//             tableTypes: tableTypes ?? this.tableTypes,
//             photo: photo ?? this.photo,
//             gallery: gallery ?? this.gallery,
//             favourites: favourites ?? this.favourites,
//             bookingStatus: bookingStatus ?? this.bookingStatus,
//             workingHours: workingHours ?? this.workingHours,
//             latitude: latitude ?? this.latitude,
//             longitude: longitude ?? this.longitude,
//             attendes: attendes ?? this.attendes,
//         );

//     factory Cafe.fromJson(Map<String, dynamic> json) => Cafe(
//         id: json["id"],
//         name: json["name"],
//         venueDescription: json["venue_description"],
//         tableTypes: json["table_types"] == null ? [] : List<String>.from(json["table_types"]!.map((x) => x)),
//         photo: json["photo"],
//         gallery: json["gallery"] == null ? [] : List<String>.from(json["gallery"]!.map((x) => x)),
//         favourites: json["favourites"],
//         bookingStatus: json["booking_status"],
//         workingHours: json["working_hours"] == null ? [] : List<WorkingHour>.from(json["working_hours"]!.map((x) => WorkingHour.fromJson(x))),
//         latitude: json["latitude"],
//         longitude: json["longitude"],
//         attendes: json["attendes"] == null ? [] : List<Attende>.from(json["attendes"]!.map((x) => Attende.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "venue_description": venueDescription,
//         "table_types": tableTypes == null ? [] : List<dynamic>.from(tableTypes!.map((x) => x)),
//         "photo": photo,
//         "gallery": gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
//         "favourites": favourites,
//         "booking_status": bookingStatus,
//         "working_hours": workingHours == null ? [] : List<dynamic>.from(workingHours!.map((x) => x.toJson())),
//         "latitude": latitude,
//         "longitude": longitude,
//         "attendes": attendes == null ? [] : List<dynamic>.from(attendes!.map((x) => x.toJson())),
//     };
// }

// class Attende {
//     final String? name;
//     final String? email;
//     final String? profilePhoto;
//     final String? additionalInfo;

//     Attende({
//         this.name,
//         this.email,
//         this.profilePhoto,
//         this.additionalInfo,
//     });

//     Attende copyWith({
//         String? name,
//         String? email,
//         String? profilePhoto,
//         String? additionalInfo,
//     }) => 
//         Attende(
//             name: name ?? this.name,
//             email: email ?? this.email,
//             profilePhoto: profilePhoto ?? this.profilePhoto,
//             additionalInfo: additionalInfo ?? this.additionalInfo,
//         );

//     factory Attende.fromJson(Map<String, dynamic> json) => Attende(
//         name: json["name"],
//         email: json["email"],
//         profilePhoto: json["profile_photo"],
//         additionalInfo: json["additional_info"],
//     );

//     Map<String, dynamic> toJson() => {
//         "name": name,
//         "email": email,
//         "profile_photo": profilePhoto,
//         "additional_info": additionalInfo,
//     };
// }

// class WorkingHour {
//     final String? day;
//     final int? isOpen;
//     final String? opening;
//     final String? closing;

//     WorkingHour({
//         this.day,
//         this.isOpen,
//         this.opening,
//         this.closing,
//     });

//     WorkingHour copyWith({
//         String? day,
//         int? isOpen,
//         String? opening,
//         String? closing,
//     }) => 
//         WorkingHour(
//             day: day ?? this.day,
//             isOpen: isOpen ?? this.isOpen,
//             opening: opening ?? this.opening,
//             closing: closing ?? this.closing,
//         );

//     factory WorkingHour.fromJson(Map<String, dynamic> json) => WorkingHour(
//         day: json["day"],
//         isOpen: json["is_open"],
//         opening: json["opening"],
//         closing: json["closing"],
//     );

//     Map<String, dynamic> toJson() => {
//         "day": day,
//         "is_open": isOpen,
//         "opening": opening,
//         "closing": closing,
//     };
// }


// To parse this JSON data, do
//
//     final cafeListResponse = cafeListResponseFromJson(jsonString);

import 'dart:convert';

import 'package:soloseaters/src/model/customer/cafe/favourite_list_response.dart';

CafeListResponse cafeListResponseFromJson(String str) => CafeListResponse.fromJson(json.decode(str));

String cafeListResponseToJson(CafeListResponse data) => json.encode(data.toJson());

class CafeListResponse {
    final bool? status;
    final String? message;
    final List<Cafe>? cafes;

    CafeListResponse({
        this.status,
        this.message,
        this.cafes,
    });

    CafeListResponse copyWith({
        bool? status,
        String? message,
        List<Cafe>? cafes,
    }) => 
        CafeListResponse(
            status: status ?? this.status,
            message: message ?? this.message,
            cafes: cafes ?? this.cafes,
        );

    factory CafeListResponse.fromJson(Map<String, dynamic> json) => CafeListResponse(
        status: json["status"],
        message: json["message"],
        cafes: json["cafes"] == null ? [] : List<Cafe>.from(json["cafes"]!.map((x) => Cafe.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "cafes": cafes == null ? [] : List<dynamic>.from(cafes!.map((x) => x.toJson())),
    };
}

class Cafe {
    final int? id;
    final String? name;
    final String? venueDescription;
    final List<String>? tableTypes;
    final String? photo;
    final List<String>? gallery;
    final bool? favourites;
    final bool? bookingStatus;
    final List<WorkingHour>? workingHours;
    final String? latitude;
    final String? longitude;
    final List<Attende>? attendes;
    final List<UpcomingEvent>? upcomingEvents;

    Cafe({
        this.id,
        this.name,
        this.venueDescription,
        this.tableTypes,
        this.photo,
        this.gallery,
        this.favourites,
        this.bookingStatus,
        this.workingHours,
        this.latitude,
        this.longitude,
        this.attendes,
        this.upcomingEvents,
    });

    Cafe copyWith({
        int? id,
        String? name,
        String? venueDescription,
        List<String>? tableTypes,
        String? photo,
        List<String>? gallery,
        bool? favourites,
        bool? bookingStatus,
        List<WorkingHour>? workingHours,
        String? latitude,
        String? longitude,
        List<Attende>? attendes,
        List<UpcomingEvent>? upcomingEvents,
    }) => 
        Cafe(
            id: id ?? this.id,
            name: name ?? this.name,
            venueDescription: venueDescription ?? this.venueDescription,
            tableTypes: tableTypes ?? this.tableTypes,
            photo: photo ?? this.photo,
            gallery: gallery ?? this.gallery,
            favourites: favourites ?? this.favourites,
            bookingStatus: bookingStatus ?? this.bookingStatus,
            workingHours: workingHours ?? this.workingHours,
            latitude: latitude ?? this.latitude,
            longitude: longitude ?? this.longitude,
            attendes: attendes ?? this.attendes,
            upcomingEvents: upcomingEvents ?? this.upcomingEvents,
        );

    factory Cafe.fromJson(Map<String, dynamic> json) => Cafe(
        id: json["id"],
        name: json["name"],
        venueDescription: json["venue_description"],
        tableTypes: json["table_types"] == null ? [] : List<String>.from(json["table_types"]!.map((x) => x)),
        photo: json["photo"],
        gallery: json["gallery"] == null ? [] : List<String>.from(json["gallery"]!.map((x) => x)),
        favourites: json["favourites"],
        bookingStatus: json["booking_status"],
        workingHours: json["working_hours"] == null ? [] : List<WorkingHour>.from(json["working_hours"]!.map((x) => WorkingHour.fromJson(x))),
        latitude: json["latitude"],
        longitude: json["longitude"],
        attendes: json["attendes"] == null ? [] : List<Attende>.from(json["attendes"]!.map((x) => Attende.fromJson(x))),
        upcomingEvents: json["upcoming_events"] == null ? [] : List<UpcomingEvent>.from(json["upcoming_events"]!.map((x) => UpcomingEvent.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "venue_description": venueDescription,
        "table_types": tableTypes == null ? [] : List<dynamic>.from(tableTypes!.map((x) => x)),
        "photo": photo,
        "gallery": gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
        "favourites": favourites,
        "booking_status": bookingStatus,
        "working_hours": workingHours == null ? [] : List<dynamic>.from(workingHours!.map((x) => x.toJson())),
        "latitude": latitude,
        "longitude": longitude,
        "attendes": attendes == null ? [] : List<dynamic>.from(attendes!.map((x) => x.toJson())),
        "upcoming_events": upcomingEvents == null ? [] : List<dynamic>.from(upcomingEvents!.map((x) => x.toJson())),
    };
}

class Attende {
    final String? name;
    final String? email;
    final String? profilePhoto;
    final String? additionalInfo;

    Attende({
        this.name,
        this.email,
        this.profilePhoto,
        this.additionalInfo,
    });

    Attende copyWith({
        String? name,
        String? email,
        String? profilePhoto,
        String? additionalInfo,
    }) => 
        Attende(
            name: name ?? this.name,
            email: email ?? this.email,
            profilePhoto: profilePhoto ?? this.profilePhoto,
            additionalInfo: additionalInfo ?? this.additionalInfo,
        );

    factory Attende.fromJson(Map<String, dynamic> json) => Attende(
        name: json["name"],
        email: json["email"],
        profilePhoto: json["profile_photo"],
        additionalInfo: json["additional_info"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "profile_photo": profilePhoto,
        "additional_info": additionalInfo,
    };
}

class UpcomingEvent {
    final int? id;
    final String? name;
    final String? description;
    final List<AvailableDay>? availableDays;

    UpcomingEvent({
        this.id,
        this.name,
        this.description,
        this.availableDays,
    });

    UpcomingEvent copyWith({
        int? id,
        String? name,
        String? description,
        List<AvailableDay>? availableDays,
    }) => 
        UpcomingEvent(
            id: id ?? this.id,
            name: name ?? this.name,
            description: description ?? this.description,
            availableDays: availableDays ?? this.availableDays,
        );

    factory UpcomingEvent.fromJson(Map<String, dynamic> json) => UpcomingEvent(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        availableDays: json["available_days"] == null ? [] : List<AvailableDay>.from(json["available_days"]!.map((x) => AvailableDay.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "available_days": availableDays == null ? [] : List<dynamic>.from(availableDays!.map((x) => x.toJson())),
    };

  void operator [](String other) {}
}

class AvailableDay {
    final dynamic isOpen;
    final String? day;
    final String? open;
    final String? close;
    final int? id;
    final List<Timing>? timings;
    final String? openTime;
    final String? closeTime;

    AvailableDay({
        this.isOpen,
        this.day,
        this.open,
        this.close,
        this.id,
        this.timings,
        this.openTime,
        this.closeTime,
    });

    AvailableDay copyWith({
        dynamic isOpen,
        String? day,
        String? open,
        String? close,
        int? id,
        List<Timing>? timings,
        String? openTime,
        String? closeTime,
    }) => 
        AvailableDay(
            isOpen: isOpen ?? this.isOpen,
            day: day ?? this.day,
            open: open ?? this.open,
            close: close ?? this.close,
            id: id ?? this.id,
            timings: timings ?? this.timings,
            openTime: openTime ?? this.openTime,
            closeTime: closeTime ?? this.closeTime,
        );

    factory AvailableDay.fromJson(Map<String, dynamic> json) => AvailableDay(
        isOpen: json["is_open"],
        day: json["day"],
        open: json["open"],
        close: json["close"],
        id: json["id"],
        timings: json["timings"] == null ? [] : List<Timing>.from(json["timings"]!.map((x) => Timing.fromJson(x))),
        openTime: json["open_time"],
        closeTime: json["close_time"],
    );

    Map<String, dynamic> toJson() => {
        "is_open": isOpen,
        "day": day,
        "open": open,
        "close": close,
        "id": id,
        "timings": timings == null ? [] : List<dynamic>.from(timings!.map((x) => x.toJson())),
        "open_time": openTime,
        "close_time": closeTime,
    };
}

class Timing {
    final String? open;
    final String? close;

    Timing({
        this.open,
        this.close,
    });

    Timing copyWith({
        String? open,
        String? close,
    }) => 
        Timing(
            open: open ?? this.open,
            close: close ?? this.close,
        );

    factory Timing.fromJson(Map<String, dynamic> json) => Timing(
        open: json["open"],
        close: json["close"],
    );

    Map<String, dynamic> toJson() => {
        "open": open,
        "close": close,
    };
}

class WorkingHour {
    final String? day;
    final bool? isOpen;
    final String? opening;
    final String? closing;

    WorkingHour({
        this.day,
        this.isOpen,
        this.opening,
        this.closing,
    });

    WorkingHour copyWith({
        String? day,
        bool? isOpen,
        String? opening,
        String? closing,
    }) => 
        WorkingHour(
            day: day ?? this.day,
            isOpen: isOpen ?? this.isOpen,
            opening: opening ?? this.opening,
            closing: closing ?? this.closing,
        );

    factory WorkingHour.fromJson(Map<String, dynamic> json) => WorkingHour(
        day: json["day"],
        isOpen: json["is_open"],
        opening: json["opening"],
        closing: json["closing"],
    );
    factory WorkingHour.fromFavWorkingHour(FavWorkingHour favHour) {
      return WorkingHour(
        day: favHour.day,
        // Convert int? (0 or 1) to bool? (false or true). 
        // We assume 1 is true and 0/null is false/null.
        isOpen: favHour.isOpen == null ? null : favHour.isOpen == 1, 
        opening: favHour.opening,
        closing: favHour.closing,
      );
    }

    Map<String, dynamic> toJson() => {
        "day": day,
        "is_open": isOpen,
        "opening": opening,
        "closing": closing,
    };
}
