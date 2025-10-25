import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookService {
  static Future<void> initialize() async {
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
  }
}
