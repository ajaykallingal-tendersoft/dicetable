class NotificationItems {
  bool status;
  String message;
  bool notificationStatus;
  Data data;

  NotificationItems({
    required this.status,
    required this.message,
    required this.notificationStatus,
    required this.data,
  });

  factory NotificationItems.fromJson(Map<String, dynamic> json) {
    return NotificationItems(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      notificationStatus: json['notification_status'] ?? false,
      data: Data.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'notification_status': notificationStatus,
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

class NotificationReadRequest {
  final String notificationId;

  NotificationReadRequest({required this.notificationId});

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
    };
  }
}

class NotificationReadResponse {
  final bool status;
  final String? message;

  NotificationReadResponse({
    required this.status,
    this.message,
  });

  factory NotificationReadResponse.fromJson(Map<String, dynamic> json) {
    return NotificationReadResponse(
      status: json['status'] ?? false,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (message != null) 'message': message,
    };
  }
}

class NotificationStatusRequest {
  final String fcmToken;
  final int notificationStatus;

  NotificationStatusRequest({
    required this.fcmToken,
    required this.notificationStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'fcm_token': fcmToken,
      'notification_status': notificationStatus,
    };
  }
}

class NotificationStatusResponse {
  final bool status;
  final String? message;
  final int? notificationStatus;

  NotificationStatusResponse({
    required this.status,
    this.message,
    this.notificationStatus,
  });

  factory NotificationStatusResponse.fromJson(Map<String, dynamic> json) {
    return NotificationStatusResponse(
      status: json['status'] ?? false,
      message: json['message'],
      notificationStatus: json['notification_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (message != null) 'message': message,
      if (notificationStatus != null) 'notification_status': notificationStatus,
    };
  }
}