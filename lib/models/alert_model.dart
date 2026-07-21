class AlertModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String severity; // "Critical" | "Warning" | "Normal"
  final String status; // "Active" | "Resolved"
  final String location;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    required this.status,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity,
      'status': status,
      'location': location,
    };
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: json['severity'] as String,
      status: json['status'] as String,
      location: json['location'] as String,
    );
  }
}
