class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final String type; // 'general' or 'vip'
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.type = 'general',
    required this.createdAt,
  });

  bool get isVip => type == 'vip';

  factory CustomerModel.fromJson(Map<String, dynamic> json, String documentId) {
    return CustomerModel(
      id: documentId,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      type: json['type'] as String? ?? 'general',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? type,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
