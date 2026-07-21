class StationStatus {
  final String id;
  final String name;
  final String location;
  final double currentLoad; // MW
  final double capacity; // MW
  final String status; // 'Normal', 'Warning', 'Critical', 'Offline'
  final double frequency; // Hz
  final double voltage; // kV
  final int activeFeeds;
  final DateTime lastUpdated;

  const StationStatus({
    required this.id,
    required this.name,
    required this.location,
    required this.currentLoad,
    required this.capacity,
    required this.status,
    required this.frequency,
    required this.voltage,
    required this.activeFeeds,
    required this.lastUpdated,
  });

  double get loadPercent => (currentLoad / capacity).clamp(0.0, 1.0);

  factory StationStatus.fromMock(Map<String, dynamic> data) {
    return StationStatus(
      id: data['id'] as String,
      name: data['name'] as String,
      location: data['location'] as String,
      currentLoad: (data['currentLoad'] as num).toDouble(),
      capacity: (data['capacity'] as num).toDouble(),
      status: data['status'] as String,
      frequency: (data['frequency'] as num).toDouble(),
      voltage: (data['voltage'] as num).toDouble(),
      activeFeeds: data['activeFeeds'] as int,
      lastUpdated: DateTime.now(),
    );
  }
}
