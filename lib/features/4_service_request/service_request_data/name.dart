import 'dart:convert';

import 'package:eam/features/4_service_request/service_request_data/service_request.dart';


ServiceRequestName nameFromJson(String str) => ServiceRequestName.fromJson(json.decode(str));

String nameToJson(ServiceRequestName data) => json.encode(data.toJson());

class ServiceRequestName {
  final String? Name;
  final String? Description;
  final String? code;


  final String? id;
  final bool? isActive;
  final bool? isDeleted;
  final DateTime? createdDate;

  ServiceRequestName({
    this.Name,
    this.Description,

    this.code,
    this.id,
    this.isActive,
    this.isDeleted,
    this.createdDate,
  });

  ServiceRequestName copyWith({
    String? Name,
    String? Description,

    String? code,

    String? id,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdDate,
  }) =>
      ServiceRequestName(
        Name: Name ?? this.Name,
        Description: Description ?? this.Description,

        code: code ?? this.code,

        id: id ?? this.id,
        isActive: isActive ?? this.isActive,
        isDeleted: isDeleted ?? this.isDeleted,
        createdDate: createdDate ?? this.createdDate,
      );

  factory ServiceRequestName.fromJson(Map<String, dynamic> json) => ServiceRequestName(
    Name: json["name"],
    Description: json["description"],

    code: json["code"],

    id: json["id"],
    isActive: json["isActive"],
    isDeleted: json["isDeleted"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
  );

  Map<String, dynamic> toJson() => {
    "name": Name,
    "description": Description,
    "code": code,
    "id": id,
    "isActive": isActive,
    "isDeleted": isDeleted,
    "createdDate": createdDate?.toIso8601String(),
  };
}
