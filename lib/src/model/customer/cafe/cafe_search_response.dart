// To parse this JSON data, do
//
//     final cafeSearchResponse = cafeSearchResponseFromJson(jsonString);

import 'dart:convert';

CafeSearchResponse cafeSearchResponseFromJson(String str) => CafeSearchResponse.fromJson(json.decode(str));

String cafeSearchResponseToJson(CafeSearchResponse data) => json.encode(data.toJson());

class CafeSearchResponse {
  final bool? status;
  final String? message;
  final List<Datum>? data;

  CafeSearchResponse({
    this.status,
    this.message,
    this.data,
  });

  CafeSearchResponse copyWith({
    bool? status,
    String? message,
    List<Datum>? data,
  }) =>
      CafeSearchResponse(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory CafeSearchResponse.fromJson(Map<String, dynamic> json) => CafeSearchResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  final int? id;
  final int? userId;
  final String? name;
  final String? venueDescription;
  final String? email;
  final String? phone;
  final String? address;
  final String? state;
  final String? city;
  final String? latitude;
  final String? longitude;
  final String? postcode;
  final List<Accommodation>? accommodations;
  final List<DiceTable>? diceTables;
  final List<SubscriptionElement>? subscriptions;
  final List<Accommodation>? dicetables;
  final String? photo;
  final List<Workingday>? workingdays;
  final List<Specialday>? specialdays;

  Datum({
    this.id,
    this.userId,
    this.name,
    this.venueDescription,
    this.email,
    this.phone,
    this.address,
    this.state,
    this.city,
    this.latitude,
    this.longitude,
    this.postcode,
    this.accommodations,
    this.diceTables,
    this.subscriptions,
    this.dicetables,
    this.photo,
    this.workingdays,
    this.specialdays,
  });

  Datum copyWith({
    int? id,
    int? userId,
    String? name,
    String? venueDescription,
    String? email,
    String? phone,
    String? address,
    String? state,
    String? city,
    String? latitude,
    String? longitude,
    String? postcode,
    List<Accommodation>? accommodations,
    List<DiceTable>? diceTables,
    List<SubscriptionElement>? subscriptions,
    List<Accommodation>? dicetables,
    String? photo,
    List<Workingday>? workingdays,
    List<Specialday>? specialdays,
  }) =>
      Datum(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        venueDescription: venueDescription ?? this.venueDescription,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        state: state ?? this.state,
        city: city ?? this.city,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        postcode: postcode ?? this.postcode,
        accommodations: accommodations ?? this.accommodations,
        diceTables: diceTables ?? this.diceTables,
        subscriptions: subscriptions ?? this.subscriptions,
        dicetables: dicetables ?? this.dicetables,
        photo: photo ?? this.photo,
        workingdays: workingdays ?? this.workingdays,
        specialdays: specialdays ?? this.specialdays,
      );

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    userId: json["user_id"],
    name: json["name"],
    venueDescription: json["venue_description"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    state: json["state"],
    city: json["city"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    postcode: json["postcode"],
    accommodations: json["accommodations"] == null ? [] : List<Accommodation>.from(json["accommodations"]!.map((x) => Accommodation.fromJson(x))),
    diceTables: json["dice_tables"] == null ? [] : List<DiceTable>.from(json["dice_tables"]!.map((x) => DiceTable.fromJson(x))),
    subscriptions: json["subscriptions"] == null ? [] : List<SubscriptionElement>.from(json["subscriptions"]!.map((x) => SubscriptionElement.fromJson(x))),
    dicetables: json["dicetables"] == null ? [] : List<Accommodation>.from(json["dicetables"]!.map((x) => Accommodation.fromJson(x))),
    photo: json["photo"],
    workingdays: json["workingdays"] == null ? [] : List<Workingday>.from(json["workingdays"]!.map((x) => Workingday.fromJson(x))),
    specialdays: json["specialdays"] == null ? [] : List<Specialday>.from(json["specialdays"]!.map((x) => Specialday.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "name": name,
    "venue_description": venueDescription,
    "email": email,
    "phone": phone,
    "address": address,
    "state": state,
    "city": city,
    "latitude": latitude,
    "longitude": longitude,
    "postcode": postcode,
    "accommodations": accommodations == null ? [] : List<dynamic>.from(accommodations!.map((x) => x.toJson())),
    "dice_tables": diceTables == null ? [] : List<dynamic>.from(diceTables!.map((x) => x.toJson())),
    "subscriptions": subscriptions == null ? [] : List<dynamic>.from(subscriptions!.map((x) => x.toJson())),
    "dicetables": dicetables == null ? [] : List<dynamic>.from(dicetables!.map((x) => x.toJson())),
    "photo": photo,
    "workingdays": workingdays == null ? [] : List<dynamic>.from(workingdays!.map((x) => x.toJson())),
    "specialdays": specialdays == null ? [] : List<dynamic>.from(specialdays!.map((x) => x.toJson())),
  };
}

class Accommodation {
  final int? id;
  final String? title;

  Accommodation({
    this.id,
    this.title,
  });

  Accommodation copyWith({
    int? id,
    String? title,
  }) =>
      Accommodation(
        id: id ?? this.id,
        title: title ?? this.title,
      );

  factory Accommodation.fromJson(Map<String, dynamic> json) => Accommodation(
    id: json["id"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
  };
}

class DiceTable {
  final int? id;
  final String? title;
  final String? subTitle;
  final String? description;
  final String? iconImage;
  final String? createdAt;
  final String? updatedAt;
  final Pivot? pivot;

  DiceTable({
    this.id,
    this.title,
    this.subTitle,
    this.description,
    this.iconImage,
    this.createdAt,
    this.updatedAt,
    this.pivot,
  });

  DiceTable copyWith({
    int? id,
    String? title,
    String? subTitle,
    String? description,
    String? iconImage,
    String? createdAt,
    String? updatedAt,
    Pivot? pivot,
  }) =>
      DiceTable(
        id: id ?? this.id,
        title: title ?? this.title,
        subTitle: subTitle ?? this.subTitle,
        description: description ?? this.description,
        iconImage: iconImage ?? this.iconImage,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        pivot: pivot ?? this.pivot,
      );

  factory DiceTable.fromJson(Map<String, dynamic> json) => DiceTable(
    id: json["id"],
    title: json["title"],
    subTitle: json["sub_title"],
    description: json["description"],
    iconImage: json["icon_image"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    pivot: json["pivot"] == null ? null : Pivot.fromJson(json["pivot"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "sub_title": subTitle,
    "description": description,
    "icon_image": iconImage,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "pivot": pivot?.toJson(),
  };
}

class Pivot {
  final int? cafeId;
  final int? diceTableId;
  final String? moreInfo;
  final String? availableDays;
  final String? createdAt;
  final String? updatedAt;

  Pivot({
    this.cafeId,
    this.diceTableId,
    this.moreInfo,
    this.availableDays,
    this.createdAt,
    this.updatedAt,
  });

  Pivot copyWith({
    int? cafeId,
    int? diceTableId,
    String? moreInfo,
    String? availableDays,
    String? createdAt,
    String? updatedAt,
  }) =>
      Pivot(
        cafeId: cafeId ?? this.cafeId,
        diceTableId: diceTableId ?? this.diceTableId,
        moreInfo: moreInfo ?? this.moreInfo,
        availableDays: availableDays ?? this.availableDays,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
    cafeId: json["cafe_id"],
    diceTableId: json["dice_table_id"],
    moreInfo: json["more_info"],
    availableDays: json["available_days"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "cafe_id": cafeId,
    "dice_table_id": diceTableId,
    "more_info": moreInfo,
    "available_days": availableDays,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Specialday {
  final int? id;
  final int? cafeId;
  final DateTime? date;
  final int? isOpen;
  final String? openTime;
  final String? closeTime;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  Specialday({
    this.id,
    this.cafeId,
    this.date,
    this.isOpen,
    this.openTime,
    this.closeTime,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  Specialday copyWith({
    int? id,
    int? cafeId,
    DateTime? date,
    int? isOpen,
    String? openTime,
    String? closeTime,
    String? note,
    String? createdAt,
    String? updatedAt,
  }) =>
      Specialday(
        id: id ?? this.id,
        cafeId: cafeId ?? this.cafeId,
        date: date ?? this.date,
        isOpen: isOpen ?? this.isOpen,
        openTime: openTime ?? this.openTime,
        closeTime: closeTime ?? this.closeTime,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory Specialday.fromJson(Map<String, dynamic> json) => Specialday(
    id: json["id"],
    cafeId: json["cafe_id"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    isOpen: json["is_open"],
    openTime: json["open_time"],
    closeTime: json["close_time"],
    note: json["note"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "cafe_id": cafeId,
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "is_open": isOpen,
    "open_time": openTime,
    "close_time": closeTime,
    "note": note,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class SubscriptionElement {
  final int? id;
  final int? cafeId;
  final int? subscriptionPlansId;
  final DateTime? registeredOn;
  final DateTime? expiryAt;
  final int? autoRenew;
  final int? status;
  final String? createdAt;
  final String? updatedAt;
  final dynamic deletedAt;
  final SubscriptionSubscription? subscription;

  SubscriptionElement({
    this.id,
    this.cafeId,
    this.subscriptionPlansId,
    this.registeredOn,
    this.expiryAt,
    this.autoRenew,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.subscription,
  });

  SubscriptionElement copyWith({
    int? id,
    int? cafeId,
    int? subscriptionPlansId,
    DateTime? registeredOn,
    DateTime? expiryAt,
    int? autoRenew,
    int? status,
    String? createdAt,
    String? updatedAt,
    dynamic deletedAt,
    SubscriptionSubscription? subscription,
  }) =>
      SubscriptionElement(
        id: id ?? this.id,
        cafeId: cafeId ?? this.cafeId,
        subscriptionPlansId: subscriptionPlansId ?? this.subscriptionPlansId,
        registeredOn: registeredOn ?? this.registeredOn,
        expiryAt: expiryAt ?? this.expiryAt,
        autoRenew: autoRenew ?? this.autoRenew,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        subscription: subscription ?? this.subscription,
      );

  factory SubscriptionElement.fromJson(Map<String, dynamic> json) => SubscriptionElement(
    id: json["id"],
    cafeId: json["cafe_id"],
    subscriptionPlansId: json["subscription_plans_id"],
    registeredOn: json["registered_on"] == null ? null : DateTime.parse(json["registered_on"]),
    expiryAt: json["expiry_at"] == null ? null : DateTime.parse(json["expiry_at"]),
    autoRenew: json["auto_renew"],
    status: json["status"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    subscription: json["subscription"] == null ? null : SubscriptionSubscription.fromJson(json["subscription"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "cafe_id": cafeId,
    "subscription_plans_id": subscriptionPlansId,
    "registered_on": "${registeredOn!.year.toString().padLeft(4, '0')}-${registeredOn!.month.toString().padLeft(2, '0')}-${registeredOn!.day.toString().padLeft(2, '0')}",
    "expiry_at": "${expiryAt!.year.toString().padLeft(4, '0')}-${expiryAt!.month.toString().padLeft(2, '0')}-${expiryAt!.day.toString().padLeft(2, '0')}",
    "auto_renew": autoRenew,
    "status": status,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "subscription": subscription?.toJson(),
  };
}

class SubscriptionSubscription {
  final int? id;
  final int? subscriptionTypeId;
  final int? paymentId;
  final String? createdAt;
  final String? updatedAt;
  final dynamic deletedAt;
  final SubscriptionType? subscriptionType;

  SubscriptionSubscription({
    this.id,
    this.subscriptionTypeId,
    this.paymentId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.subscriptionType,
  });

  SubscriptionSubscription copyWith({
    int? id,
    int? subscriptionTypeId,
    int? paymentId,
    String? createdAt,
    String? updatedAt,
    dynamic deletedAt,
    SubscriptionType? subscriptionType,
  }) =>
      SubscriptionSubscription(
        id: id ?? this.id,
        subscriptionTypeId: subscriptionTypeId ?? this.subscriptionTypeId,
        paymentId: paymentId ?? this.paymentId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        subscriptionType: subscriptionType ?? this.subscriptionType,
      );

  factory SubscriptionSubscription.fromJson(Map<String, dynamic> json) => SubscriptionSubscription(
    id: json["id"],
    subscriptionTypeId: json["subscription_type_id"],
    paymentId: json["payment_id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    subscriptionType: json["subscription_type"] == null ? null : SubscriptionType.fromJson(json["subscription_type"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "subscription_type_id": subscriptionTypeId,
    "payment_id": paymentId,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "subscription_type": subscriptionType?.toJson(),
  };
}

class SubscriptionType {
  final int? id;
  final String? title;
  final String? amount;
  final String? type;
  final int? period;
  final int? isTrial;
  final int? trialDuration;
  final String? trialType;
  final String? createdAt;
  final String? updatedAt;

  SubscriptionType({
    this.id,
    this.title,
    this.amount,
    this.type,
    this.period,
    this.isTrial,
    this.trialDuration,
    this.trialType,
    this.createdAt,
    this.updatedAt,
  });

  SubscriptionType copyWith({
    int? id,
    String? title,
    String? amount,
    String? type,
    int? period,
    int? isTrial,
    int? trialDuration,
    String? trialType,
    String? createdAt,
    String? updatedAt,
  }) =>
      SubscriptionType(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        period: period ?? this.period,
        isTrial: isTrial ?? this.isTrial,
        trialDuration: trialDuration ?? this.trialDuration,
        trialType: trialType ?? this.trialType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory SubscriptionType.fromJson(Map<String, dynamic> json) => SubscriptionType(
    id: json["id"],
    title: json["title"],
    amount: json["amount"],
    type: json["type"],
    period: json["period"],
    isTrial: json["is_trial"],
    trialDuration: json["trial_duration"],
    trialType: json["trial_type"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "amount": amount,
    "type": type,
    "period": period,
    "is_trial": isTrial,
    "trial_duration": trialDuration,
    "trial_type": trialType,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Workingday {
  final int? id;
  final int? cafeId;
  final String? day;
  final int? isOpen;
  final String? openTime;
  final String? closeTime;

  Workingday({
    this.id,
    this.cafeId,
    this.day,
    this.isOpen,
    this.openTime,
    this.closeTime,
  });

  Workingday copyWith({
    int? id,
    int? cafeId,
    String? day,
    int? isOpen,
    String? openTime,
    String? closeTime,
  }) =>
      Workingday(
        id: id ?? this.id,
        cafeId: cafeId ?? this.cafeId,
        day: day ?? this.day,
        isOpen: isOpen ?? this.isOpen,
        openTime: openTime ?? this.openTime,
        closeTime: closeTime ?? this.closeTime,
      );

  factory Workingday.fromJson(Map<String, dynamic> json) => Workingday(
    id: json["id"],
    cafeId: json["cafe_id"],
    day: json["day"],
    isOpen: json["is_open"],
    openTime: json["open_time"],
    closeTime: json["close_time"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "cafe_id": cafeId,
    "day": day,
    "is_open": isOpen,
    "open_time": openTime,
    "close_time": closeTime,
  };
}
