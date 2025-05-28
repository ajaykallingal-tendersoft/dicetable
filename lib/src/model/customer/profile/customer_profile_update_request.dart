class CustomerUpdateProfileRequest {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? country;
  final String? region;
  final double? latitude;
  final double? longitude;

  CustomerUpdateProfileRequest({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.country,
    this.region,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "country": country,
    "region": region,
    "latitude": latitude,
    "longitude": longitude,
  };
}