import 'package:flutter/material.dart';
import '../models/prediction_result.dart';
import '../services/api_service.dart';
import '../models/mock_data.dart';

class PredictionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Environmental inputs
  double _temperature = 30.0;
  double _humidity = 60.0;
  double _windSpeed = 12.0;
  double _solarIrradiance = 500.0;
  double _currentLoad = 140.0;

  PredictionResult? _predictionResult;
  bool _isPredicting = false;
  bool _isLoadingHistory = false;
  List<PredictionResult> _history = [];

  // Getters
  double get temperature => _temperature;
  double get humidity => _humidity;
  double get windSpeed => _windSpeed;
  double get solarIrradiance => _solarIrradiance;
  double get currentLoad => _currentLoad;

  PredictionResult? get predictionResult => _predictionResult;
  bool get isPredicting => _isPredicting;
  bool get isLoadingHistory => _isLoadingHistory;
  List<PredictionResult> get history => _history;

  void setTemperature(double val) {
    _temperature = val;
    notifyListeners();
  }

  void setHumidity(double val) {
    _humidity = val;
    notifyListeners();
  }

  void setWindSpeed(double val) {
    _windSpeed = val;
    notifyListeners();
  }

  void setSolarIrradiance(double val) {
    _solarIrradiance = val;
    notifyListeners();
  }

  void setCurrentLoad(double val) {
    _currentLoad = val;
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    _history = List.from(MockData.mockPredictions);

    _isLoadingHistory = false;
    notifyListeners();
  }

  Future<bool> performPrediction() async {
    _isPredicting = true;
    notifyListeners();

    final inputs = {
      'temperature': _temperature,
      'humidity': _humidity,
      'wind_speed': _windSpeed,
      'solar_irradiance': _solarIrradiance,
      'current_load': _currentLoad,
    };

    try {
      final res = await _apiService.predictLoad(inputs);
      _predictionResult = res;
      // Add to front of history list
      _history.insert(0, res);
      if (_history.length > 10) {
        _history.removeLast();
      }
      _isPredicting = false;
      notifyListeners();
      return true;
    } catch (_) {
      // Error boundary fallback
    }

    _isPredicting = false;
    notifyListeners();
    return false;
  }

  void clearResult() {
    _predictionResult = null;
    notifyListeners();
  }
}
