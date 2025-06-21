class AppleSignUpRequest {
  final String? name;
  final String? venueDescription;
  final String? email;
  final String? password;
  final String? passwordConfirmation;
  final String? phone;
  final int? loginType;
  final String? country;
  final String? region;
  final String? address;
  final String? postcode;
  final List<String>? accommodations;
  final Map<String, Map<String, dynamic>>? workingDays;
  final String? blob;
  final String? fcmToken;
  final String? apple_id;

  AppleSignUpRequest({
    this.name,
    this.venueDescription,
    this.email,
    this.password,
    this.passwordConfirmation,
    this.phone,
    this.loginType,
    this.country,
    this.region,
    this.address,
    this.postcode,
    this.accommodations,
    this.workingDays,
    this.blob,
    this.fcmToken,
    this.apple_id,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) {
      json['name'] = name;
    }
    if (venueDescription != null) {
      json['venue_description'] = venueDescription;
    }
    if (email != null) {
      json['email'] = email;
    }
    if (password != null) {
      json['password'] = password;
    }
    if (passwordConfirmation != null) {
      json['password_confirmation'] = passwordConfirmation;
    }
    if (phone != null) {
      json['phone'] = phone;
    }
    if (loginType != null) {
      json['login_type'] = loginType;
    }
    if (country != null) {
      json['country'] = country;
    }
    if (region != null) {
      json['region'] = region;
    }
    if (address != null) {
      json['address'] = address;
    }
    if (postcode != null) {
      json['postcode'] = postcode;
    }
    if (accommodations != null) {
      json['accommodations'] = accommodations;
    }
    if (workingDays != null) {
      json['working_days'] = workingDays;
    }
    if (blob != null) {
      json['blob'] = blob;
    }
    if (fcmToken != null) {
      json['fcm_token'] = fcmToken;
    }
     if (apple_id != null) {
      json['apple_id'] = apple_id;
    }

    return json;
  }
}

class WorkingDay {
  final bool? isOpen;
  final String? open;
  final String? close;

  WorkingDay({this.isOpen, this.open, this.close});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    if (isOpen != null) {
      map['is_open'] = isOpen;
      if (isOpen == true) {
        // only add open/close if isOpen is true
        map['open'] = open;
        map['close'] = close;
      }
    }

    return map;
  }
}
