class UnitModel {
  final String id;
  final String name;
  final String? description;

  UnitModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json, String documentId) {
    return UnitModel(
      id: documentId,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
