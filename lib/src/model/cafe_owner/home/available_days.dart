/*
class AvailableDay {
  final int? id;
  final String? day;
  final String? openTime;
  final String? closeTime;
  final bool? isOpen;

  AvailableDay({
    this.id,
    this.day,
    this.openTime,
    this.closeTime,
    this.isOpen,
  });

  factory AvailableDay.fromJson(Map<String, dynamic> json) => AvailableDay(
    id: json["id"],
    day: json["day"],
    openTime: json["open"],
    closeTime: json["close"],
    isOpen: json["is_open"],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "day": day,
      "open": openTime,
      "close": closeTime,
      "is_open": isOpen,
    };

    if (id != null) {
      data["id"] = id;
    }

    return data;
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AvailableDay &&
        other.day == day &&
        other.openTime == openTime &&
        other.closeTime == closeTime;
  }

  @override
  int get hashCode => day.hashCode ^ openTime.hashCode ^ closeTime.hashCode;
}
*/

/*class AvailableDay {
  final int? id;
  final String? day;
  final bool? isOpen;
  final String? openTime; // Legacy - still used in old UI
  final String? closeTime; // Legacy
  final List<Timing>? timings; // ✅ New field for new API

  AvailableDay({
    this.id,
    this.day,
    this.isOpen,
    this.openTime,
    this.closeTime,
    this.timings,
  });

  factory AvailableDay.fromJson(Map<String, dynamic> json) {
    // Handle both old and new API structures
    if (json["timings"] != null) {
      return AvailableDay(
        id: json["id"],
        day: json["day"],
        isOpen: json["is_open"] ?? true,
        timings: List<Timing>.from(
          json["timings"].map((x) => Timing.fromJson(x)),
        ),
      );
    } else {
      // Old structure fallback
      return AvailableDay(
        id: json["id"],
        day: json["day"],
        isOpen: json["is_open"],
        openTime: json["open"],
        closeTime: json["close"],
        timings: [
          Timing(open: json["open"], close: json["close"]),
        ],
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "id": id,
      "day": day,
      "is_open": isOpen,
    };

    if (timings != null && timings!.isNotEmpty) {
      data["timings"] = List<dynamic>.from(timings!.map((x) => x.toJson()));
    } else {
      // Backward support for old format
      data["open"] = openTime;
      data["close"] = closeTime;
    }

    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AvailableDay &&
        other.day == day &&
        other.openTime == openTime &&
        other.closeTime == closeTime;
  }

  @override
  int get hashCode => day.hashCode ^ openTime.hashCode ^ closeTime.hashCode;
}

class Timing {
  final String? open;
  final String? close;

  Timing({this.open, this.close});

  factory Timing.fromJson(Map<String, dynamic> json) => Timing(
        open: json["open"],
        close: json["close"],
      );

  Map<String, dynamic> toJson() => {
        "open": open,
        "close": close,
      };
}
*/

class AvailableDay {
  final int? id;
  final String? day;
  final bool? isOpen;
  final List<Timing>? timings;

  AvailableDay({
    this.id,
    this.day,
    this.isOpen,
    this.timings,
  });

  factory AvailableDay.fromJson(Map<String, dynamic> json) {
    return AvailableDay(
      id: json['id'],
      day: json['day'],
      isOpen: true,
      timings: (json['timings'] as List?)
          ?.map((t) => Timing.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'is_open': isOpen ?? true,
      'timings': timings?.map((t) => t.toJson()).toList(),
    };
  }
}

class Timing {
  final String open;
  final String close;

  Timing({required this.open, required this.close});

  factory Timing.fromJson(Map<String, dynamic> json) {
    return Timing(
      open: json['open'],
      close: json['close'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'open': open, 'close': close};
  }
}
