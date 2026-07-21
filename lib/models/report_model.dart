class MonthlyReport {
  final String id;
  final String monthLabel; // e.g. "June 2026"
  final double totalConsumption; // kWh
  final double peakDemand; // MW
  final double avgDailyLoad; // MW
  final double forecastAccuracy; // %
  final int totalAlerts;
  final int criticalAlerts;
  final int warningAlerts;
  final int theftDetections;
  final double costSaved; // USD equivalent
  final String status; // 'Available', 'Processing', 'Draft'

  const MonthlyReport({
    required this.id,
    required this.monthLabel,
    required this.totalConsumption,
    required this.peakDemand,
    required this.avgDailyLoad,
    required this.forecastAccuracy,
    required this.totalAlerts,
    required this.criticalAlerts,
    required this.warningAlerts,
    required this.theftDetections,
    required this.costSaved,
    required this.status,
  });

  factory MonthlyReport.fromMock(Map<String, dynamic> data) {
    return MonthlyReport(
      id: data['id'] as String,
      monthLabel: data['monthLabel'] as String,
      totalConsumption: (data['totalConsumption'] as num).toDouble(),
      peakDemand: (data['peakDemand'] as num).toDouble(),
      avgDailyLoad: (data['avgDailyLoad'] as num).toDouble(),
      forecastAccuracy: (data['forecastAccuracy'] as num).toDouble(),
      totalAlerts: data['totalAlerts'] as int,
      criticalAlerts: data['criticalAlerts'] as int,
      warningAlerts: data['warningAlerts'] as int,
      theftDetections: data['theftDetections'] as int,
      costSaved: (data['costSaved'] as num).toDouble(),
      status: data['status'] as String,
    );
  }
}
