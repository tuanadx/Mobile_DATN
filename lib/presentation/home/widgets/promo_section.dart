import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savefood/core/configs/theme/app_color.dart';
import 'package:savefood/data/model/promo_model.dart';

class PromoSection extends StatefulWidget {
  final List<PromoModel> promos;
  final VoidCallback? onSeeAllTap;
  final Function(PromoModel)? onPromoTap;
  final bool showHeader;
  final bool isVertical;

  const PromoSection({
    super.key,
    required this.promos,
    this.onSeeAllTap,
    this.onPromoTap,
    this.showHeader = true,
    this.isVertical = false,
  });

  @override
  State<PromoSection> createState() => _PromoSectionState();
}

class _PromoSectionState extends State<PromoSection> {
  late PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    if (widget.promos.length <= 1) return;
    
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentIndex = (_currentIndex + 1) % widget.promos.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          if (widget.showHeader) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                const Text(
                  'Promo & Cashback',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onSeeAllTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Promo Cards
          SizedBox(
            height: widget.isVertical ? null : 160,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: widget.promos.length,
                  itemBuilder: (context, index) {
                    final promo = widget.promos[index];
                    return GestureDetector(
                      onTap: () => widget.onPromoTap?.call(promo),
                      child: Container(
                        width: widget.isVertical ? double.infinity : double.infinity,
                        height: widget.isVertical ? 120 : null,
                        margin: EdgeInsets.only(
                          left: !widget.isVertical ? 8 : 0,
                          right: !widget.isVertical ? 8 : 0,
                          bottom: widget.isVertical && index < widget.promos.length - 1 ? 16 : 0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Background image
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  promo.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [Color(0xFFFF8A65), Color(0xFFFFB74D)],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Dark overlay for readability
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  
                                  // Promo content
                                  Expanded(
                                    child: Row(
                                      children: [
                                        // Illustration placeholder
                                        const SizedBox(width: 4),
                                        const SizedBox(width: 12),
                                        
                                        // Text content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                promo.title,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'DISC ${promo.discountPercentage.toInt()}%',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                promo.validUntil,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
                ),
                
                // Page indicator overlay
                if (widget.promos.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.promos.length,
                        (indicatorIndex) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == indicatorIndex 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Bottom spacing
          const SizedBox(height: 8),
        ],
    );
  }
}
