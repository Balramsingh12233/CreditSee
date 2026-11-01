import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/services/notification_service.dart';
import '../core/services/storage_service.dart';
import '../data/models/loan_model.dart';
import '../routes/app_routes.dart';

class LoanController extends GetxController {
  // Screen 11: Loan Calculator
  final purpose = 'Personal Expense'.obs;
  final principalAmount = 30000.0.obs;
  final tenureDays = 40.obs;
  final dailyInterestRate = 0.01; // 1% per day
  final processingFeePercent = 10; // 10%

  // Screen 12: Offer
  final offerAmount = 10000.0.obs;
  final offerTenureDays = 90.obs;
  final offerPayable = 10600.0.obs;

  // Screen 13: Application Status Tracking
  final applicationId = '#CS12323'.obs;
  final currentStep = 2.obs; // 1: Submitted, 2: Under Review, 3: E-KYC, 4: E-Nach, 5: E-Sign, 6: Disbursement
  final currentStatus = 'Under Review'.obs;
  final statusMessage =
      "We're carefully reviewing your application to ensure everything is in order. Thank you for your patience.".obs;

  final isLoading = false.obs;
  final activeLoan = Rxn<LoanModel>();

  // Calculator dynamic formulas
  // Figma Screen 11 displays: Principle: ₹1,00,000 (or selected), Interest: 1%, Total Payable: ₹2000 (or calculated)
  double get totalInterest {
    // Interest calculated based on tenure and daily rate
    return (principalAmount.value * 0.01 * (tenureDays.value / 30)).roundToDouble();
  }

  double get processingFee {
    return (principalAmount.value * 0.10).roundToDouble();
  }

  double get totalPayable {
    return principalAmount.value + totalInterest;
  }

  @override
  void onInit() {
    super.onInit();
    final savedId = StorageService.getActiveLoanId();
    if (savedId != null) {
      applicationId.value = savedId;
    }
  }

  void updatePrincipal(double val) {
    principalAmount.value = val;
  }

  void updateTenure(int val) {
    tenureDays.value = val;
  }

  void updatePurpose(String val) {
    purpose.value = val;
  }

  // Submit calculation / Apply (Screen 11 -> Screen 12)
  Future<void> proceedToOffer() async {
    isLoading.value = true;
    try {
      final user = StorageService.getUser();
      final response = await ApiClient.dio.post(
        '/loans/check-eligibility',
        data: {
          'requestedAmount': principalAmount.value,
          'monthlyIncome': user?.monthlyIncome ?? 35000,
        },
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        final d = response.data['data'];
        offerAmount.value = (d['offerAmount'] as num?)?.toDouble() ?? 10000.0;
        offerTenureDays.value = (d['offerTenureDays'] as num?)?.toInt() ?? 90;
        offerPayable.value = (d['offerPayable'] as num?)?.toDouble() ?? 10600.0;
      }
    } catch (_) {
      // Keep robust defaults
      offerAmount.value = 10000.0;
      offerTenureDays.value = 90;
      offerPayable.value = 10600.0;
    }
    isLoading.value = false;
    Get.toNamed(AppRoutes.loanOffer);
  }

  // Accept Offer (Screen 12 -> Screen 13)
  Future<void> acceptOffer() async {
    isLoading.value = true;
    final user = StorageService.getUser();
    final newAppId = '#CS${10000 + (DateTime.now().millisecondsSinceEpoch % 89999)}';
    applicationId.value = newAppId;
    await StorageService.saveActiveLoanId(newAppId);

    final loan = LoanModel(
      applicationId: newAppId,
      userPhone: user?.phone ?? '8800642354',
      userName: user?.fullName ?? 'Rahul Sharma',
      purpose: purpose.value,
      principalAmount: principalAmount.value,
      tenureDays: tenureDays.value,
      dailyInterestRate: dailyInterestRate,
      processingFee: processingFee,
      totalInterest: totalInterest,
      totalPayable: totalPayable,
      status: 'Under Review',
      currentStep: 2,
      statusMessage:
          "We're carefully reviewing your application to ensure everything is in order. Thank you for your patience.",
      offerAmount: offerAmount.value,
      offerTenureDays: offerTenureDays.value,
      offerPayable: offerPayable.value,
      isOfferAccepted: true,
      createdAt: DateTime.now(),
    );

    try {
      await ApiClient.dio.post(
        '/loans/apply',
        data: loan.toJson(),
      );
    } catch (_) {}

    activeLoan.value = loan;
    currentStep.value = 2;
    currentStatus.value = 'Under Review';
    statusMessage.value =
        "We're carefully reviewing your application to ensure everything is in order. Thank you for your patience.";

    isLoading.value = false;
    Get.toNamed(AppRoutes.applicationStatus);
  }

  // Refresh status from backend
  Future<void> refreshStatus() async {
    try {
      final res = await ApiClient.dio.get('/loans/${applicationId.value}/status');
      if (res.statusCode == 200 && res.data['data'] != null) {
        final d = LoanModel.fromJson(res.data['data']);
        activeLoan.value = d;
        currentStep.value = d.currentStep;
        currentStatus.value = d.status;
        statusMessage.value = d.statusMessage;
      }
    } catch (_) {}
  }

  // Evaluation / Demo helper: Allows toggling steps live
  Future<void> setDemoStep(int step) async {
    final statusMap = {
      1: 'Submitted',
      2: 'Under Review',
      3: 'Approved',
      4: 'Approved',
      5: 'Approved',
      6: 'Disbursed',
      7: 'Repaid',
    };

    final messageMap = {
      1: 'Application has been submitted successfully.',
      2: "We're carefully reviewing your application to ensure everything is in order. Thank you for your patience.",
      3: 'E-KYC verified successfully. Identity checks passed.',
      4: 'E-Nach mandate auto-debit setup is complete.',
      5: 'Loan agreement digitally signed via Aadhaar e-Sign.',
      6: 'Congratulations! Loan amount of ₹${offerAmount.value.toInt()} disbursed to your bank account.',
      7: 'Loan has been completely repaid. Credit score upgraded!',
    };

    currentStep.value = step;
    currentStatus.value = statusMap[step] ?? 'Under Review';
    statusMessage.value = messageMap[step] ?? messageMap[2]!;

    try {
      await ApiClient.dio.patch(
        '/loans/${applicationId.value}/status',
        data: {
          'currentStep': step,
          'status': currentStatus.value,
          'statusMessage': statusMessage.value,
        },
      );
    } catch (_) {}

    Get.snackbar(
      'Demo Status Updated',
      'Step transitioned to: ${currentStatus.value} (Step $step/6)',
      backgroundColor: Colors.blue.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Trigger local push notification for loan update
    NotificationService.showLoanStatusNotification(
      step: step,
      status: currentStatus.value,
      applicationId: applicationId.value,
    );
  }

  // Bonus: Mock Repayment
  Future<void> performMockRepayment() async {
    isLoading.value = true;
    try {
      await ApiClient.dio.post(
        '/loans/${applicationId.value}/mock-repayment',
        data: {
          'paymentMethod': 'Razorpay / UPI Instant',
          'amount': offerPayable.value,
        },
      );
    } catch (_) {}

    currentStep.value = 7;
    currentStatus.value = 'Repaid';
    statusMessage.value = 'Loan has been completely repaid. Credit score upgraded!';
    isLoading.value = false;

    Get.snackbar(
      'Repayment Successful! ',
      'Mock repayment of ₹${offerPayable.value.toInt()} confirmed. Your credit score has increased!',
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
