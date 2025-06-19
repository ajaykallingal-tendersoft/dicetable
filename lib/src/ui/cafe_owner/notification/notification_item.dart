class NotificationItems {
  bool status;
  String message;
  Data data;

  NotificationItems({
    required this.status,
    required this.message,
    required this.data,
  });

  factory NotificationItems.fromJson(Map<String, dynamic> json) {
    return NotificationItems(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: Data.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class Data {
  List<All> all;
  List<All> unread;

  Data({
    required this.all,
    required this.unread,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      all: (json['all'] as List<dynamic>?)
          ?.map((item) => All.fromJson(item))
          .toList() ??
          [],
      unread: (json['unread'] as List<dynamic>?)
          ?.map((item) => All.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'all': all.map((e) => e.toJson()).toList(),
      'unread': unread.map((e) => e.toJson()).toList(),
    };
  }
}

class All {
  String id;
  String type;
  String title;
  String body;
  dynamic readAt;
  String createdAt;

  All({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.readAt,
    required this.createdAt,
  });

  factory All.fromJson(Map<String, dynamic> json) {
    return All(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      readAt: json['read_at'], // can be null
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'read_at': readAt,
      'created_at': createdAt,
    };
  }
}

