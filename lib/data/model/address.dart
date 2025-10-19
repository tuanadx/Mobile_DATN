class AddressItem {
  final String title; // e.g., 107 B7 Tô Hiệu nhỏ
  final String fullAddress; // base address
  final String contactName; // name label
  final String phone; // phone number
  final String? building; // Tòa nhà, Số tầng
  final String? gate; // Cổng
  final String? noteForDriver; // Ghi chú cho Tài xế

  AddressItem({
    required this.title,
    required this.fullAddress,
    required this.contactName,
    required this.phone,
    this.building,
    this.gate,
    this.noteForDriver,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'fullAddress': fullAddress,
        'contactName': contactName,
        'phone': phone,
        'building': building,
        'gate': gate,
        'noteForDriver': noteForDriver,
      };

  factory AddressItem.fromJson(Map<String, dynamic> json) => AddressItem(
        title: json['title'] ?? '',
        fullAddress: json['fullAddress'] ?? '',
        contactName: json['contactName'] ?? '',
        phone: json['phone'] ?? '',
        building: (json['building'] as String?)?.isEmpty == true ? null : json['building'] as String?,
        gate: (json['gate'] as String?)?.isEmpty == true ? null : json['gate'] as String?,
        noteForDriver: (json['noteForDriver'] as String?)?.isEmpty == true ? null : json['noteForDriver'] as String?,
      );
}


