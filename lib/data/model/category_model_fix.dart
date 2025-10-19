class CategoryModel {
  final String id;
  final String name;
  final String iconPath;
  final String? route;
  final String? discountText;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconPath,
    this.route,
    this.discountText,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconPath: json['iconPath'] as String,
      route: json['route'] as String?,
      discountText: json['discountText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'route': route,
      'discountText': discountText,
    };
  }
}
