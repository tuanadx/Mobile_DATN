import 'package:flutter/material.dart';
import 'package:savefood/core/configs/theme/app_color.dart';

class VoucherWalletPage extends StatefulWidget {
  const VoucherWalletPage({super.key});

  @override
  State<VoucherWalletPage> createState() => _VoucherWalletPageState();
}

class _VoucherWalletPageState extends State<VoucherWalletPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Ví Voucher',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Lịch sử',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 10),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColor.primary,
              unselectedLabelColor: Colors.black54,
              indicatorColor: AppColor.primary,
              labelStyle: const TextStyle(fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              tabs: const [
                Tab(text: 'Tất cả'),
                Tab(text: 'Giảm giá món'),
                Tab(text: 'Phí vận chuyển'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _EmptyVoucherView(),
          _EmptyVoucherView(),
          _EmptyVoucherView(),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}

class _EmptyVoucherView extends StatelessWidget {
  const _EmptyVoucherView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.confirmation_number_outlined,
                size: 96, color: Colors.black12),
            SizedBox(height: 16),
            Text(
              'Ui, chưa có voucher trong ví',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Dạo một vòng các bộ sưu tập và cửa hàng để thu thập thêm voucher nhé!',
              style: TextStyle(fontSize: 12, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


