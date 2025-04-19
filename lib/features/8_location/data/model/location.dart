import 'dart:convert';

Location locationFromJson(String str) => Location.fromJson(json.decode(str));

String locationToJson(Location data) => json.encode(data.toJson());

class Location {
  final String? locationTypeName;
  final String? parentLocationName;
  final String? locationName;
  final String? code;
  final String? locationDesc;
  final String? locationTypeId;
  final String? id;
  final bool? isActive;
  final bool? isDeleted;
  final DateTime? createdDate;

  Location({
    this.locationTypeName,
    this.parentLocationName,
    this.locationName,
    this.code,
    this.locationDesc,
    this.locationTypeId,
    this.id,
    this.isActive,
    this.isDeleted,
    this.createdDate,
  });

  Location copyWith({
    String? locationTypeName,
    String? parentLocationName,
    String? locationName,
    String? code,
    String? locationDesc,
    String? locationTypeId,
    String? id,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdDate,
  }) =>
      Location(
        locationTypeName: locationTypeName ?? this.locationTypeName,
        parentLocationName: parentLocationName ?? this.parentLocationName,
        locationName: locationName ?? this.locationName,
        code: code ?? this.code,
        locationDesc: locationDesc ?? this.locationDesc,
        locationTypeId: locationTypeId ?? this.locationTypeId,
        id: id ?? this.id,
        isActive: isActive ?? this.isActive,
        isDeleted: isDeleted ?? this.isDeleted,
        createdDate: createdDate ?? this.createdDate,
      );

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        locationTypeName: json["locationTypeName"],
        parentLocationName: json["parentLocationName"],
        locationName: json["locationName"],
        code: json["code"],
        locationDesc: json["locationDesc"],
        locationTypeId: json["locationTypeId"],
        id: json["id"],
        isActive: json["isActive"],
        isDeleted: json["isDeleted"],
        createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
      );

  Map<String, dynamic> toJson() => {
        "locationTypeName": locationTypeName,
        "parentLocationName": parentLocationName,
        "locationName": locationName,
        "code": code,
        "locationDesc": locationDesc,
        "locationTypeId": locationTypeId,
        "id": id,
        "isActive": isActive,
        "isDeleted": isDeleted,
        "createdDate": createdDate?.toIso8601String(),
      };
}
