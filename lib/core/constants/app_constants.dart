import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static const String appName = 'CreditSea';
  static const String appTagline = 'Instant, Flexible, Trusted Loans';

  // Base API URL (Live Render Deployed Backend)
  static String get defaultBaseUrl {
    return 'https://creditsee.onrender.com/api';
  }

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'user_data';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyActiveLoanId = 'active_loan_id';
  static const String keyBaseUrl = 'custom_base_url';

  // Demo Fallback Flag
  static const bool enableOfflineFallback = true;
}
