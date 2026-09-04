/// Model for ISP subscription broadband plans.
class PlanDto {
  final int id;
  final String name;
  final String description;
  final double amount;
  final int? discountId;

  const PlanDto({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    this.discountId,
  });

  factory PlanDto.fromJson(Map<String, dynamic> json) {
    return PlanDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      discountId: json['discountId'] is int
          ? json['discountId'] as int
          : int.tryParse(json['discountId']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'amount': amount,
        if (discountId != null) 'discountId': discountId,
      };

  String get formattedPrice => '₱${amount.toStringAsFixed(2)}';
}

/// Model for approved ISP ONT / Router hardware specifications.
class RouterDto {
  final int id;
  final String name; // e.g. "Huawei", "UT-KING", "ZTE"
  final String description; // e.g. "5v5", "UT-XP6486-S", "F670L"
  final String brand; // e.g. "DUAL BAND ONU MODEM"
  final String model;

  const RouterDto({
    required this.id,
    required this.name,
    required this.description,
    required this.brand,
    required this.model,
  });

  factory RouterDto.fromJson(Map<String, dynamic> json) {
    return RouterDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      brand: json['brand']?.toString().trim() ?? '',
      model: json['model']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'brand': brand,
        'model': model,
      };

  /// Full display name for UI pickers: e.g. "Huawei 5v5 (DUAL BAND ONU MODEM)"
  String get displayName {
    final parts = [name, description].where((s) => s.isNotEmpty).join(' ');
    if (brand.isNotEmpty) {
      return '$parts ($brand)';
    }
    return parts;
  }

  /// Compact specification: e.g. "Huawei 5v5"
  String get compactName =>
      [name, description].where((s) => s.isNotEmpty).join(' ');
}

/// Model for NAP items from `/api/Naps`.
class NapDto {
  final int id;
  final String name; // e.g. "NAP 001", "NAP 002", "test nap 1"
  final String description; // e.g. "NAP 001 Description"
  final int? createdByUserId;
  final DateTime? createdDate;

  const NapDto({
    required this.id,
    required this.name,
    this.description = '',
    this.createdByUserId,
    this.createdDate,
  });

  factory NapDto.fromJson(Map<String, dynamic> json) {
    return NapDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      createdByUserId: json['createdByUserId'] is int
          ? json['createdByUserId'] as int
          : int.tryParse(json['createdByUserId']?.toString() ?? ''),
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        if (createdByUserId != null) 'createdByUserId': createdByUserId,
        if (createdDate != null) 'createdDate': createdDate!.toIso8601String(),
      };
}

/// Model for Port items from `/api/Ports`.
class PortDto {
  final int id;
  final String name; // e.g. "PORT 001", "PORT 002"
  final String description; // e.g. "PORT 001 Description"
  final int? createdByUserId;
  final DateTime? createdDate;

  const PortDto({
    required this.id,
    required this.name,
    this.description = '',
    this.createdByUserId,
    this.createdDate,
  });

  factory PortDto.fromJson(Map<String, dynamic> json) {
    return PortDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      createdByUserId: json['createdByUserId'] is int
          ? json['createdByUserId'] as int
          : int.tryParse(json['createdByUserId']?.toString() ?? ''),
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        if (createdByUserId != null) 'createdByUserId': createdByUserId,
        if (createdDate != null) 'createdDate': createdDate!.toIso8601String(),
      };
}
