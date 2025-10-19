# Promotion Module

Module này chứa tất cả các thành phần liên quan đến promotion/khuyến mãi trong ứng dụng.

## Cấu trúc thư mục

```
lib/presentation/promotions/
├── cubit/
│   └── promotion_cubit.dart          # Quản lý state cho promotions
├── pages/
│   └── promotions_page.dart          # Trang hiển thị danh sách promotions
└── README.md                         # Tài liệu này

lib/data/
├── repositories/
│   ├── promotion_repository.dart     # Repository implementation cũ (để tương thích)
│   └── promotion_repository_impl.dart # Repository implementation mới theo Clean Architecture
└── services/
    └── promotion_api_service.dart    # API service riêng cho promotions

lib/domain/
├── entities/
│   └── promotion_entity.dart         # Entity cho promotion
├── repositories/
│   └── promotion_repository_interface.dart # Interface cho promotion repository
└── usecases/
    ├── get_all_promotions.dart       # Use case lấy tất cả promotions
    ├── get_active_promotions.dart    # Use case lấy promotions đang hoạt động
    └── get_promotions_by_category.dart # Use case lấy promotions theo danh mục
```

## Các tính năng

### 1. PromotionCubit
- Quản lý state cho promotions
- Hỗ trợ load tất cả promotions, active promotions, và promotions theo category
- Có mock data fallback khi API lỗi

### 2. PromotionsPage
- Trang hiển thị danh sách promotions
- Hỗ trợ filter theo category
- Layout dọc cho danh sách promotions
- Error handling và loading states

### 3. PromotionRepository
- Tách biệt hoàn toàn khỏi FoodRepository
- Có API service riêng (PromotionApiService)
- Hỗ trợ Clean Architecture với domain layer

### 4. PromoSection Widget
- Widget có thể tái sử dụng
- Hỗ trợ hiển thị ngang (trên home page) và dọc (trên promotions page)
- Có thể ẩn/hiện header

## Cách sử dụng

### Trong HomePage
```dart
PromoSection(
  promos: state.promos,
  onSeeAllTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PromotionsPage()),
    );
  },
  onPromoTap: (promo) {
    // Handle promo selection
  },
)
```

### Trong PromotionsPage
```dart
PromoSection(
  promos: [promo],
  showHeader: false,
  isVertical: true,
  onPromoTap: (selectedPromo) {
    // Handle promo selection
  },
)
```

### Sử dụng PromotionCubit
```dart
BlocProvider(
  create: (context) => PromotionCubit(),
  child: BlocBuilder<PromotionCubit, PromotionState>(
    builder: (context, state) {
      if (state is PromotionLoaded) {
        return ListView.builder(
          itemCount: state.promotions.length,
          itemBuilder: (context, index) {
            // Build promotion item
          },
        );
      }
      return CircularProgressIndicator();
    },
  ),
)
```

## Lợi ích của việc tách biệt

1. **Separation of Concerns**: Promotions có logic riêng, không phụ thuộc vào Food
2. **Maintainability**: Dễ bảo trì và phát triển tính năng promotion
3. **Reusability**: Có thể sử dụng lại ở nhiều nơi khác nhau
4. **Testability**: Dễ test riêng biệt
5. **Clean Architecture**: Tuân thủ nguyên tắc Clean Architecture
6. **Scalability**: Dễ mở rộng thêm tính năng mới cho promotions
