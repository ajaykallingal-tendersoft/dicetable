class AvailableDay {
  final int? id;
  final String? day;
  final String? openTime;
  final String? closeTime;

  AvailableDay({
    this.id,
    this.day,
    this.openTime,
    this.closeTime,
  });

  factory AvailableDay.fromJson(Map<String, dynamic> json) => AvailableDay(
    id: json["id"],
    day: json["day"],
    openTime: json["open_time"],
    closeTime: json["close_time"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "day": day,
    "open_time": openTime,
    "close_time": closeTime,
  };

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