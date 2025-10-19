class PromoModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final double discountPercentage;
  final String imageUrl;
  final String validUntil;
  final String? minimumPurchase;
  final String category;

  const PromoModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.discountPercentage,
    required this.imageUrl,
    required this.validUntil,
    this.minimumPurchase,
    required this.category,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      validUntil: json['validUntil'] as String,
      minimumPurchase: json['minimumPurchase'] as String?,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'discountPercentage': discountPercentage,
      'imageUrl': imageUrl,
      'validUntil': validUntil,
      'minimumPurchase': minimumPurchase,
      'category': category,
    };
  }
}
