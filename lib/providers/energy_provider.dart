import 'package:flutter/material.dart';
import '../models/energy_reading.dart';
import '../models/alert_model.dart';
import '../models/mock_data.dart';

class EnergyProvider with ChangeNotifier {
  List<EnergyReading> _readings = [];
  List<AlertModel> _alerts = [];
  bool _isLoadingReadings = false;
  bool _isLoadingAlerts = false;
  
  String _activeAlertFilter = "All";
  String _activeAnalyticsPeriod = "7 Days";

  List<EnergyReading> get readings => _readings;
  List<AlertModel> get alerts => _alerts;
  bool get isLoadingReadings => _isLoadingReadings;
  bool get isLoadingAlerts => _isLoadingAlerts;
  String get activeAlertFilter => _activeAlertFilter;
  String get activeAnalyticsPeriod => _activeAnalyticsPeriod;

  // Dynamic system status based on active alerts
  String get systemStatus {
    final activeAlerts = _alerts.where((a) => a.status == "Active");
    if (activeAlerts.any((a) => a.severity == "Critical")) {
      return "Critical";
    } else if (activeAlerts.any((a) => a.severity == "Warning")) {
      return "Warning";
    }
    return "Normal";
  }

  // Filtered alerts computed dynamically
  List<AlertModel> get filteredAlerts {
    if (_activeAlertFilter == "All") {
      return _alerts;
    } else if (_activeAlertFilter == "Resolved") {
      return _alerts.where((a) => a.status == "Resolved").toList();
    } else {
      // Filter by severity: "Critical", "Warning", "Normal"
      // Normal badge maps to severity "Normal", status "Active" (typically)
      return _alerts.where((a) => a.severity == _activeAlertFilter && a.status == "Active").toList();
    }
  }

  Future<void> fetchReadings({bool silent = false}) async {
    if (!silent) {
      _isLoadingReadings = true;
      notifyListeners();
    }

    // Simulate shimmer loading delay
    await Future.delayed(const Duration(milliseconds: 1000));
    _readings = List.from(MockData.mockReadings);
    
    _isLoadingReadings = false;
    notifyListeners();
  }

  Future<void> fetchAlerts({bool silent = false}) async {
    if (!silent) {
      _isLoadingAlerts = true;
      notifyListeners();
    }

    // Simulate shimmer loading delay
    await Future.delayed(const Duration(milliseconds: 1200));
    _alerts = List.from(MockData.mockAlerts);

    _isLoadingAlerts = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchReadings(silent: false),
      fetchAlerts(silent: false),
    ]);
  }

  void setAlertFilter(String filter) {
    _activeAlertFilter = filter;
    notifyListeners();
  }

  void setAnalyticsPeriod(String period) {
    _activeAnalyticsPeriod = period;
    // We can simulate slightly different readings or just redraw
    notifyListeners();
  }

  void resolveAlert(String alertId) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      final oldAlert = _alerts[index];
      _alerts[index] = AlertModel(
        id: oldAlert.id,
        title: oldAlert.title,
        description: oldAlert.description,
        timestamp: oldAlert.timestamp,
        severity: oldAlert.severity,
        status: "Resolved",
        location: oldAlert.location,
      );
      notifyListeners();
    }
  }

  void clearAllAlerts() {
    _alerts.clear();
    notifyListeners();
  }
}
