

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
      isOpen: json['is_open'] as bool?,
      timings: (json['timings'] as List?)
          ?.map((t) => Timing.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'is_open': isOpen, 
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
