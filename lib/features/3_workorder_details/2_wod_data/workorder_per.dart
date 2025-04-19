class TaskProgress {
  final String formattedSummary;
  final String percentage;

  TaskProgress({
    required this.formattedSummary,
    required this.percentage,
  });

  factory TaskProgress.fromJson(Map<String, dynamic> json) {
    return TaskProgress(
      formattedSummary: json['formattedSummary'] ?? '',
      percentage: json['percentage'] ?? '0%',
    );
  }
}