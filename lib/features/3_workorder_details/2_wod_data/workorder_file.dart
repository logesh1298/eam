// To parse this JSON data, do
//
//     final assetFile = assetFileFromJson(jsonString);

import 'dart:convert';

import 'package:eam/features/2_workorder/2_wo_data/workorders.dart';

WorkOrderFile workorderFileFromJson(String str) => WorkOrderFile.fromJson(json.decode(str));

String workorderFileToJson(WorkOrderFile data) => json.encode(data.toJson());

class WorkOrderFile {
  final String? workOrderId;
  final String? documentName;
  final String? documentcategory;
  final String? documenttype;
  final String? id;
  final bool? isActive;
  final bool? isDeleted;
  final DateTime? createdDate;

  WorkOrderFile({
    this.workOrderId,
    this.documentName,
    this.documentcategory,
    this.documenttype,
    this.id,
    this.isActive,
    this.isDeleted,
    this.createdDate,
  });

  factory WorkOrderFile.fromJson(Map<String, dynamic> json) => WorkOrderFile(
    workOrderId: json["workOrderId"],
    documentName: json["documentName"],
    documentcategory: json["documentcategory"],
    documenttype: json["documenttype"],
    id: json["id"],
    isActive: json["isActive"],
    isDeleted: json["isDeleted"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
  );

  Map<String, dynamic> toJson() => {
    "workOrderId": workOrderId,
    "documentName": documentName,
    "documentcategory": documentcategory,
    "documenttype": documenttype,
    "id": id,
    "isActive": isActive,
    "isDeleted": isDeleted,
    "createdDate": createdDate?.toIso8601String(),
  };
}
