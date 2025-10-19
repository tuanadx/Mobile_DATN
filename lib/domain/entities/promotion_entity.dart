class PromotionEntity {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final double discountPercentage;
  final String imageUrl;
  final String validUntil;
  final String? minimumPurchase;
  final String category;

  const PromotionEntity({
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
}
