import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/loan_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../widgets/demo_status_sheet.dart';
import '../widgets/stepper_header.dart';

class ApplicationStatusView extends StatefulWidget {
  const ApplicationStatusView({super.key});

  @override
  State<ApplicationStatusView> createState() => _ApplicationStatusViewState();
}

class _ApplicationStatusViewState extends State<ApplicationStatusView> {
  final LoanController _loanController = Get.find<LoanController>();

  final List<Map<String, dynamic>> _steps = [
    {
      'step': 1,
      'title': 'Application Submitted',
      'icon': Icons.description_outlined,
    },
    {
      'step': 2,
      'title': 'Application under Review',
      'icon': Icons.date_range_outlined,
    },
    {
      'step': 3,
      'title': 'E-KYC',
      'icon': Icons.badge_outlined,
    },
    {
      'step': 4,
      'title': 'E-Nach',
      'icon': Icons.account_balance_outlined,
    },
    {
      'step': 5,
      'title': 'E-Sign',
      'icon': Icons.draw_outlined,
    },
    {
      'step': 6,
      'title': 'Disbursement',
      'icon': Icons.payments_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loanController.refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: SafeArea(
          child: StepperHeader(currentStep: 3), // Step 3: Approval
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => DemoStatusSheet.show(context),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
        label: Text(
          'Demo Controls',
          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Arrow + Title (Screen 13)
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textDark,
                      size: 24,
                    ),
                  ),
                ),
                Text(
                  'Application Status',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Subtitle: Loan application no. #CS12323
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Obx(
                () => Text(
                  'Loan application no. ${_loanController.applicationId.value}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Vertical Step Cards - Centered buttons matching Figma request
            Obx(
              () => Column(
                children: _steps.map((s) {
                  final stepNum = s['step'] as int;
                  final title = s['title'] as String;
                  final icon = s['icon'] as IconData;
                  final activeStep = _loanController.currentStep.value;

                  return _buildStepCard(
                    stepNum: stepNum,
                    title: title,
                    icon: icon,
                    activeStep: activeStep,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Application Under Review Status Message Card (Screen 13 bottom)
            Obx(
              () => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.calcCardBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/in_review.svg',
                          width: 34,
                          height: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _loanController.currentStatus.value == 'Disbursed'
                          ? 'Loan Disbursed 🎉'
                          : (_loanController.currentStatus.value == 'Repaid'
                              ? 'Loan Closed & Upgraded'
                              : 'Application Under Review'),
                      style: GoogleFonts.outfit(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _loanController.statusMessage.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // Pinned Continue Button at screen bottom
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(
            onPressed: () {
              Get.offAllNamed(AppRoutes.homeDashboard);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBlue,
              minimumSize: const Size.fromHeight(50),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Centered step button matching user requirement & Figma
  Widget _buildStepCard({
    required int stepNum,
    required String title,
    required IconData icon,
    required int activeStep,
  }) {
    final isDone = activeStep > stepNum;
    final isCurrent = activeStep == stepNum;

    Color borderColor = AppColors.borderGrey;
    Color textColor = AppColors.textGrey;
    Color iconColor = AppColors.textLight;
    Color bgColor = Colors.white;

    if (isDone) {
      borderColor = AppColors.successGreen;
      textColor = AppColors.successGreen;
      iconColor = AppColors.successGreen;
      bgColor = AppColors.successBg.withValues(alpha: 0.3);
    } else if (isCurrent) {
      borderColor = AppColors.buttonBlue;
      textColor = AppColors.buttonBlue;
      iconColor = AppColors.buttonBlue;
      bgColor = AppColors.calcCardBg.withValues(alpha: 0.4);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: isCurrent || isDone ? 1.5 : 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (stepNum == 2 && isCurrent)
            SvgPicture.asset(
              'assets/icons/in_review.svg',
              width: 20,
              height: 20,
            )
          else
            Icon(
              isDone ? Icons.check_circle_outline_rounded : icon,
              color: iconColor,
              size: 20,
            ),
          const SizedBox(width: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isCurrent || isDone ? FontWeight.w600 : FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
