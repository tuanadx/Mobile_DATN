import 'package:flutter/material.dart';
import 'package:feedia/core/configs/theme/app_color.dart';
import 'package:feedia/data/model/address.dart';
import 'package:feedia/data/services/address_api.dart';
import 'package:feedia/data/services/profile_service.dart';
import 'package:feedia/data/services/Auth/auth_service.dart';
import 'package:feedia/presentation/profile/widgets/location_picker_widget.dart';
import 'package:feedia/common/widgets/auth_guard.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _gateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool get _valid =>
      _nameController.text.isNotEmpty &&
      _phoneController.text.length >= 9 &&
      _addressController.text.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _buildingController.dispose();
    _gateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thêm địa chỉ',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              children: [
                _inputField(controller: _nameController, hint: 'Tên', keyboardType: TextInputType.name,
                    trailing: const Icon(Icons.person_outline, color: Colors.black45)),
                const SizedBox(height: 12),
                _inputField(controller: _phoneController, hint: 'Điện thoại', keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _pickerField(controller: _addressController, hint: 'Chọn địa chỉ', onTap: _openAddressEditor),
                const SizedBox(height: 12),
                _inputField(controller: _buildingController, hint: 'Tòa nhà, Số tầng (Không bắt buộc)'),
                const SizedBox(height: 12),
                _inputField(controller: _gateController, hint: 'Cổng (không bắt buộc)'),
                const SizedBox(height: 12),
                _noteArea(controller: _noteController, hint: 'Ghi chú cho Tài xế (không bắt buộc)'),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _valid ? () async {
                    final item = AddressItem(
                      title: _addressController.text.trim(),
                      fullAddress: _addressController.text.trim(),
                      contactName: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      building: _buildingController.text.trim().isEmpty ? null : _buildingController.text.trim(),
                      gate: _gateController.text.trim().isEmpty ? null : _gateController.text.trim(),
                      noteForDriver: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
                    );
                    try {
                      // Gửi lên server; nếu thành công mới gọi /me và lưu local
                      await AddressApi.createAddress(item);
                      final profile = await ProfileService.fetchProfile();
                      await AuthService.saveProfile(profile);
                      if (!mounted) return;
                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi lưu địa chỉ: $e')),
                      );
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    disabledBackgroundColor: Colors.grey[300],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Lưu địa chỉ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }


  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => setState(() {}),
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: trailing,
            ),
        ],
      ),
    );
  }

  Widget _pickerField({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: _inputField(
          controller: controller,
          hint: hint,
          trailing: const Icon(Icons.chevron_right, color: Colors.black45),
        ),
      ),
    );
  }

  void _openAddressEditor() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerWidget(
          title: 'Chọn địa chỉ',
          initialValue: _addressController.text,
          onLocationSelected: (selected) {
            _addressController.text = selected;
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _noteArea({required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        maxLines: 6,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}


