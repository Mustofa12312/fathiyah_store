class ShopModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String receiptFooter;
  final String logoUrl;

  ShopModel({
    required this.id,
    required this.name,
    this.address = '',
    this.phone = '',
    this.receiptFooter = 'Terima kasih atas kunjungan Anda!',
    this.logoUrl = '',
  });

  factory ShopModel.fromJson(Map<String, dynamic> json, String documentId) {
    return ShopModel(
      id: documentId,
      name: json['name'] ?? 'Fathiyah Store',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      receiptFooter: json['receiptFooter'] ?? 'Terima kasih atas kunjungan Anda!',
      logoUrl: json['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'receiptFooter': receiptFooter,
      'logoUrl': logoUrl,
    };
  }

  ShopModel copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? receiptFooter,
    String? logoUrl,
  }) {
    return ShopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
