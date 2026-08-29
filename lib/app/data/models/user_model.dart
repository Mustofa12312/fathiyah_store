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
