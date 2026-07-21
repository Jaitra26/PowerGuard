class EnergyReading {
  final DateTime timestamp;
  final double actualLoad;
  final double predictedLoad;
  final String theftRisk; // "Low" | "Medium" | "High"
  final String anomalyStatus; // "Normal" | "Warning" | "Critical"

  EnergyReading({
    required this.timestamp,
    required this.actualLoad,
    required this.predictedLoad,
    required this.theftRisk,
    required this.anomalyStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'actualLoad': actualLoad,
      'predictedLoad': predictedLoad,
      'theftRisk': theftRisk,
      'anomalyStatus': anomalyStatus,
    };
  }

  factory EnergyReading.fromJson(Map<String, dynamic> json) {
    return EnergyReading(
      timestamp: DateTime.parse(json['timestamp'] as String),
      actualLoad: (json['actualLoad'] as num).toDouble(),
      predictedLoad: (json['predictedLoad'] as num).toDouble(),
      theftRisk: json['theftRisk'] as String,
      anomalyStatus: json['anomalyStatus'] as String,
    );
  }
}
