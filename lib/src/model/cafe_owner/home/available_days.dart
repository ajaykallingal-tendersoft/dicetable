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