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

  UserModel({
    required this.id,
    required this.username,
    this.fname = '',
    this.lname = '',
    this.email = '',
    this.accessLevelId = 1,
    this.active = true,
    this.menus = const [],
  });

  String get fullName {
    final name = '$fname $lname'.trim();
    return name.isNotEmpty ? name : username;
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
    );
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
    };
  }

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str) as Map<String, dynamic>);
}
