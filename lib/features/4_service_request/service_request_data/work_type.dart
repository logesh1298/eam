class WorkTypes {
  final String id;
  final String workTypeName;
  final String description;
  final String code;

  WorkTypes({
    required this.id,
    required this.workTypeName,
    required this.description,
    required this.code,
  });

  factory WorkTypes.fromJson(Map<String, dynamic> json) {
    return WorkTypes(
      id: json['id'] ?? '',
      workTypeName: json['workTypeName'] ?? '',
      description: json['description'] ?? '',
      code: json['code'] ?? '',
    );
  }
}