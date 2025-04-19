import 'dart:convert';

import 'package:retrofit/http.dart';

Part partFromJson(String str) => Part.fromJson(json.decode(str));

String partToJson(Part data) => json.encode(data.toJson());

class Part {
  final String? partName;
  final String? stockRoomName;
  final String? binName;
  final String? rowName;
  final String? aisleName;
  final String? stockRoomCode;
  final String? binCode;
  final String? aisleCode;
  final String? rowCode;
  final int? totalQuantity;
  final String? partId;
  final String? stockRoomId;
  final int? quantityOnHandInBin;
  final int? quantityOnHandInAisle;
  final int? quantityOnHandInRow;
  final int? quantityOnHandInRoom;
  final double? safetyStockLevel;
  final int? economicReOrderQuantity;
  final double? standardPrice;
  final double? averagePrice;
  final double? lastReceiptPrice;
  final bool? isReOrder;
  final int? reOrderPoint;
  final int? maxQuantity;
  final String? stockcategory;
  final int? actualQuantityInBin;
  final int? actualQuantityInAisle;
  final int? actualQuantityInRoom;
  final int? actualQuantityInRow;
  final String? stockTakingId;
  final String? stockTakingNo;
  final String? id;
  final String? code;
  final bool? isActive;
  final bool? isDeleted;
  final DateTime? createdDate;
  Part({
    this.partName,
    this.stockRoomName,
    this.binName,
    this.rowName,
    this.aisleName,
    this.stockRoomCode,
    this.binCode,
    this.aisleCode,
    this.rowCode,
    this.totalQuantity,
    this.partId,
    this.stockRoomId,
    this.quantityOnHandInBin,
    this.quantityOnHandInAisle,
    this.quantityOnHandInRow,
    this.quantityOnHandInRoom,
    this.safetyStockLevel,
    this.economicReOrderQuantity,
    this.standardPrice,
    this.averagePrice,
    this.lastReceiptPrice,
    this.isReOrder,
    this.reOrderPoint,
    this.maxQuantity,
    this.stockcategory,
    this.actualQuantityInBin,
    this.actualQuantityInAisle,
    this.actualQuantityInRoom,
    this.actualQuantityInRow,
    this.stockTakingId,
    this.stockTakingNo,
    this.id,
    this.code,
    this.isActive,
    this.isDeleted,
    this.createdDate,
  });

  Part copyWith({
    String? partName,
    String? stockRoomName,
    String? binName,
    String? rowName,
    String? aisleName,
    String? stockRoomCode,
    String? binCode,
    String? aisleCode,
    String? rowCode,
    // int? totalQuantity,
    // String? partId,
    // String? stockRoomId,
    // int? quantityOnHandInBin,
    // int? quantityOnHandInAisle,
    // int? quantityOnHandInRow,
    // int? quantityOnHandInRoom,
    // double? safetyStockLevel,
    // int? economicReOrderQuantity,
    // double? standardPrice,
    // double? averagePrice,
    // double? lastReceiptPrice,
    // bool? isReOrder,
    // int? reOrderPoint,
    // int? maxQuantity,
    // String? stockcategory,
    // int? actualQuantityInBin,
    // int? actualQuantityInAisle,
    // int? actualQuantityInRoom,
    // int? actualQuantityInRow,
    // String? stockTakingId,
    // String? stockTakingNo,
    String? id,
    String? code,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdDate,


  }) =>
      Part(
        partName: partName ?? this.partName,
        stockRoomName:
        stockRoomName ?? this.stockRoomName,
        binName:
        binName ?? this.binName,
        rowName: rowName ?? this.rowName,
        aisleName: aisleName ?? this.aisleName,
        stockRoomCode: stockRoomCode ?? this.stockRoomCode,
        binCode: binCode ?? this.binCode,
        aisleCode: aisleCode ?? this.aisleCode,
        rowCode: rowCode ?? this.rowCode,
        // totalQuantity: totalQuantity ?? this.totalQuantity,
        // partId: partId ?? this.partId,
        // stockRoomId: stockRoomId ?? this.stockRoomId,
        // quantityOnHandInBin: quantityOnHandInBin ?? this.quantityOnHandInBin,
        // quantityOnHandInAisle: quantityOnHandInAisle ?? this.quantityOnHandInAisle,
        // quantityOnHandInRow: quantityOnHandInRow ?? this.quantityOnHandInRow,
        // quantityOnHandInRoom: quantityOnHandInRoom ?? this.quantityOnHandInRoom,
        // safetyStockLevel: safetyStockLevel ?? this.safetyStockLevel,
        // economicReOrderQuantity: economicReOrderQuantity ?? this.economicReOrderQuantity,
        // standardPrice: standardPrice ?? this.standardPrice,
        // averagePrice: averagePrice ?? this.averagePrice,
        // lastReceiptPrice: lastReceiptPrice ?? this.lastReceiptPrice,
        // isReOrder: isReOrder ?? this.isReOrder,
        // reOrderPoint: reOrderPoint ?? this.reOrderPoint,
        // maxQuantity: maxQuantity ?? this.maxQuantity,
        // stockcategory: stockcategory ?? this.stockcategory,
        // actualQuantityInBin: actualQuantityInBin ?? this.actualQuantityInBin,
        // actualQuantityInAisle: actualQuantityInAisle ?? this.actualQuantityInAisle,
        // actualQuantityInRoom: actualQuantityInRoom?? this.actualQuantityInRoom,
        // actualQuantityInRow: actualQuantityInRow?? this.actualQuantityInRow,
        // stockTakingId: stockTakingId?? this.stockTakingId,
        // stockTakingNo: stockTakingNo?? this.stockTakingNo,


        id: id ?? this.id,
        isActive: isActive ?? this.isActive,
        isDeleted: isDeleted ?? this.isDeleted,
        createdDate: createdDate ?? this.createdDate,
      );

  factory Part.fromJson(Map<String, dynamic> json) =>   Part(
    partName: json["partName"],
    stockRoomName: json["stockRoomName"],
    binName: json["binName"],
    rowName: json["rowName"],
    aisleName: json["aisleName"],
    stockRoomCode: json["stockRoomCode"],
    binCode: json["binCode"],
    aisleCode: json["aisleCode"],
    rowCode: json["rowCode"],
    // totalQuantity: json["totalQuantity"],
    // partId: json["partId"],
    // stockRoomId: json["stockRoomId"],
    // quantityOnHandInBin: json["quantityOnHandInBin"],
    // quantityOnHandInAisle: json["quantityOnHandInAisle"],
    // quantityOnHandInRow: json["quantityOnHandInRow"],
    // quantityOnHandInRoom: json["quantityOnHandInRoom"],
    // safetyStockLevel: (json["safetyStockLevel"] as num?)?.toDouble(),
    // economicReOrderQuantity: json["economicReOrderQuantity"],
    // standardPrice: json["standardPrice"].toDouble(),
    // averagePrice: json["averagePrice"].toDouble(),
    // lastReceiptPrice: json["lastReceiptPrice"].toDouble(),
    // isReOrder: json["isReOrder"],
    // reOrderPoint: json["reOrderPoint"],
    // maxQuantity: json["maxQuantity"],
    // stockcategory: json["stockcategory"],
    // actualQuantityInBin: json["actualQuantityInBin"],
    // actualQuantityInAisle: json["actualQuantityInAisle"],
    // actualQuantityInRoom: json["actualQuantityInRoom"],
    // actualQuantityInRow: json["actualQuantityInRow"],
    // stockTakingId: json["stockTakingId"],
    // stockTakingNo: json["stockTakingNo"],
    id: json["id"],
    code: json["code"],
    isActive: json["isActive"],
    isDeleted: json["isDeleted"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
  );

  Map<String, dynamic> toJson() => {
    "partName": partName,
    "stockRoomName": stockRoomName,
    "binName": binName,
    "rowName": rowName,
    "aisleName": aisleName,
    "stockRoomCode": stockRoomCode,
    "binCode": binCode,
    "aisleCode": aisleCode,
    "rowCode": rowCode,
    // "totalQuantity": totalQuantity,
    // "partId": partId,
    // "stockRoomId": stockRoomId,
    // "quantityOnHandInBin": quantityOnHandInBin,
    // "quantityOnHandInAisle": quantityOnHandInAisle,
    // "quantityOnHandInRow": quantityOnHandInRow,
    // "quantityOnHandInRoom": quantityOnHandInRoom,
    // "safetyStockLevel": safetyStockLevel,
    // "economicReOrderQuantity": economicReOrderQuantity,
    // "standardPrice": standardPrice,
    // "averagePrice": averagePrice,
    // "lastReceiptPrice": lastReceiptPrice,
    // "isReOrder": isReOrder,
    // "reOrderPoint": reOrderPoint,
    // "maxQuantity": maxQuantity,
    // "stockcategory": stockcategory,
    // "actualQuantityInBin": actualQuantityInBin,
    // "actualQuantityInAisle": actualQuantityInAisle,
    // "actualQuantityInRoom": actualQuantityInRoom,
    // "actualQuantityInRow": actualQuantityInRow,
    // "stockTakingId": stockTakingId,
    // "stockTakingNo": stockTakingNo,
    "id": id,
    "code": code,
    "isActive": isActive,
    "isDeleted": isDeleted,
    "createdDate": createdDate?.toIso8601String(),
  };
}
