class PredictionResult {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double solarIrradiance;
  final double currentLoad;
  final double predictedLoad;
  final double confidence;
  final DateTime timestamp;

  PredictionResult({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.solarIrradiance,
    required this.currentLoad,
    required this.predictedLoad,
    required this.confidence,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'solarIrradiance': solarIrradiance,
      'currentLoad': currentLoad,
      'predictedLoad': predictedLoad,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      solarIrradiance: (json['solarIrradiance'] as num).toDouble(),
      currentLoad: (json['currentLoad'] as num).toDouble(),
      predictedLoad: (json['predictedLoad'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
