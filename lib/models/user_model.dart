import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String facilityName;
  final String location;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool notificationsOn;
  final bool autoRefresh;
  final String profileImageUrl;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.facilityName,
    required this.location,
    required this.createdAt,
    required this.lastLoginAt,
    required this.notificationsOn,
    required this.autoRefresh,
    required this.profileImageUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'operator',
      facilityName: data['facilityName'] as String? ?? '',
      location: data['location'] as String? ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] as Timestamp).toDate() 
          : DateTime.now(),
      notificationsOn: data['notificationsOn'] as bool? ?? true,
      autoRefresh: data['autoRefresh'] as bool? ?? true,
      profileImageUrl: data['profileImageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'facilityName': facilityName,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'notificationsOn': notificationsOn,
      'autoRefresh': autoRefresh,
      'profileImageUrl': profileImageUrl,
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? facilityName,
    String? location,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? notificationsOn,
    bool? autoRefresh,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      facilityName: facilityName ?? this.facilityName,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      notificationsOn: notificationsOn ?? this.notificationsOn,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  String get initials {
    final name = fullName.trim();
    if (name.isEmpty) return "US";
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
