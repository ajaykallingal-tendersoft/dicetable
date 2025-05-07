class CustomerProfileModel {
  final String firstName;
  final String email;
  final String password;
  final String phone;
  final String country;
  final String region;

  CustomerProfileModel({
    required this.firstName,
    required this.email,
    required this.password,
    required this.phone,
    required this.country,
    required this.region,
  });

  CustomerProfileModel copyWith({
    String? firstName,
    String? email,
    String? password,
    String? phone,
    String? country,
    String? region,
  }) {
    return CustomerProfileModel(
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      region: region ?? this.region,
    );
  }
}