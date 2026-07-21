import 'user_model.dart';
import 'energy_reading.dart';
import 'alert_model.dart';
import 'prediction_result.dart';
import 'station_model.dart';
import 'theft_model.dart';
import 'report_model.dart';

class MockData {
  MockData._();

  static final UserModel mockUser = UserModel(
    uid: "mock_uid_hiren",
    fullName: "Hiren Patel",
    email: "hiren.patel@powerguard.gov",
    phone: "+91 98765 43210",
    role: "Grid Operations Chief",
    facilityName: "Vadodara Grid Substation 4",
    location: "Vadodara, Gujarat",
    createdAt: DateTime(2024, 1, 1),
    lastLoginAt: DateTime.now(),
    notificationsOn: true,
    autoRefresh: true,
    profileImageUrl: "",
  );

  static final List<EnergyReading> mockReadings = List.generate(24, (index) {
    final hour = index;
    final time = DateTime.now().subtract(Duration(hours: 23 - index));
    
    // Create consumption wave that peaks around mid-day and evening
    double baseLoad = 120.0;
    if (hour >= 9 && hour <= 17) {
      baseLoad += 30.0; // Day peak
    } else if (hour >= 18 && hour <= 22) {
      baseLoad += 45.0; // Evening peak
    }
    
    // Add minor fluctuations
    final fluctuation = (index * 7) % 15 - 7;
    double predicted = baseLoad + fluctuation;
    double actual = predicted;

    // Inject anomalies for specific hours to represent theft / load spikes
    String theftRisk = "Low";
    String anomalyStatus = "Normal";

    if (hour == 14) {
      // Massive spike (unmetered load/theft suspicion)
      actual += 35.5; 
      theftRisk = "High";
      anomalyStatus = "Critical";
    } else if (hour == 19) {
      // Off-peak anomaly
      actual += 18.0;
      theftRisk = "Medium";
      anomalyStatus = "Warning";
    } else if (hour == 8) {
      // Under-consumption anomaly
      actual -= 12.0;
      theftRisk = "Low";
      anomalyStatus = "Warning";
    }

    return EnergyReading(
      timestamp: time,
      actualLoad: double.parse(actual.toStringAsFixed(1)),
      predictedLoad: double.parse(predicted.toStringAsFixed(1)),
      theftRisk: theftRisk,
      anomalyStatus: anomalyStatus,
    );
  });

  static final List<AlertModel> mockAlerts = [
    AlertModel(
      id: "ALT-001",
      title: "Possible Theft Detected",
      description: "Meter bypass behavior signature identified in Sector 3-B commercial feeds.",
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      severity: "Critical",
      status: "Active",
      location: "Sector 3-B, Vadodara",
    ),
    AlertModel(
      id: "ALT-002",
      title: "Abnormal Load Spike",
      description: "Substation load surged by 28.5% over the 15-minute average threshold.",
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
      severity: "Critical",
      status: "Active",
      location: "Feeder Line 12, Halol",
    ),
    AlertModel(
      id: "ALT-003",
      title: "Transformer Overload",
      description: "Transformer T-45 temp registered at 92.4°C under high continuous demand.",
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 45)),
      severity: "Critical",
      status: "Resolved",
      location: "Industrial Park A",
    ),
    AlertModel(
      id: "ALT-004",
      title: "Unusual Consumption Pattern",
      description: "Off-peak energy draw exceeded standard baseline by 18.2 MW.",
      timestamp: DateTime.now().subtract(const Duration(hours: 7)),
      severity: "Warning",
      status: "Active",
      location: "Manjalpur Feeder",
    ),
    AlertModel(
      id: "ALT-005",
      title: "Voltage Fluctuation Alert",
      description: "Main feeder line recorded drop below 210V (tolerance limit exceeded).",
      timestamp: DateTime.now().subtract(const Duration(hours: 11)),
      severity: "Warning",
      status: "Active",
      location: "Alkapuri Substation",
    ),
    AlertModel(
      id: "ALT-006",
      title: "High Load at Off-Peak Hour",
      description: "Load profile at 03:00 AM deviated +22% from historical weekday norms.",
      timestamp: DateTime.now().subtract(const Duration(hours: 14)),
      severity: "Warning",
      status: "Resolved",
      location: "Waghodia GIDC",
    ),
    AlertModel(
      id: "ALT-007",
      title: "Phase Current Imbalance",
      description: "Line current delta between R and B phase exceeds safe limit (14.5A delta).",
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      severity: "Warning",
      status: "Resolved",
      location: "Gotri Residential 2",
    ),
    AlertModel(
      id: "ALT-008",
      title: "System Check Passed",
      description: "Daily automated telemetry diagnostic report complete. 0 hardware faults.",
      timestamp: DateTime.now().subtract(const Duration(hours: 22)),
      severity: "Normal",
      status: "Resolved",
      location: "Substation Central Control",
    ),
    AlertModel(
      id: "ALT-009",
      title: "Load Within Range",
      description: "High demand hours completed with system stability maintained at 100%.",
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      severity: "Normal",
      status: "Resolved",
      location: "Vadodara Grid Substation 4",
    ),
    AlertModel(
      id: "ALT-010",
      title: "API Connection Restored",
      description: "Primary edge-computing sync node re-established telemetry pipeline.",
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      severity: "Normal",
      status: "Resolved",
      location: "Data Sync Center",
    ),
  ];

  static final List<PredictionResult> mockPredictions = [
    PredictionResult(
      temperature: 32.5,
      humidity: 65.0,
      windSpeed: 12.4,
      solarIrradiance: 750.0,
      currentLoad: 142.5,
      predictedLoad: 147.3,
      confidence: 94.0,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    PredictionResult(
      temperature: 31.0,
      humidity: 70.0,
      windSpeed: 10.5,
      solarIrradiance: 680.0,
      currentLoad: 138.2,
      predictedLoad: 141.6,
      confidence: 92.5,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
    ),
    PredictionResult(
      temperature: 28.5,
      humidity: 78.0,
      windSpeed: 15.0,
      solarIrradiance: 200.0,
      currentLoad: 155.0,
      predictedLoad: 152.1,
      confidence: 91.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    PredictionResult(
      temperature: 26.0,
      humidity: 82.0,
      windSpeed: 8.0,
      solarIrradiance: 0.0,
      currentLoad: 128.0,
      predictedLoad: 126.4,
      confidence: 95.8,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    PredictionResult(
      temperature: 34.0,
      humidity: 58.0,
      windSpeed: 14.2,
      solarIrradiance: 890.0,
      currentLoad: 145.2,
      predictedLoad: 150.8,
      confidence: 93.4,
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  // ── Real-Time Monitoring Mock Data ──────────────────────────────────────────
  static final List<StationStatus> mockStations = [
    StationStatus(
      id: 'SS-01',
      name: 'Vadodara Central Substation',
      location: 'Ring Road, Vadodara',
      currentLoad: 148.3,
      capacity: 200.0,
      status: 'Normal',
      frequency: 49.98,
      voltage: 132.4,
      activeFeeds: 12,
      lastUpdated: DateTime.now(),
    ),
    StationStatus(
      id: 'SS-02',
      name: 'Alkapuri Feeder Station',
      location: 'Alkapuri, Vadodara',
      currentLoad: 87.6,
      capacity: 100.0,
      status: 'Warning',
      frequency: 49.85,
      voltage: 127.2,
      activeFeeds: 8,
      lastUpdated: DateTime.now().subtract(const Duration(seconds: 30)),
    ),
    StationStatus(
      id: 'SS-03',
      name: 'Waghodia GIDC Grid',
      location: 'GIDC, Waghodia',
      currentLoad: 195.8,
      capacity: 200.0,
      status: 'Critical',
      frequency: 49.72,
      voltage: 122.1,
      activeFeeds: 16,
      lastUpdated: DateTime.now().subtract(const Duration(seconds: 12)),
    ),
    StationStatus(
      id: 'SS-04',
      name: 'Manjalpur Residential',
      location: 'Manjalpur, Vadodara',
      currentLoad: 42.0,
      capacity: 80.0,
      status: 'Normal',
      frequency: 50.01,
      voltage: 133.0,
      activeFeeds: 6,
      lastUpdated: DateTime.now().subtract(const Duration(seconds: 45)),
    ),
    StationStatus(
      id: 'SS-05',
      name: 'Halol Industrial Feeder',
      location: 'Halol, Panchmahal',
      currentLoad: 0.0,
      capacity: 150.0,
      status: 'Offline',
      frequency: 0.0,
      voltage: 0.0,
      activeFeeds: 0,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    StationStatus(
      id: 'SS-06',
      name: 'Gotri Residential Hub',
      location: 'Gotri, Vadodara',
      currentLoad: 63.5,
      capacity: 90.0,
      status: 'Normal',
      frequency: 49.99,
      voltage: 132.8,
      activeFeeds: 9,
      lastUpdated: DateTime.now().subtract(const Duration(seconds: 20)),
    ),
  ];

  // ── Power Theft Detection Mock Data ─────────────────────────────────────────
  static final List<TheftRecord> mockTheftRecords = [
    TheftRecord(
      id: 'TH-001',
      stationId: 'SS-02',
      stationName: 'Alkapuri Feeder Station',
      location: 'Alkapuri, Vadodara',
      theftProbability: 87.4,
      suspectedLoss: 234.5,
      investigationStatus: 'Investigating',
      detectionMethod: 'Meter Bypass Pattern',
      detectedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 18)),
      notes: 'Commercial meter bypass signatures identified via AMR mismatch.',
    ),
    TheftRecord(
      id: 'TH-002',
      stationId: 'SS-03',
      stationName: 'Waghodia GIDC Grid',
      location: 'GIDC, Waghodia',
      theftProbability: 91.2,
      suspectedLoss: 512.8,
      investigationStatus: 'Open',
      detectionMethod: 'Load Profile Deviation',
      detectedAt: DateTime.now().subtract(const Duration(hours: 5)),
      notes: 'Industrial feeder draw exceeds billing data by 36% consistently.',
    ),
    TheftRecord(
      id: 'TH-003',
      stationId: 'SS-01',
      stationName: 'Vadodara Central Substation',
      location: 'Ring Road, Vadodara',
      theftProbability: 54.6,
      suspectedLoss: 97.3,
      investigationStatus: 'Investigating',
      detectionMethod: 'Phase Current Imbalance',
      detectedAt: DateTime.now().subtract(const Duration(hours: 11)),
      notes: 'Phase imbalance indicates possible direct line tapping in sector 4.',
    ),
    TheftRecord(
      id: 'TH-004',
      stationId: 'SS-06',
      stationName: 'Gotri Residential Hub',
      location: 'Gotri, Vadodara',
      theftProbability: 23.1,
      suspectedLoss: 18.2,
      investigationStatus: 'Resolved',
      detectionMethod: 'Smart Meter Alert',
      detectedAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      notes: 'Tampered seal confirmed. Meter replaced. Case filed with authorities.',
    ),
    TheftRecord(
      id: 'TH-005',
      stationId: 'SS-04',
      stationName: 'Manjalpur Residential',
      location: 'Manjalpur, Vadodara',
      theftProbability: 66.8,
      suspectedLoss: 145.9,
      investigationStatus: 'Open',
      detectionMethod: 'Anomaly ML Detection',
      detectedAt: DateTime.now().subtract(const Duration(hours: 8, minutes: 40)),
      notes: 'AI model flagged abnormal after-midnight consumption spike patterns.',
    ),
    TheftRecord(
      id: 'TH-006',
      stationId: 'SS-01',
      stationName: 'Vadodara Central Substation',
      location: 'Ring Road, Vadodara',
      theftProbability: 79.3,
      suspectedLoss: 302.4,
      investigationStatus: 'Investigating',
      detectionMethod: 'Billing Mismatch Analysis',
      detectedAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      notes: 'Three-month billing discrepancy of ~11% flagged for verification.',
    ),
  ];

  // ── Monthly Reports Mock Data ────────────────────────────────────────────────
  static final List<MonthlyReport> mockReports = [
    MonthlyReport(
      id: 'RPT-2026-06',
      monthLabel: 'June 2026',
      totalConsumption: 68240.5,
      peakDemand: 195.8,
      avgDailyLoad: 147.3,
      forecastAccuracy: 94.2,
      totalAlerts: 12,
      criticalAlerts: 4,
      warningAlerts: 6,
      theftDetections: 3,
      costSaved: 48500.0,
      status: 'Draft',
    ),
    MonthlyReport(
      id: 'RPT-2026-05',
      monthLabel: 'May 2026',
      totalConsumption: 142310.8,
      peakDemand: 202.1,
      avgDailyLoad: 152.6,
      forecastAccuracy: 92.7,
      totalAlerts: 28,
      criticalAlerts: 9,
      warningAlerts: 15,
      theftDetections: 6,
      costSaved: 91200.0,
      status: 'Available',
    ),
    MonthlyReport(
      id: 'RPT-2026-04',
      monthLabel: 'April 2026',
      totalConsumption: 136800.0,
      peakDemand: 189.4,
      avgDailyLoad: 144.8,
      forecastAccuracy: 91.3,
      totalAlerts: 22,
      criticalAlerts: 7,
      warningAlerts: 11,
      theftDetections: 4,
      costSaved: 73800.0,
      status: 'Available',
    ),
    MonthlyReport(
      id: 'RPT-2026-03',
      monthLabel: 'March 2026',
      totalConsumption: 148920.5,
      peakDemand: 198.3,
      avgDailyLoad: 158.2,
      forecastAccuracy: 89.8,
      totalAlerts: 35,
      criticalAlerts: 12,
      warningAlerts: 18,
      theftDetections: 8,
      costSaved: 112400.0,
      status: 'Available',
    ),
    MonthlyReport(
      id: 'RPT-2026-02',
      monthLabel: 'February 2026',
      totalConsumption: 121650.0,
      peakDemand: 185.7,
      avgDailyLoad: 140.1,
      forecastAccuracy: 90.5,
      totalAlerts: 19,
      criticalAlerts: 5,
      warningAlerts: 10,
      theftDetections: 3,
      costSaved: 62100.0,
      status: 'Available',
    ),
    MonthlyReport(
      id: 'RPT-2026-01',
      monthLabel: 'January 2026',
      totalConsumption: 155480.2,
      peakDemand: 210.4,
      avgDailyLoad: 163.8,
      forecastAccuracy: 88.4,
      totalAlerts: 41,
      criticalAlerts: 14,
      warningAlerts: 22,
      theftDetections: 11,
      costSaved: 138700.0,
      status: 'Available',
    ),
  ];
}
