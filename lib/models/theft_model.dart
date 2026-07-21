class TheftRecord {
  final String id;
  final String stationId;
  final String stationName;
  final String location;
  final double theftProbability; // 0–100
  final double suspectedLoss; // kWh
  final String investigationStatus; // 'Open', 'Investigating', 'Resolved', 'Cleared'
  final String detectionMethod;
  final DateTime detectedAt;
  final String notes;

  const TheftRecord({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.location,
    required this.theftProbability,
    required this.suspectedLoss,
    required this.investigationStatus,
    required this.detectionMethod,
    required this.detectedAt,
    required this.notes,
  });

  String get riskLevel {
    if (theftProbability >= 75) return 'Critical';
    if (theftProbability >= 45) return 'Warning';
    return 'Low';
  }

  factory TheftRecord.fromMock(Map<String, dynamic> data) {
    return TheftRecord(
      id: data['id'] as String,
      stationId: data['stationId'] as String,
      stationName: data['stationName'] as String,
      location: data['location'] as String,
      theftProbability: (data['theftProbability'] as num).toDouble(),
      suspectedLoss: (data['suspectedLoss'] as num).toDouble(),
      investigationStatus: data['investigationStatus'] as String,
      detectionMethod: data['detectionMethod'] as String,
      detectedAt: DateTime.parse(data['detectedAt'] as String),
      notes: data['notes'] as String,
    );
  }
}
