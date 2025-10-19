import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'presentation/splash/pages/splash_screen.dart';
import 'presentation/main/pages/main_page.dart';
import 'presentation/auth/pages/login_page.dart';
import 'presentation/auth/pages/password_login_page.dart';
import 'presentation/auth/pages/otp_verification_page.dart';
import 'presentation/profile/pages/voucher_wallet_page.dart';
import 'presentation/profile/pages/payment_page.dart';
import 'presentation/profile/pages/add_card_page.dart';
import 'presentation/profile/pages/addresses_page.dart';
import 'presentation/profile/pages/add_address_page.dart';
import 'presentation/profile/pages/settings_page.dart';
import 'data/services/Auth/auth_service.dart';
import 'core/services/product_data_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Facebook SDK for web so window.FB is available
if (kIsWeb) {
  const fbAppId = String.fromEnvironment('FACEBOOK_APP_ID', defaultValue: '796925846425252');
  await FacebookAuth.i.webAndDesktopInitialize(
    appId: fbAppId,
    cookie: true,
    xfbml: true,
    version: "v18.0",
  );
}
  
  // Load thông tin đăng nhập từ local storage
  await AuthService.loadAuthData();
  
  // Preload dữ liệu quan trọng
  try {
    await ProductDataManager().preloadImportantData();
  } catch (e) {
    print('Error preloading data: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaveFood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA4C3A2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
      routes: {
        '/main': (context) => const MainPage(),
        '/login': (context) => const LoginPage(),
        '/password-login': (context) => const PasswordLoginPage(),
        '/otp-verification': (context) {
          final phoneNumber = ModalRoute.of(context)!.settings.arguments as String;
          return OtpVerificationPage(phoneNumber: phoneNumber);
        },
        '/voucher-wallet': (context) => const VoucherWalletPage(),
        '/payment': (context) => const PaymentPage(),
        '/add-card': (context) => const AddCardPage(),
        '/addresses': (context) => const AddressesPage(),
        '/add-address': (context) => const AddAddressPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
