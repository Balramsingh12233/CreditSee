import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// CreditSea Push Notification Service
/// Handles all local push notifications for loan status updates,
/// repayment reminders, and credit score changes.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ─── Notification Channel IDs ───────────────────────────────────────────────
  static const String _loanStatusChannelId = 'creditsea_loan_status';
  static const String _repaymentChannelId = 'creditsea_repayment';
  static const String _creditScoreChannelId = 'creditsea_credit_score';

  /// Initialize the notification service (call in main.dart)
  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on Android 13+
    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Navigate based on payload
    final payload = response.payload ?? '';
    if (payload.startsWith('loan_status')) {
      Get.toNamed('/application-status');
    } else if (payload.startsWith('repayment')) {
      Get.toNamed('/application-status');
    } else if (payload.startsWith('credit_score')) {
      // Stay on dashboard / credit score section
    }
  }

  // ─── LOAN STATUS NOTIFICATIONS ──────────────────────────────────────────────

  /// Called whenever loan step changes (1-6)
  static Future<void> showLoanStatusNotification({
    required int step,
    required String status,
    required String applicationId,
  }) async {
    final (title, body, icon) = _getLoanStatusContent(step, applicationId);

    await _show(
      id: 1000 + step,
      title: title,
      body: body,
      channelId: _loanStatusChannelId,
      channelName: 'Loan Status Updates',
      channelDesc: 'Notifications for your loan application progress',
      importance: Importance.high,
      priority: Priority.high,
      payload: 'loan_status_$applicationId',
      largeIcon: icon,
      color: _getStatusColor(step),
    );
  }

  static (String, String, String) _getLoanStatusContent(
      int step, String appId) {
    switch (step) {
      case 1:
        return (
          '✅ Application Submitted',
          'Your loan application $appId has been submitted successfully.',
          'submitted'
        );
      case 2:
        return (
          '🔍 Application Under Review',
          'We\'re reviewing your application $appId. You\'ll hear from us soon!',
          'review'
        );
      case 3:
        return (
          '🪪 E-KYC Completed',
          'Identity verification successful for $appId. Moving to next step.',
          'kyc'
        );
      case 4:
        return (
          '🏦 E-Nach Activated',
          'Auto-debit mandate setup complete for $appId.',
          'nach'
        );
      case 5:
        return (
          '✍️ Loan Agreement Signed',
          'E-Sign complete! Your loan $appId is almost disbursed.',
          'sign'
        );
      case 6:
        return (
          '💰 Loan Disbursed! 🎉',
          'Congratulations! Loan amount for $appId has been credited to your account.',
          'disbursed'
        );
      case 7:
        return (
          '🏆 Loan Repaid Successfully!',
          'You\'ve repaid loan $appId in full. Your credit score has improved!',
          'repaid'
        );
      default:
        return ('CreditSea Update', 'Check your loan status.', 'default');
    }
  }

  static Color _getStatusColor(int step) {
    if (step == 6 || step == 7) return const Color(0xFF00B074);
    if (step >= 3) return const Color(0xFF0075FF);
    return const Color(0xFF0066FF);
  }

  // ─── REPAYMENT NOTIFICATIONS ─────────────────────────────────────────────────

  /// Show repayment reminder (e.g., 3 days before due)
  static Future<void> showRepaymentReminder({
    required String applicationId,
    required double amount,
    required String dueDate,
    required int daysLeft,
  }) async {
    final amountStr = '₹${amount.toStringAsFixed(0)}';
    await _show(
      id: 2000,
      title: daysLeft == 0
          ? '⚠️ EMI Due Today!'
          : '📅 EMI Due in $daysLeft Day${daysLeft == 1 ? '' : 's'}',
      body: 'Your EMI of $amountStr for $applicationId is due on $dueDate. Pay on time to boost your credit score!',
      channelId: _repaymentChannelId,
      channelName: 'Repayment Reminders',
      channelDesc: 'EMI due date reminders',
      importance: daysLeft == 0 ? Importance.max : Importance.high,
      priority: daysLeft == 0 ? Priority.max : Priority.high,
      payload: 'repayment_$applicationId',
      color: daysLeft == 0
          ? const Color(0xFFE53E3E)
          : const Color(0xFFFF8C00),
    );
  }

  /// Show repayment success notification
  static Future<void> showRepaymentSuccess({
    required String applicationId,
    required double amount,
    required int creditScoreIncrease,
    required int newScore,
  }) async {
    final amountStr = '₹${amount.toStringAsFixed(0)}';
    await _show(
      id: 2001,
      title: '🎉 Repayment Successful!',
      body:
          '$amountStr repaid for $applicationId ✓ | Your credit score increased by +$creditScoreIncrease points → $newScore',
      channelId: _repaymentChannelId,
      channelName: 'Repayment Reminders',
      channelDesc: 'EMI due date reminders',
      importance: Importance.high,
      priority: Priority.high,
      payload: 'repayment_success_$applicationId',
      color: const Color(0xFF00B074),
    );
  }

  // ─── CREDIT SCORE NOTIFICATIONS ─────────────────────────────────────────────

  static Future<void> showCreditScoreUpdate({
    required int oldScore,
    required int newScore,
    required String reason,
  }) async {
    final diff = newScore - oldScore;
    final isIncrease = diff > 0;
    await _show(
      id: 3000,
      title: isIncrease
          ? '📈 Credit Score Improved! +$diff'
          : '📉 Credit Score Changed: $diff',
      body:
          'Your CIBIL score: $oldScore → $newScore | Reason: $reason | ${_getCreditCategory(newScore)}',
      channelId: _creditScoreChannelId,
      channelName: 'Credit Score Alerts',
      channelDesc: 'Alerts when your credit score changes',
      importance: Importance.high,
      priority: Priority.high,
      payload: 'credit_score_update',
      color: isIncrease ? const Color(0xFF00B074) : const Color(0xFFE53E3E),
    );
  }

  static String _getCreditCategory(int score) {
    if (score >= 800) return 'Category: Excellent ⭐⭐⭐';
    if (score >= 750) return 'Category: Very Good ⭐⭐';
    if (score >= 700) return 'Category: Good ⭐';
    if (score >= 650) return 'Category: Fair';
    return 'Category: Needs Improvement';
  }

  // ─── CORE SHOW HELPER ────────────────────────────────────────────────────────

  static Future<void> _show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required String channelDesc,
    required Importance importance,
    required Priority priority,
    String? payload,
    String? largeIcon,
    Color color = const Color(0xFF0066FF),
  }) async {
    if (!_initialized) await init();

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: importance,
      priority: priority,
      color: color,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body),
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _plugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      // Silently fail if notifications not permitted
      debugPrint('Notification failed: $e');
    }
  }

  /// Cancel all active notifications
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

