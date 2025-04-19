class WorkOrderTaskPart {
  final String partName;
  final String taskNo;
  final String partId;
  final String code;
  final double quantity;
  final String workOrderTaskId;
  final String id;

  WorkOrderTaskPart({
    required this.partName,
    required this.taskNo,
    required this.partId,
    required this.code,
    required this.quantity,
    required this.workOrderTaskId,
    required this.id,
  });

  factory WorkOrderTaskPart.fromJson(Map<String, dynamic> json) {
    return WorkOrderTaskPart(
      partName: json['partName'] ?? '',
      taskNo: json['taskNo'] ?? '',
      partId: json['partId'] ?? '',
      quantity: json['quantity'] ?? 0,
      workOrderTaskId: json['workOrderTaskId'] ?? '',
      code: json['code']??'',
      id: json['id'] ?? '',
    );
  }
}