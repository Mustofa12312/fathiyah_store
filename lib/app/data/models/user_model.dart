// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
class UserModel {
  final String id;
  final String name;
  final String username; // used for login
  final String password; // dummy for local mock
  final String role; // 'admin' or 'cashier'
  final String status; // 'aktif' or 'nonaktif'

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    this.status = 'aktif',
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String documentId) {
    return UserModel(
      id: documentId,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'cashier',
      status: json['status'] ?? 'aktif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'password': password,
      'role': role,
      'status': status,
    };
  }
  
  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    String? role,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
