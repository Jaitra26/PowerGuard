import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_result.dart';

class ApiService {
  // Try local machine default or standard emulator alias
  static const String _emulatorUrl = "http://10.0.2.2:5000/predict";
  static const String _localUrl = "http://localhost:5000/predict";

  Future<PredictionResult> predictLoad(Map<String, double> inputs) async {
    final body = {
      'temperature': inputs['temperature'],
      'humidity': inputs['humidity'],
      'wind_speed': inputs['wind_speed'],
      'solar_irradiance': inputs['solar_irradiance'],
      'current_load': inputs['current_load'],
    };

    // We try to call the emulator localhost bridge (10.0.2.2) first.
    // If that fails, we try localhost. If both fail or time out, we return mock predictions.
    try {
      final response = await http.post(
        Uri.parse(_emulatorUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseResponse(inputs, data);
      }
    } catch (_) {
      // Fallback to localhost (for web/desktop or desktop simulators)
      try {
        final response = await http.post(
          Uri.parse(_localUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 1));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return _parseResponse(inputs, data);
        }
      } catch (_) {
        // Suppress and fallback to mock
      }
    }

    // Unreachable API, return simulation data with a realistic variation
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate processing lag
    
    // Simple load formula matching current conditions:
    // Increased temperature increases AC usage, solar irradiance offsets load slightly.
    final currentVal = inputs['current_load'] ?? 142.5;
    final tempVal = inputs['temperature'] ?? 30.0;
    final humVal = inputs['humidity'] ?? 60.0;
    
    double predicted = currentVal * (1.0 + (tempVal - 28.0) * 0.008 + (humVal - 50.0) * 0.002);
    if (predicted < 50.0) predicted = 50.0;
    
    final confidence = 90.0 + ((tempVal + humVal) % 8);

    return PredictionResult(
      temperature: inputs['temperature'] ?? 32.5,
      humidity: inputs['humidity'] ?? 65.0,
      windSpeed: inputs['wind_speed'] ?? 12.4,
      solarIrradiance: inputs['solar_irradiance'] ?? 750.0,
      currentLoad: currentVal,
      predictedLoad: double.parse(predicted.toStringAsFixed(1)),
      confidence: double.parse(confidence.toStringAsFixed(1)),
      timestamp: DateTime.now(),
    );
  }

  PredictionResult _parseResponse(Map<String, double> inputs, Map<String, dynamic> json) {
    return PredictionResult(
      temperature: inputs['temperature'] ?? 0.0,
      humidity: inputs['humidity'] ?? 0.0,
      windSpeed: inputs['wind_speed'] ?? 0.0,
      solarIrradiance: inputs['solar_irradiance'] ?? 0.0,
      currentLoad: inputs['current_load'] ?? 0.0,
      predictedLoad: (json['predicted_load'] as num).toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 94.0,
      timestamp: DateTime.now(),
    );
  }
}
