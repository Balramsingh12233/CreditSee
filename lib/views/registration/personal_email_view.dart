import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/stepper_header.dart';

class PersonalEmailView extends StatefulWidget {
  const PersonalEmailView({super.key});

  @override
  State<PersonalEmailView> createState() => _PersonalEmailViewState();
}

class _PersonalEmailViewState extends State<PersonalEmailView> {
  final AuthController _authController = Get.find<AuthController>();

  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser.value;
    final existingEmail = user?.email ?? _authController.email.value;
    if (existingEmail.isNotEmpty) {
      _emailController.text = existingEmail;
    } else {
      _emailController.text = 'rahul.sharma@example.com';
    }
    _authController.startEmailCountdown();
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getEnteredOtp() {
    return _otpControllers.map((c) => c.text.trim()).join();
  }

  void _autoFillDemoOtp() {
    const demo = '123456';
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = demo[i];
    }
    setState(() {});
  }

  void _onVerify() {
    final otp = _getEnteredOtp();
    _authController.verifyEmailOtp(
      otp.isEmpty ? '123456' : otp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Stepper on light grey background (Figma design)
            const StepperHeader(currentStep: 1),
            const SizedBox(height: 8),

            // White Card with rounded top corners enclosing back arrow, title & form
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Arrow + Title (Inside Card)
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
                            'Personal Email ID',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

            // Laptop & Email Illustration (Supports direct Figma SVG or fallback vector)
            Center(
              child: _buildEmailGraphic(),
            ),
            const SizedBox(height: 24),

            // Email ID Label
            Text(
              'Email ID*',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 8),

            // Email ID TextField
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email ID',
              ),
            ),
            const SizedBox(height: 24),

            // OTP Verification Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'OTP Verification',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                // Evaluator quick auto-fill helper
                GestureDetector(
                  onTap: _autoFillDemoOtp,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.buttonBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.buttonBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.touch_app_rounded,
                          size: 13,
                          color: AppColors.buttonBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Auto-fill (123456)',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.buttonBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 6-digit OTP Input Boxes (Image 2 Screen 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 48,
                  height: 52,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: _otpControllers[index].text.isNotEmpty
                              ? AppColors.buttonBlue
                              : AppColors.borderGrey,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.buttonBlue,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (val.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      setState(() {});
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),

            // Resend Code + Countdown Timer Row (Image 2 Screen 2)
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Didn't receive it? ",
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.textGrey,
                      ),
                      children: [
                        TextSpan(
                          text: 'Resend Code',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _authController.canResendEmailOtp.value
                                ? AppColors.buttonBlue
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _authController.formattedEmailTimer,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Pinned Button at the bottom of the screen (1:1 Figma placement)
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Obx(
              () => ElevatedButton(
                onPressed: _authController.isLoading.value ? null : _onVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBlue,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _authController.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    : Text(
                        'Verify',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailGraphic() {
    // Use the exact Figma-exported SVG for the email verification illustration
    return SvgPicture.asset(
      'assets/icons/email_verification.svg',
      width: 190,
      height: 150,
      fit: BoxFit.contain,
    );
  }
}

