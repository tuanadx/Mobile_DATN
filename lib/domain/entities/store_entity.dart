class StoreEntity {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final String deliveryAddress;
  final List<String> tags;
  final bool isFavorite;
  final String phoneNumber;
  final String address;
  final List<String> workingHours;
  final double deliveryFee;
  final double minOrderAmount;

  const StoreEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryAddress,
    required this.tags,
    this.isFavorite = false,
    required this.phoneNumber,
    required this.address,
    required this.workingHours,
    required this.deliveryFee,
    required this.minOrderAmount,
  });
}
