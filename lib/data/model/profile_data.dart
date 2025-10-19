import 'auth_response.dart';
import 'address.dart';

class ProfileData {
  final User user;
  final List<AddressItem> addresses;
  final List<String> favoriteStoreIds;
  final String? avatar; // allow override if not in user

  ProfileData({
    required this.user,
    required this.addresses,
    required this.favoriteStoreIds,
    this.avatar,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    try {
      print('ProfileData.fromJson: Parsing JSON: $json');
      
      final userJson = (json['user'] is Map<String, dynamic>) ? json['user'] : json;
      print('ProfileData.fromJson: User JSON: $userJson');
      
      final addressesJson = (json['addresses'] as List?) ?? const [];
      print('ProfileData.fromJson: Addresses JSON: $addressesJson');
      
      final favoritesJson = (json['favorite_stores'] as List?) ?? const [];
      print('ProfileData.fromJson: Favorites JSON: $favoritesJson');
      
      final user = User.fromJson(Map<String, dynamic>.from(userJson));
      print('ProfileData.fromJson: User parsed successfully');
      
      final addresses = addressesJson
          .whereType<Map>()
          .map((e) {
            print('ProfileData.fromJson: Parsing address: $e');
            return AddressItem.fromJson(Map<String, dynamic>.from(e));
          })
          .toList();
      print('ProfileData.fromJson: Addresses parsed successfully: ${addresses.length}');
      
      final favoriteStoreIds = favoritesJson.map((e) => e.toString()).toList();
      print('ProfileData.fromJson: Favorites parsed successfully: ${favoriteStoreIds.length}');
      
      return ProfileData(
        user: user,
        addresses: addresses,
        favoriteStoreIds: favoriteStoreIds,
        avatar: json['avatar'] as String?,
      );
    } catch (e, stackTrace) {
      print('ProfileData.fromJson: Error parsing: $e');
      print('ProfileData.fromJson: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'addresses': addresses.map((e) => e.toJson()).toList(),
        'favorite_stores': favoriteStoreIds,
        'avatar': avatar,
      };
}


