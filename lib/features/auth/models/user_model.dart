import 'dart:convert';

/// Technician user profile model.
class UserModel {
  final int id;
  final String username;
  final String fname;
  final String lname;
  final String email;
  final int accessLevelId;
  final bool active;
  final List<String> menus;
  final String contactNumber;
  final String address;

  UserModel({
    required this.id,
    required this.username,
    this.fname = '',
    this.lname = '',
    this.email = '',
    this.accessLevelId = 1,
    this.active = true,
    this.menus = const [],
    this.contactNumber = '',
    this.address = '',
  });

  String get fullName {
    final name = '$fname $lname'.trim();
    return name.isNotEmpty ? name : username;
  }

  /// Initials for the profile avatar. The API has no avatar field, so the
  /// technician's initials stand in for a photo.
  String get initials {
    final first = fname.trim();
    final last = lname.trim();
    if (first.isEmpty && last.isEmpty) {
      final u = username.trim();
      return u.isEmpty ? '?' : u[0].toUpperCase();
    }
    final buffer = StringBuffer();
    if (first.isNotEmpty) buffer.write(first[0].toUpperCase());
    if (last.isNotEmpty) buffer.write(last[0].toUpperCase());
    return buffer.toString();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username']?.toString() ??
          json['fname']?.toString() ??
          'Technician',
      fname: json['fname']?.toString() ?? json['firstName']?.toString() ?? '',
      lname: json['lname']?.toString() ?? json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ??
          json['userEmail']?.toString() ??
          json['applicantEmailAddress']?.toString() ??
          '',
      accessLevelId: json['accesslevel_id'] is int
          ? json['accesslevel_id']
          : json['accessLevelId'] is int
              ? json['accessLevelId']
              : int.tryParse(json['accesslevel_id']?.toString() ?? '1') ?? 1,
      active: json['active'] == null ||
          json['active'] == true ||
          json['active'].toString() == 'true',
      menus: json['menus'] is List
          ? (json['menus'] as List).map((e) => e.toString()).toList()
          : [],
      contactNumber: json['contactnumber']?.toString() ??
          json['contactNumber']?.toString() ??
          '',
      address: json['address']?.toString() ?? '',
    );
    // NOTE: `password` is deliberately not read. GET /api/Users/{id} returns it
    // in plaintext; it must never enter the model or the stored session.
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fname': fname,
      'lname': lname,
      'email': email,
      'accesslevel_id': accessLevelId,
      'active': active,
      'menus': menus,
      'contactnumber': contactNumber,
      'address': address,
    };
  }

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str) as Map<String, dynamic>);
}
