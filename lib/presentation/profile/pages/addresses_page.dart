import 'package:flutter/material.dart';
import 'package:savefood/core/configs/theme/app_color.dart';
import 'package:savefood/data/local/address_local.dart';
import 'package:savefood/data/model/address.dart';
import 'package:savefood/data/services/Auth/auth_service.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  List<AddressItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Ưu tiên địa chỉ từ profile API, sau đó từ local storage
    final profile = AuthService.getProfile();
    print('AddressesPage: Profile from AuthService: $profile');
    List<AddressItem> items = [];
    
    if (profile != null && profile.addresses.isNotEmpty) {
      // Lấy từ profile API
      items = profile.addresses;
      print('AddressesPage: Using addresses from profile: ${items.length}');
    } else {
      // Fallback: lấy từ local storage
      items = await AddressService.loadAddresses();
      print('AddressesPage: Using addresses from local storage: ${items.length}');
    }
    
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Địa chỉ giao hàng',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600,fontSize:12),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final added = await Navigator.pushNamed(context, '/add-address');
                if (added == true) {
                  _load();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Thêm địa chỉ mới',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Quick add rows
          _QuickAddRow(
            icon: Icons.home_outlined,
            title: 'Thêm địa chỉ Nhà',
            onTap: () async {
              final added = await Navigator.pushNamed(context, '/add-address');
              if (added == true) {
                _load();
              }
            },
          ),
          const SizedBox(height: 8),
          // Saved addresses (empty by default)
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : _items.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có địa chỉ nào',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return _AddressCard(item: item);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressItem item;
  const _AddressCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bookmark_border, color: AppColor.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Sửa',
                      style: TextStyle(
                        fontSize:12,
                        color: AppColor.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.fullAddress,
                style: const TextStyle(color: Colors.black54),
              ),
              if (item.building != null && item.building!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Tòa nhà: ${item.building}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              if (item.gate != null && item.gate!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Cổng: ${item.gate}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              if (item.noteForDriver != null && item.noteForDriver!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Ghi chú: ${item.noteForDriver}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                '${item.contactName}   ${item.phone}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAddRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColor.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


