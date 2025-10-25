import 'package:flutter/material.dart';
import 'package:savefood/data/model/food_model.dart';
import 'package:savefood/core/configs/theme/app_color.dart';
import '../../../data/services/cart_service.dart';
import '../../../domain/models/cart_item.dart';

class FoodDetailPage extends StatefulWidget {
  final FoodModel food;

  const FoodDetailPage({
    Key? key,
    required this.food,
  }) : super(key: key);

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  int _quantity = 0;
  final CartService _cartService = CartService();

  String _formatNumber(num value) {
    final digits = value.toStringAsFixed(0);
    final parts = <String>[];
    int counter = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      parts.add(digits[i]);
      counter++;
      if (counter % 3 == 0 && i != 0) {
        parts.add('.');
      }
    }
    return parts.reversed.join();
  }

  String _formatPrice(num value) => '${_formatNumber(value)}đ';

  void _addToCart() async {
    if (_quantity <= 0) return;

    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: widget.food.id,
      name: widget.food.name,
      price: widget.food.price,
      quantity: _quantity,
      imageUrl: widget.food.imageUrl,
      description: widget.food.description,
    );

    await _cartService.addItem(cartItem);

    // Reset quantity
    setState(() {
      _quantity = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFoodInfo(),
                _buildExpirationDate(),
                _buildDescription(),
                _buildStoreInfo(),
                _buildComments(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.food.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.fastfood, size: 96, color: Colors.grey),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.25)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.food.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    ...List.generate(5, (index) => Icon(
                      index < widget.food.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    )),
                    const SizedBox(width: 8),
                    Text('${widget.food.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
               SizedBox(
                 height: 24,
                 child: _quantity == 0
                     ? Container(
                         width: 24,
                         height: 24,
                         decoration: BoxDecoration(
                           gradient: const LinearGradient(
                             colors: [AppColor.primary, Color(0xFFA4C3A2)],
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                           ),
                           borderRadius: BorderRadius.circular(6),
                         ),
                         child: IconButton(
                           constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                           padding: EdgeInsets.zero,
                           icon: const Icon(Icons.add, size: 14, color: Colors.white),
                           onPressed: () => setState(() => _quantity = 1),
                         ),
                       )
                     : Container(
                         padding: const EdgeInsets.symmetric(horizontal: 1),
                         decoration: BoxDecoration(
                           gradient: const LinearGradient(
                             colors: [AppColor.primary, Color(0xFFA4C3A2)],
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                           ),
                           borderRadius: BorderRadius.circular(6),
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             IconButton(
                               constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                               padding: EdgeInsets.zero,
                               icon: const Icon(Icons.remove, size: 14, color: Colors.white),
                               onPressed: _quantity > 1 ? () => setState(() => _quantity--) : () => setState(() => _quantity = 0),
                             ),
                             const SizedBox(width: 1),
                             SizedBox(
                               width: 14,
                               child: Center(
                                 child: Text(
                                   '$_quantity',
                                   style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                                 ),
                               ),
                             ),
                             const SizedBox(width: 1),
                             IconButton(
                               constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                               padding: EdgeInsets.zero,
                               icon: const Icon(Icons.add, size: 10, color: Colors.white),
                               onPressed: () => setState(() => _quantity++),
                             ),
                           ],
                         ),
                       ),
               ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                _formatPrice(widget.food.price),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange),
              ),
              const SizedBox(width: 8),
              if (widget.food.discountPercentage != null)
                Text(
                  _formatPrice(widget.food.price * (1 + widget.food.discountPercentage! / 100)),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600], decoration: TextDecoration.lineThrough),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationDate() {
    final exp = widget.food.expirationDate;
    if (exp == null) {
      return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hạn sử dụng:', style: TextStyle(fontSize: 10, color: Colors.grey[700])),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.grey, size: 14),
              const SizedBox(width: 4),
              const Text('Không có thông tin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
            ],
          ),
        ],
      ),
      );
    }

    final now = DateTime.now();
    final daysLeft = exp.difference(now).inDays;

    Color statusColor;
    String statusText;
    if (daysLeft < 0) {
      statusColor = Colors.red;
      statusText = 'Đã hết hạn';
    } else if (daysLeft == 0) {
      statusColor = Colors.orange;
      statusText = 'Hết hạn hôm nay';
    } else if (daysLeft <= 3) {
      statusColor = Colors.orange;
      statusText = 'Còn $daysLeft ngày';
    } else {
      statusColor = Colors.green;
      statusText = 'Còn $daysLeft ngày';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hạn sử dụng:', style: TextStyle(fontSize: 10, color: Colors.grey[700])),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.schedule, color: statusColor, size: 14),
              const SizedBox(width: 4),
              Text('${exp.day}/${exp.month}/${exp.year}', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              const SizedBox(width: 8),
              Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
    if (widget.food.store == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cửa hàng', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.food.store!.avatar.isNotEmpty 
                      ? Image.network(
                          widget.food.store!.avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, color: Colors.grey, size: 24),
                        )
                      : const Icon(Icons.store, color: Colors.grey, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.food.store!.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${widget.food.rating}', style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                          const SizedBox(width: 8),
                          Text('• ${widget.food.deliveryTime}', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text('Mô tả sản phẩm', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(widget.food.description, style: TextStyle(fontSize: 10, color: Colors.grey[700], height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildComments() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Đánh giá', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildCommentItem('Nguyễn Văn A', 5, 'Món ăn rất ngon, đáng giá tiền. Sẽ order lại lần sau.', '2 ngày trước'),
          const SizedBox(height: 16),
          _buildCommentItem('Trần Thị B', 4, 'Ngon nhưng hơi mặn. Delivery nhanh.', '1 tuần trước'),
          const SizedBox(height: 16),
          _buildCommentItem('Lê Văn C', 5, 'Tuyệt vời! Chất lượng tốt, giá hợp lý.', '2 tuần trước'),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String name, int rating, String comment, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 20, child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 14)),
                        const SizedBox(width: 8),
                        Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment, style: TextStyle(fontSize: 10, color: Colors.grey[700], height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Cart icon with badge
            GestureDetector(
              onTap: _showCartSheet,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: Colors.black87, size: 18),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Middle: Old price (if any) + current price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.food.discountPercentage != null)
                    Text(
                      _formatPrice(widget.food.price * (1 + widget.food.discountPercentage! / 100)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                    ),
                  Text(
                    _formatPrice(widget.food.price * _quantity),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right: Add to cart button
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: _quantity > 0 ? _addToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _quantity > 0 ? Theme.of(context).colorScheme.primary : Colors.grey[400],
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                 child: Text(
                   _quantity > 0 ? 'Thanh toán' : 'Thanh toán',
                   maxLines: 1,
                   softWrap: false,
                   style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                 ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        int localQty = _quantity;
        final hasDiscount = widget.food.discountPercentage != null;
        return StatefulBuilder(
          builder: (context, setLocalState) {
            void dec() {
              if (localQty > 1) {
                setLocalState(() => localQty--);
                setState(() => _quantity = localQty);
              }
            }
            void inc() {
              setLocalState(() => localQty++);
              setState(() => _quantity = localQty);
            }

            final currentTotal = widget.food.price * localQty;
            final oldTotal = hasDiscount
                ? widget.food.price * (1 + widget.food.discountPercentage! / 100) * localQty
                : null;

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text('Xóa tất cả', style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.w400,fontSize: 8)),
                          const Spacer(),
                          const Text('Giỏ hàng', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.food.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.fastfood, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.food.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text(
                                                _formatPrice(widget.food.price),
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          height: 24,
                                          padding: const EdgeInsets.symmetric(horizontal: 1),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[300]!),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.remove, size: 12),
                                                onPressed: dec,
                                              ),
                                              const SizedBox(width: 1),
                                              SizedBox(
                                                width: 16,
                                                child: Center(
                                                  child: Text(
                                                    '$localQty',
                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 1),
                                              IconButton(
                                                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.add, size: 12),
                                                onPressed: inc,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Giá món đã bao gồm thuế, nhưng chưa bao gồm phí giao hàng và các phí khác.',
                            style: TextStyle(color: Colors.grey[500],fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatPrice(currentTotal),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'Giao hàng',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
