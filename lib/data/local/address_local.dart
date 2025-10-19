import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/address.dart';

class AddressService {
  static const String _key = 'addresses';

  static Future<List<AddressItem>> loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List)
          .whereType<Map<String, dynamic>>()
          .map(AddressItem.fromJson)
          .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAddresses(List<AddressItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  static Future<void> addAddress(AddressItem item) async {
    final items = await loadAddresses();
    items.insert(0, item); // newest on top
    await saveAddresses(items);
  }
}


