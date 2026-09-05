import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:latlong2/latlong.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/photo_storage_service.dart';

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
  final String
      concern; // e.g. "Pullout", "No Connection", "High Loss", "Relocation"
  final String?
      priorityLevel; // e.g. "Urgent", "High", "Normal", "System Generated"
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

  final bool isSynced;
  final DateTime? updatedAt;

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
    this.isSynced = true,
    this.updatedAt,
  });

  ServiceOrderDto copyWith({
    int? id,
    String? accountNumber,
    String? fullName,
    String? contactNumber,
    String? emailAddress,
    String? address,
    String? barangay,
    String? city,
    String? provider,
    String? plan,
    String? username,
    String? connectionType,
    String? routerModemSN,
    String? lcp,
    String? nap,
    String? port,
    String? vlan,
    String? supportStatus,
    String? concern,
    String? priorityLevel,
    String? visitStatus,
    String? visitBy,
    String? visitRemarks,
    String? assignedEmail,
    DateTime? createdDate,
    DateTime? dateInstalled,
    String? newRouterModemSN,
    String? newLCP,
    String? newNAP,
    String? newPORT,
    String? newVLAN,
    String? routerModel,
    String? pulloutRouterModel,
    String? pulloutRouterModelSN,
    String? pulloutRemarks,
    Map<String, int>? materialsUsed,
    String? clientSignature,
    String? image1,
    String? image2,
    String? image3,
    String? houseFrontPicture,
    String? addressCoordinates,
    double? serviceCharge,
    String? rawJson,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return ServiceOrderDto(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      fullName: fullName ?? this.fullName,
      contactNumber: contactNumber ?? this.contactNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      address: address ?? this.address,
      barangay: barangay ?? this.barangay,
      city: city ?? this.city,
      provider: provider ?? this.provider,
      plan: plan ?? this.plan,
      username: username ?? this.username,
      connectionType: connectionType ?? this.connectionType,
      routerModemSN: routerModemSN ?? this.routerModemSN,
      lcp: lcp ?? this.lcp,
      nap: nap ?? this.nap,
      port: port ?? this.port,
      vlan: vlan ?? this.vlan,
      supportStatus: supportStatus ?? this.supportStatus,
      concern: concern ?? this.concern,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      visitStatus: visitStatus ?? this.visitStatus,
      visitBy: visitBy ?? this.visitBy,
      visitRemarks: visitRemarks ?? this.visitRemarks,
      assignedEmail: assignedEmail ?? this.assignedEmail,
      createdDate: createdDate ?? this.createdDate,
      dateInstalled: dateInstalled ?? this.dateInstalled,
      newRouterModemSN: newRouterModemSN ?? this.newRouterModemSN,
      newLCP: newLCP ?? this.newLCP,
      newNAP: newNAP ?? this.newNAP,
      newPORT: newPORT ?? this.newPORT,
      newVLAN: newVLAN ?? this.newVLAN,
      routerModel: routerModel ?? this.routerModel,
      pulloutRouterModel: pulloutRouterModel ?? this.pulloutRouterModel,
      pulloutRouterModelSN: pulloutRouterModelSN ?? this.pulloutRouterModelSN,
      pulloutRemarks: pulloutRemarks ?? this.pulloutRemarks,
      materialsUsed: materialsUsed ?? this.materialsUsed,
      clientSignature: clientSignature ?? this.clientSignature,
      image1: image1 ?? this.image1,
      image2: image2 ?? this.image2,
      image3: image3 ?? this.image3,
      houseFrontPicture: houseFrontPicture ?? this.houseFrontPicture,
      addressCoordinates: addressCoordinates ?? this.addressCoordinates,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      rawJson: rawJson ?? this.rawJson,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ServiceOrderDto.fromDrift(ServiceOrder row) {
    Map<String, int> materials = const {};
    if (row.materialsUsedJson != null &&
        row.materialsUsedJson!.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(row.materialsUsedJson!);
        if (decoded is Map) {
          materials =
              decoded.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
        }
      } catch (_) {}
    }
    return ServiceOrderDto(
      id: row.id,
      accountNumber: row.accountNumber,
      fullName: row.fullName,
      contactNumber: row.contactNumber ?? '',
      emailAddress: row.emailAddress ?? '',
      address: row.address,
      barangay: row.barangay,
      city: row.city,
      provider: row.provider,
      plan: row.plan,
      username: row.username,
      connectionType: row.connectionType,
      routerModemSN: row.routerModemSN,
      lcp: row.lcp,
      nap: row.nap,
      port: row.port,
      vlan: row.vlan,
      supportStatus: row.supportStatus,
      concern: row.concern,
      priorityLevel: row.priorityLevel,
      visitStatus: row.visitStatus,
      visitBy: row.visitBy,
      visitRemarks: row.visitRemarks,
      assignedEmail: row.assignedEmail,
      createdDate: row.createdDate,
      dateInstalled: row.dateInstalled,
      newRouterModemSN: row.newRouterModemSN,
      newLCP: row.newLCP,
      newNAP: row.newNAP,
      newPORT: row.newPORT,
      newVLAN: row.newVLAN,
      routerModel: row.routerModel,
      pulloutRouterModel: row.pulloutRouterModel,
      pulloutRouterModelSN: row.pulloutRouterModelSN,
      pulloutRemarks: row.pulloutRemarks,
      materialsUsed: materials,
      clientSignature: row.clientSignature,
      image1: row.image1,
      image2: row.image2,
      image3: row.image3,
      houseFrontPicture: row.houseFrontPicture,
      addressCoordinates: row.addressCoordinates,
      serviceCharge: row.serviceCharge,
      rawJson: row.rawJson,
      isSynced: row.isSynced,
      updatedAt: row.updatedAt,
    );
  }

  ServiceOrdersCompanion toCompanion({bool synced = true}) {
    return ServiceOrdersCompanion(
      id: Value(id),
      accountNumber: Value(accountNumber),
      fullName: Value(fullName),
      contactNumber: Value(contactNumber),
      emailAddress: Value(emailAddress),
      address: Value(address),
      barangay: Value(barangay),
      city: Value(city),
      provider: Value(provider),
      plan: Value(plan),
      username: Value(username),
      connectionType: Value(connectionType),
      routerModemSN: Value(routerModemSN),
      lcp: Value(lcp),
      nap: Value(nap),
      port: Value(port),
      vlan: Value(vlan),
      supportStatus: Value(supportStatus),
      concern: Value(concern),
      priorityLevel: Value(priorityLevel),
      visitStatus: Value(visitStatus),
      visitBy: Value(visitBy),
      visitRemarks: Value(visitRemarks),
      assignedEmail: Value(assignedEmail),
      createdDate: Value(createdDate),
      dateInstalled: Value(dateInstalled),
      newRouterModemSN: Value(newRouterModemSN),
      newLCP: Value(newLCP),
      newNAP: Value(newNAP),
      newPORT: Value(newPORT),
      newVLAN: Value(newVLAN),
      routerModel: Value(routerModel),
      pulloutRouterModel: Value(pulloutRouterModel),
      pulloutRouterModelSN: Value(pulloutRouterModelSN),
      pulloutRemarks: Value(pulloutRemarks),
      materialsUsedJson:
          Value(materialsUsed.isNotEmpty ? jsonEncode(materialsUsed) : null),
      clientSignature: Value(clientSignature),
      image1: Value(image1),
      image2: Value(image2),
      image3: Value(image3),
      houseFrontPicture: Value(houseFrontPicture),
      addressCoordinates: Value(addressCoordinates),
      serviceCharge: Value(serviceCharge),
      rawJson: Value(rawJson),
      isSynced: Value(synced),
      updatedAt: Value(updatedAt ?? DateTime.now()),
    );
  }

  /// Converts fields to API JSON map, resolving local photo file paths
  /// back into Base64 data URLs as required by the backend API.
  Future<Map<String, dynamic>> toApiJsonAsync() async {
    final base = toJson();
    final photoStorage = PhotoStorageService.instance;
    if (clientSignature != null) {
      base['clientSignature'] =
          await photoStorage.resolveToDataUrl(clientSignature);
    }
    if (image1 != null) {
      base['image1'] = await photoStorage.resolveToDataUrl(image1);
    }
    if (image2 != null) {
      base['image2'] = await photoStorage.resolveToDataUrl(image2);
    }
    if (image3 != null) {
      base['image3'] = await photoStorage.resolveToDataUrl(image3);
    }
    if (houseFrontPicture != null) {
      base['houseFrontPicture'] =
          await photoStorage.resolveToDataUrl(houseFrontPicture);
    }
    return base;
  }

  /// Parse GPS coordinates from addressCoordinates string (e.g. "14.4705, 121.2150")
  LatLng? get latLng {
    if (addressCoordinates != null && addressCoordinates!.trim().isNotEmpty) {
      final parts = addressCoordinates!
          .replaceAll(RegExp(r'[^\d.,\s-]'), '')
          .split(RegExp(r'[,;\s]+'));
      if (parts.length >= 2) {
        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);
        if (lat != null &&
            lng != null &&
            lat.abs() <= 90 &&
            lng.abs() <= 180 &&
            !(lat == 0 && lng == 0)) {
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
        final parsedQty =
            qty is int ? qty : int.tryParse(qty?.toString() ?? '1') ?? 1;
        materials[name] = parsedQty;
      }
    }

    checkSlot('itemName', 'itemQuantity');
    for (int i = 1; i <= 10; i++) {
      checkSlot('itemName$i', 'itemQuantity$i');
    }

    return ServiceOrderDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
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
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'].toString())
          : null,
      dateInstalled: json['dateInstalled'] != null
          ? DateTime.tryParse(json['dateInstalled'].toString())
          : null,
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
