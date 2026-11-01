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

  final List<String> _stepTitles = [
    'Application Submitted',
    'Application under Review',
    'E-KYC',
    'E-Nach',
    'E-Sign',
    'Disbursement',
  ];

  @override
  void initState() {
    super.initState();
    _loanController.refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Stepper on light grey background (Step 3: Approval) ──
            const StepperHeader(currentStep: 3),
            const SizedBox(height: 8),

            // ── White Card with rounded top corners (1:1 Figma wireframe) ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Arrow + Title
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
                          Expanded(
                            child: GestureDetector(
                              onLongPress: () => DemoStatusSheet.show(context),
                              child: Text(
                                'Application Status',
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                          // Subtle discrete icon to access demo status simulator
                          GestureDetector(
                            onTap: () => DemoStatusSheet.show(context),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Subtitle: Loan application no. #CS12323
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: Obx(
                          () => RichText(
                            text: TextSpan(
                              text: 'Loan application no. ',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textGrey,
                              ),
                              children: [
                                TextSpan(
                                  text: _loanController.applicationId.value.isNotEmpty
                                      ? _loanController.applicationId.value
                                      : '#CS12323',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // ── Connected Step Cards List (1:1 Figma Design) ──
                      Obx(
                        () {
                          final activeStep = _loanController.currentStep.value;

                          return Column(
                            children: List.generate(_stepTitles.length, (index) {
                              final stepNum = index + 1;
                              final title = _stepTitles[index];

                              final isDone = activeStep > stepNum;
                              final isCurrent = activeStep == stepNum;

                              Color connectorColor = const Color(0xFFCBD5E1);
                              if (isDone) {
                                connectorColor = const Color(0xFF00B074);
                              } else if (isCurrent) {
                                connectorColor = const Color(0xFF0075FF);
                              }

                              return Column(
                                children: [
                                  _buildStepCard(
                                    stepNum: stepNum,
                                    title: title,
                                    activeStep: activeStep,
                                  ),
                                  if (index < _stepTitles.length - 1)
                                    Center(
                                      child: Container(
                                        width: 1.5,
                                        height: 10,
                                        color: connectorColor,
                                      ),
                                    ),
                                ],
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // ── Bottom Review Status Section (1:1 Figma Matching) ──
                      Center(
                        child: SvgPicture.asset(
                          'assets/icons/in_review.svg',
                          width: 60,
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Application Under Review',
                          style: GoogleFonts.outfit(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "We're carefully reviewing your application to ensure\neverything is in order. Thank you for your patience.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textGrey,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Pinned Continue Button at screen bottom ──
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: ElevatedButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.homeDashboard);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBlue,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
      ),
    );
  }

  // 1:1 Figma Step Card
  // • White background for all states
  // • Icon on far-left side (calendar icon)
  // • Title perfectly centered
  Widget _buildStepCard({
    required int stepNum,
    required String title,
    required int activeStep,
  }) {
    final isDone = activeStep > stepNum;
    final isCurrent = activeStep == stepNum;

    Color borderColor = const Color(0xFF94A3B8); // Default grey border
    Color textColor = const Color(0xFF64748B);   // Default grey text
    Color iconColor = const Color(0xFF64748B);   // Default grey icon

    if (isDone) {
      borderColor = const Color(0xFF00B074);    // Green border
      textColor = const Color(0xFF00B074);      // Green text
      iconColor = const Color(0xFF00B074);      // Green icon
    } else if (isCurrent) {
      borderColor = const Color(0xFF0075FF);    // Blue border
      textColor = const Color(0xFF0075FF);      // Blue text
      iconColor = const Color(0xFF0075FF);      // Blue icon
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: isCurrent || isDone ? 1.6 : 1.2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Icon strictly pinned to the far left edge
          Positioned(
            left: 14,
            child: Icon(
              isDone ? Icons.event_available_outlined : Icons.event_note_outlined,
              color: iconColor,
              size: 22,
            ),
          ),
          // Title strictly in the horizontal center of the button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: isCurrent || isDone ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
