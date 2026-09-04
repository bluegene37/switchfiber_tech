import 'dart:convert';
import 'package:latlong2/latlong.dart';

/// Data Transfer Object representing a Field Repair / Trouble Ticket / Service Order.
class ServiceOrderDto {
  final int id;
  final String accountNumber;
  final String fullName;
  final String contactNumber;
  final String emailAddress;
  final String address;
  final String? barangay;
  final String? city;
  final String? provider;
  final String? plan;
  final String? username; // RADIUS PPPoE username
  final String? connectionType;
  final String? routerModemSN;
  final String? lcp;
  final String? nap;
  final String? port;
  final String? vlan;
  final String supportStatus;
  final String concern; // e.g. "Pullout", "No Connection", "High Loss", "Relocation"
  final String? priorityLevel; // e.g. "Urgent", "High", "Normal", "System Generated"
  final String? visitStatus; // e.g. "In Progress", "Done", "Pending"
  final String? visitBy;
  final String? visitRemarks;
  final String? assignedEmail;
  final DateTime? createdDate;
  final DateTime? dateInstalled;

  // Equipment Swaps & Pullouts
  final String? newRouterModemSN;
  final String? newLCP;
  final String? newNAP;
  final String? newPORT;
  final String? newVLAN;
  final String? routerModel;
  final String? pulloutRouterModel;
  final String? pulloutRouterModelSN;
  final String? pulloutRemarks;

  // Materials & Consumables (1 to 10)
  final Map<String, int> materialsUsed;

  // Proofs & Signatures
  final String? clientSignature;
  final String? image1;
  final String? image2;
  final String? image3;
  final String? houseFrontPicture;
  final String? addressCoordinates;
  final double serviceCharge;

  // Raw JSON
  final String? rawJson;

  const ServiceOrderDto({
    required this.id,
    required this.accountNumber,
    required this.fullName,
    required this.contactNumber,
    required this.emailAddress,
    required this.address,
    this.barangay,
    this.city,
    this.provider,
    this.plan,
    this.username,
    this.connectionType,
    this.routerModemSN,
    this.lcp,
    this.nap,
    this.port,
    this.vlan,
    this.supportStatus = 'Open',
    this.concern = 'Maintenance Visit',
    this.priorityLevel,
    this.visitStatus,
    this.visitBy,
    this.visitRemarks,
    this.assignedEmail,
    this.createdDate,
    this.dateInstalled,
    this.newRouterModemSN,
    this.newLCP,
    this.newNAP,
    this.newPORT,
    this.newVLAN,
    this.routerModel,
    this.pulloutRouterModel,
    this.pulloutRouterModelSN,
    this.pulloutRemarks,
    this.materialsUsed = const {},
    this.clientSignature,
    this.image1,
    this.image2,
    this.image3,
    this.houseFrontPicture,
    this.addressCoordinates,
    this.serviceCharge = 0.0,
    this.rawJson,
  });

  /// Parse GPS coordinates from addressCoordinates string (e.g. "14.4705, 121.2150")
  LatLng? get latLng {
    if (addressCoordinates != null && addressCoordinates!.trim().isNotEmpty) {
      final parts = addressCoordinates!
          .replaceAll(RegExp(r'[^\d.,\s-]'), '')
          .split(RegExp(r'[,;\s]+'));
      if (parts.length >= 2) {
        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);
        if (lat != null && lng != null && lat.abs() <= 90 && lng.abs() <= 180 && !(lat == 0 && lng == 0)) {
          return LatLng(lat, lng);
        }
      }
    }
    return null;
  }

  bool get isDone => (visitStatus ?? '').trim().toLowerCase() == 'done';
  bool get isUrgent => (priorityLevel ?? '').trim().toLowerCase() == 'urgent';

  bool isAssignedTo(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    final mine = email.trim().toLowerCase();
    final theirs = (assignedEmail ?? '').trim().toLowerCase();
    return mine == theirs;
  }

  factory ServiceOrderDto.fromJson(Map<String, dynamic> json) {
    // Extract materials from slots itemName / itemQuantity and itemName1..10
    final materials = <String, int>{};
    void checkSlot(String nameKey, String qtyKey) {
      final name = json[nameKey]?.toString().trim();
      final qty = json[qtyKey];
      if (name != null && name.isNotEmpty) {
        final parsedQty = qty is int ? qty : int.tryParse(qty?.toString() ?? '1') ?? 1;
        materials[name] = parsedQty;
      }
    }

    checkSlot('itemName', 'itemQuantity');
    for (int i = 1; i <= 10; i++) {
      checkSlot('itemName$i', 'itemQuantity$i');
    }

    return ServiceOrderDto(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      accountNumber: json['accountNumber']?.toString().trim() ?? '',
      fullName: json['fullName']?.toString().trim() ?? 'Subscriber',
      contactNumber: json['contactNumber']?.toString().trim() ?? '',
      emailAddress: json['emailAddress']?.toString().trim() ?? '',
      address: json['address']?.toString().trim() ?? 'No address provided',
      barangay: json['barangay']?.toString().trim(),
      city: json['city']?.toString().trim(),
      provider: json['provider']?.toString().trim(),
      plan: json['plan']?.toString().trim(),
      username: json['username']?.toString().trim(),
      connectionType: json['connectionType']?.toString().trim(),
      routerModemSN: json['routerModemSN']?.toString().trim(),
      lcp: json['lcp']?.toString().trim(),
      nap: json['nap']?.toString().trim(),
      port: json['port']?.toString().trim(),
      vlan: json['vlan']?.toString().trim(),
      supportStatus: json['supportStatus']?.toString().trim() ?? 'Open',
      concern: json['concern']?.toString().trim() ?? 'Service Call',
      priorityLevel: json['priorityLevel']?.toString().trim(),
      visitStatus: json['visitStatus']?.toString().trim(),
      visitBy: json['visitBy']?.toString().trim(),
      visitRemarks: json['visitRemarks']?.toString().trim(),
      assignedEmail: json['assignedEmail']?.toString().trim(),
      createdDate: json['createdDate'] != null ? DateTime.tryParse(json['createdDate'].toString()) : null,
      dateInstalled: json['dateInstalled'] != null ? DateTime.tryParse(json['dateInstalled'].toString()) : null,
      newRouterModemSN: json['newRouterModemSN']?.toString().trim(),
      newLCP: json['newLCP']?.toString().trim(),
      newNAP: json['newNAP']?.toString().trim(),
      newPORT: json['newPORT']?.toString().trim(),
      newVLAN: json['newVLAN']?.toString().trim(),
      routerModel: json['routerModel']?.toString().trim(),
      pulloutRouterModel: json['pulloutRouterModel']?.toString().trim(),
      pulloutRouterModelSN: json['pulloutRouterModelSN']?.toString().trim(),
      pulloutRemarks: json['pulloutRemarks']?.toString().trim(),
      materialsUsed: materials,
      clientSignature: json['clientSignature']?.toString(),
      image1: json['image1']?.toString(),
      image2: json['image2']?.toString(),
      image3: json['image3']?.toString(),
      houseFrontPicture: json['houseFrontPicture']?.toString(),
      addressCoordinates: json['addressCoordinates']?.toString().trim(),
      serviceCharge: json['serviceCharge'] is num
          ? (json['serviceCharge'] as num).toDouble()
          : double.tryParse(json['serviceCharge']?.toString() ?? '0') ?? 0.0,
      rawJson: jsonEncode(json),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'accountNumber': accountNumber,
      'fullName': fullName,
      'contactNumber': contactNumber,
      'emailAddress': emailAddress,
      'address': address,
      'barangay': barangay,
      'city': city,
      'provider': provider,
      'plan': plan,
      'username': username,
      'connectionType': connectionType,
      'routerModemSN': routerModemSN,
      'lcp': lcp,
      'nap': nap,
      'port': port,
      'vlan': vlan,
      'supportStatus': supportStatus,
      'concern': concern,
      'priorityLevel': priorityLevel,
      'visitStatus': visitStatus,
      'visitBy': visitBy,
      'visitRemarks': visitRemarks,
      'assignedEmail': assignedEmail,
      'newRouterModemSN': newRouterModemSN,
      'newLCP': newLCP,
      'newNAP': newNAP,
      'newPORT': newPORT,
      'newVLAN': newVLAN,
      'routerModel': routerModel,
      'pulloutRouterModel': pulloutRouterModel,
      'pulloutRouterModelSN': pulloutRouterModelSN,
      'pulloutRemarks': pulloutRemarks,
      'clientSignature': clientSignature,
      'image1': image1,
      'image2': image2,
      'image3': image3,
      'houseFrontPicture': houseFrontPicture,
      'addressCoordinates': addressCoordinates,
      'serviceCharge': serviceCharge,
    };

    // Serialize materials into itemName1..10 and itemQuantity1..10
    int index = 1;
    materialsUsed.forEach((name, qty) {
      if (index <= 10) {
        map['itemName$index'] = name;
        map['itemQuantity$index'] = qty;
        index++;
      }
    });

    return map;
  }
}
