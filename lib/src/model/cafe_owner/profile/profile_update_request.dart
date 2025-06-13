class ProfileUpdateRequest {
  final String name;
  final String venueDescription;
  final String email;
  final String? password; // Optional
  final String phone;
  final String address;
  final String postcode;
  final List<String> accommodations;
  final List<WorkingDay> workingDays;
  final String? blob;
  final String? originalName; // Optional

  ProfileUpdateRequest({
    required this.name,
    required this.venueDescription,
    required this.email,
    this.password,
    required this.phone,
    required this.address,
    required this.postcode,
    required this.accommodations,
    required this.workingDays,
    this.blob,
    this.originalName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'venue_description': venueDescription,
      'email': email,
      'phone': phone,
      'address': address,
      'postcode': postcode,
      'accommodations': accommodations,
      'working_days': workingDays.map((e) => e.toJson()).toList(),
      // 'blob': blob,
    };

    // Conditionally add password only if not null and not empty
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }

    // Conditionally add originalName only if not null and not empty
    if (originalName != null && originalName!.isNotEmpty) {
      data['original_name'] = originalName;
    }
    if (blob != null && blob!.isNotEmpty) {
      data['blob'] = blob;
    }

    return data;
  }
}

class WorkingDay {
  final int? id;
  final String day;
  final bool isOpen;
  final String open;
  final String close;

  WorkingDay({
     this.id,
    required this.day,
    required this.isOpen,
    required this.open,
    required this.close,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'day': day,
      'is_open': isOpen,
      'open': open,
      'close': close,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}