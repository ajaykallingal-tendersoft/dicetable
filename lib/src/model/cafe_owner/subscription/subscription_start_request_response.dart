class SubscriptionStartResponse {
  final bool status;
  final String? message;
  final Map<String, List<String>>? errors;

  SubscriptionStartResponse({
    required this.status,
    this.message,
    this.errors,
  });

  factory SubscriptionStartResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('success')) {
      return SubscriptionStartResponse(
        status: json['success'] ?? false,
        message: json['message'],
        errors: null,
      );
    } else {
      // Handle error response
      return SubscriptionStartResponse(
        status: json['status'] ?? false,
        message: null,
        errors: (json['errors'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      );
    }
  }

  bool get isError => errors != null;
}
