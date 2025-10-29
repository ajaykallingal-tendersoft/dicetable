class CountryResponse {
  final bool? status;
  final List<Country>? data;
  final String? message;

  CountryResponse({
    this.status,
    this.data,
    this.message,
  });

  factory CountryResponse.fromJson(Map<String, dynamic> json) {
    return CountryResponse(
      status: json['status'] as bool?,
      data: json['data'] != null
          ? (json['data'] as List)
          .map((item) => Country.fromJson(item))
          .toList()
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (status != null) {
      json['status'] = status;
    }
    if (data != null) {
      json['data'] = data!.map((item) => item.toJson()).toList();
    }
    if (message != null) {
      json['message'] = message;
    }
    return json;
  }
}

class Country {
  final int? id;
  final String? name;
  final String? code;

  Country({
    this.id,
    this.name,
    this.code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as int?,
      name: json['name'] as String?,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (id != null) {
      json['id'] = id;
    }
    if (name != null) {
      json['name'] = name;
    }
    if (code != null) {
      json['code'] = code;
    }
    return json;
  }
}
