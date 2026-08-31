class UserModel {
  final String id;
  final String name;
  final String username; // used for login
  final String role; // 'admin', 'supervisor', 'cashier'
  final String status; // 'aktif' or 'nonaktif'
  final String? pin; // 6-digit PIN for supervisor/admin

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    this.status = 'aktif',
    this.pin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String documentId) {
    return UserModel(
      id: documentId,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'cashier',
      status: json['status'] ?? 'aktif',
      pin: json['pin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'role': role,
      'status': status,
      if (pin != null) 'pin': pin,
    };
  }
  
  bool get isAdmin => role == 'admin';
  bool get isSupervisor => role == 'supervisor' || role == 'admin';
  bool get isCashier => role == 'cashier';

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? role,
    String? status,
    String? pin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      status: status ?? this.status,
      pin: pin ?? this.pin,
    );
  }
}
