/// Model representing a RADIUS PPPoE subscriber account.
class RadiusUserDto {
  final String id;
  final String
      name; // Account name / PPPoE username (e.g. "accountt0601261206")
  final String
      group; // Plan group or "Disconnected" (e.g. "SwitchLite", "SwitchLite-Disconnected")
  final bool disabled;
  final String password;
  final int sharedUsers;

  const RadiusUserDto({
    required this.id,
    required this.name,
    required this.group,
    this.disabled = false,
    this.password = '',
    this.sharedUsers = 0,
  });

  /// A RADIUS account reports its session state through its Group:
  /// The backend puts the word "Disconnected" in that column when the session is cut.
  bool get isConnected => !group.toLowerCase().contains('disconnected');

  String get statusLabel => isConnected ? 'Connected' : 'Disconnected';

  factory RadiusUserDto.fromJson(Map<String, dynamic> json) {
    return RadiusUserDto(
      id: json['id']?.toString().trim() ?? '',
      name: json['name']?.toString().trim() ??
          json['Name']?.toString().trim() ??
          '',
      group: json['group']?.toString().trim() ??
          json['Group']?.toString().trim() ??
          '',
      disabled: json['disabled'] is bool
          ? json['disabled'] as bool
          : (json['disabled']?.toString().toLowerCase() == 'true'),
      password: json['password']?.toString().trim() ?? '',
      sharedUsers: json['shared_users'] is int
          ? json['shared_users'] as int
          : int.tryParse(json['shared_users']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'group': group,
        'disabled': disabled,
        'password': password,
        'shared_users': sharedUsers,
      };
}
