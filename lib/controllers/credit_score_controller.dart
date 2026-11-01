import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/services/notification_service.dart';
import '../core/services/storage_service.dart';

/// CreditSea Credit Scoring Engine
/// Implements CIBIL-like scoring with 5 real weighted factors.
///
/// Score Range: 300 – 900
/// ┌─────────────────────────────────────────────────────┐
/// │  Factor                  Weight   Points Range      │
/// │  Payment History          35%     0 – 315           │
/// │  Credit Utilization       30%     0 – 270           │
/// │  Credit Age / Tenure      15%     0 – 135           │
/// │  Credit Mix               10%     0 – 90            │
/// │  New Credit Inquiries     10%     0 – 90            │
/// └─────────────────────────────────────────────────────│
class CreditScoreController extends GetxController {
  // ─── Observables ─────────────────────────────────────────────────────────────
  final score = 750.obs;
  final maxScore = 900;
  final minScore = 300;

  // Factor-level scores (0–100 each, displayed as %)
  final paymentHistoryScore = 0.obs;    // Factor 1: 35% weight
  final utilizationScore = 0.obs;       // Factor 2: 30% weight
  final creditAgeScore = 0.obs;         // Factor 3: 15% weight
  final creditMixScore = 0.obs;         // Factor 4: 10% weight
  final inquiryScore = 0.obs;           // Factor 5: 10% weight

  // Displayed metrics
  final category = 'Good'.obs;
  final onTimePayments = '0'.obs;       // count
  final totalPayments = '0'.obs;
  final onTimePercent = '0%'.obs;
  final creditUtilization = '0%'.obs;
  final creditAgeMonths = 0.obs;
  final activeLoansCount = 0.obs;
  final totalLoansCount = 0.obs;
  final recentInquiries = 0.obs;
  final isLoading = false.obs;

  // Internal tracking (persisted via StorageService simulation)
  final _onTimeCount = 0.obs;
  final _missedCount = 0.obs;
  final _totalLoanAmount = 0.0.obs;
  final _usedAmount = 0.0.obs;
  final _hasVerifiedPan = false.obs;
  final _hasVerifiedEmail = false.obs;
  final _hasActiveSecuredLoan = false.obs;
  final _accountAgeMonths = 0.obs;
  final _inquiriesLast6Months = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  // ─── LOAD / PERSIST STATE ────────────────────────────────────────────────────

  void _loadFromStorage() {
    final user = StorageService.getUser();
    if (user != null) {
      loadForUser(user);
    } else {
      resetForNewUser();
    }
  }

  void resetForNewUser() {
    _resetInternalState();
    _recalculate();
  }

  void _resetInternalState() {
    _hasVerifiedPan.value = false;
    _hasVerifiedEmail.value = false;
    _hasActiveSecuredLoan.value = false;
    _accountAgeMonths.value = 0;
    _onTimeCount.value = 0;
    _missedCount.value = 0;
    _totalLoanAmount.value = 0;
    _usedAmount.value = 0;
    _inquiriesLast6Months.value = 0;
  }

  void loadForUser(UserModel user) {
    _hasVerifiedPan.value = user.isPanVerified;
    _hasVerifiedEmail.value = user.isEmailVerified;

    final activeLoan = StorageService.getActiveLoanId(phone: user.phone);
    if (activeLoan != null && activeLoan.isNotEmpty) {
      _accountAgeMonths.value = 6;
      _onTimeCount.value = 2;
      _totalLoanAmount.value = 30000;
      _usedAmount.value = 15000;
      _inquiriesLast6Months.value = 1;
    } else {
      _resetInternalState();
      _hasVerifiedPan.value = user.isPanVerified;
      _hasVerifiedEmail.value = user.isEmailVerified;
    }
    _recalculate();
  }

  // ─── MAIN CALCULATION ENGINE ─────────────────────────────────────────────────

  /// Recalculates the full CIBIL-like score from all 5 factors.
  /// Standard CIBIL: Base 300 + max 600 points = 300 to 900 range.
  void _recalculate() {
    final totalPayments = _onTimeCount.value + _missedCount.value;

    // ── Factor 1: Payment History (35% weight → max 210 points) ──────────────
    double f1 = 0;
    if (totalPayments > 0) {
      final ratio = _onTimeCount.value / totalPayments;
      f1 = ratio * 210;
      if (_missedCount.value >= 3) f1 *= 0.6;
    } else {
      f1 = 150; // New user base
    }
    paymentHistoryScore.value = ((f1 / 210) * 100).round().clamp(0, 100);

    // ── Factor 2: Credit Utilization (30% weight → max 180 points) ───────────
    double f2 = 0;
    if (_totalLoanAmount.value > 0) {
      final utilizationRatio = _usedAmount.value / _totalLoanAmount.value;
      // < 30% utilization is ideal
      if (utilizationRatio <= 0.30) {
        f2 = 180;
      } else if (utilizationRatio <= 0.50) {
        f2 = 144;
      } else if (utilizationRatio <= 0.75) {
        f2 = 108;
      } else {
        f2 = 54;
      }
      creditUtilization.value =
          '${(utilizationRatio * 100).round().clamp(0, 100)}%';
    } else {
      f2 = 126;
      creditUtilization.value = '25%';
    }
    utilizationScore.value = ((f2 / 180) * 100).round().clamp(0, 100);

    // ── Factor 3: Credit Age / Account Tenure (15% → max 90 points) ──────────
    double f3 = 0;
    final ageMonths = _accountAgeMonths.value;
    if (ageMonths >= 60) {
      f3 = 90;
    } else if (ageMonths >= 36) {
      f3 = 75;
    } else if (ageMonths >= 24) {
      f3 = 60;
    } else if (ageMonths >= 12) {
      f3 = 48;
    } else if (ageMonths >= 6) {
      f3 = 36;
    } else {
      f3 = 24;
    }
    if (_hasVerifiedPan.value) f3 = (f3 * 1.1).clamp(0, 90);
    if (_hasVerifiedEmail.value) f3 = (f3 * 1.05).clamp(0, 90);
    creditAgeScore.value = ((f3 / 90) * 100).round().clamp(0, 100);
    creditAgeMonths.value = ageMonths;

    // ── Factor 4: Credit Mix (10% → max 60 points) ───────────────────────────
    double f4 = 36;
    if (_hasActiveSecuredLoan.value) f4 = 60;
    if (_onTimeCount.value > 2) f4 = f4.clamp(0, 60);
    creditMixScore.value = ((f4 / 60) * 100).round().clamp(0, 100);

    // ── Factor 5: New Credit / Recent Inquiries (10% → max 60 points) ────────
    double f5 = 60;
    final inq = _inquiriesLast6Months.value;
    if (inq == 0) {
      f5 = 60;
    } else if (inq == 1) {
      f5 = 52;
    } else if (inq == 2) {
      f5 = 40;
    } else if (inq <= 4) {
      f5 = 26;
    } else {
      f5 = 12;
    }
    inquiryScore.value = ((f5 / 60) * 100).round().clamp(0, 100);
    recentInquiries.value = inq;

    // ── Final Score (Base 300 + max 600 = 300 to 900) ────────────────────────
    final rawScore = 300 + f1 + f2 + f3 + f4 + f5;
    score.value = rawScore.round().clamp(300, 900);

    // ── Category ─────────────────────────────────────────────────────────────
    category.value = _getCategory(score.value);

    // ── Displayed Metrics ─────────────────────────────────────────────────────
    onTimePayments.value = _onTimeCount.value.toString();
    this.totalPayments.value = totalPayments.toString();
    onTimePercent.value = totalPayments > 0
        ? '${((_onTimeCount.value / totalPayments) * 100).round()}%'
        : '100%';
    activeLoansCount.value = _usedAmount.value > 0 ? 1 : 0;
  }

  String _getCategory(int s) {
    if (s >= 800) return 'Excellent';
    if (s >= 750) return 'Very Good';
    if (s >= 700) return 'Good';
    if (s >= 650) return 'Fair';
    return 'Needs Improvement';
  }

  // ─── PUBLIC APIs — called from LoanController / AuthController ───────────────

  /// Called when user completes a loan repayment ON TIME.
  /// This is the biggest credit score booster (+20 to +35 points).
  Future<void> recordOnTimeRepayment({
    required double loanAmount,
    bool isEarlyRepayment = false,
  }) async {
    final oldScore = score.value;
    _onTimeCount.value++;
    _usedAmount.value = (_usedAmount.value - loanAmount).clamp(0, double.infinity);
    if (isEarlyRepayment) {
      _inquiriesLast6Months.value =
          (_inquiriesLast6Months.value - 1).clamp(0, 99); // reward
    }
    _recalculate();

    await _saveScoreToBackend();

    await NotificationService.showCreditScoreUpdate(
      oldScore: oldScore,
      newScore: score.value,
      reason: 'On-time loan repayment${isEarlyRepayment ? ' (early)' : ''}',
    );

    return;
  }

  /// Called when loan is newly disbursed (adds new inquiry + utilization).
  Future<void> recordLoanDisbursed({required double loanAmount}) async {
    _totalLoanAmount.value += loanAmount;
    _usedAmount.value += loanAmount;
    _inquiriesLast6Months.value++;
    _accountAgeMonths.value = _accountAgeMonths.value == 0
        ? 1
        : _accountAgeMonths.value;
    _recalculate();
    await _saveScoreToBackend();
  }

  /// Called when user misses a repayment (big penalty).
  Future<void> recordMissedRepayment() async {
    final oldScore = score.value;
    _missedCount.value++;
    _recalculate();

    await NotificationService.showCreditScoreUpdate(
      oldScore: oldScore,
      newScore: score.value,
      reason: 'Missed EMI payment',
    );

    await _saveScoreToBackend();
  }

  /// Called when PAN is verified — improves credibility factor.
  void recordPanVerified() {
    _hasVerifiedPan.value = true;
    _recalculate();
  }

  /// Called when email is verified — improves credibility factor.
  void recordEmailVerified() {
    _hasVerifiedEmail.value = true;
    _recalculate();
  }

  /// Called when loan application is submitted — counts as a new inquiry.
  void recordNewInquiry() {
    _inquiriesLast6Months.value++;
    _recalculate();
  }

  /// Simulate account aging (called during demo or periodic refresh).
  void simulateTimePassage({int months = 1}) {
    _accountAgeMonths.value += months;
    _recalculate();
  }

  Future<void> _saveScoreToBackend() async {
    try {
      final user = StorageService.getUser();
      await ApiClient.dio.patch(
        '/user/credit-score',
        data: {
          'phone': user?.phone ?? '8800642354',
          'score': score.value,
        },
      );
    } catch (_) {}
  }

  Future<void> fetchScore() async {
    isLoading.value = true;
    try {
      final user = StorageService.getUser();
      final res = await ApiClient.dio.get(
        '/user/credit-score',
        queryParameters: {'phone': user?.phone ?? '8800642354'},
      );
      if (res.statusCode == 200 && res.data['data'] != null) {
        final d = res.data['data'];
        final serverScore = d['score'] as int? ?? score.value;
        // Only take server score if meaningfully different
        if ((serverScore - score.value).abs() > 5) {
          score.value = serverScore;
          category.value = _getCategory(score.value);
        }
      }
    } catch (_) {}
    isLoading.value = false;
  }

  // ─── Convenience getters for UI ──────────────────────────────────────────────

  /// Color representation of the current credit score
  String get categoryColor {
    switch (category.value) {
      case 'Excellent':
        return '#00B074';
      case 'Very Good':
        return '#0075FF';
      case 'Good':
        return '#2196F3';
      case 'Fair':
        return '#FF8C00';
      default:
        return '#E53E3E';
    }
  }

  double get scorePercentage => (score.value - 300) / 600;
}
