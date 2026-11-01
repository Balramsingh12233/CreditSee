import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/auth_header_carousel.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final AuthController _authController = Get.find<AuthController>();

  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  String _getCombinedOtp() => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          const AuthHeaderCarousel(initialPage: 1),

          // ── Bottom White Card with glowing gradient top border (Figma) ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0066FF), Color(0xFF00C9A7), Color(0xFF00E5B5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.only(top: 2.5),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back + Title
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.textDark,
                                size: 22,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Enter OTP',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 34),
                        ],
                      ),
                      const SizedBox(height: 18),

                      Center(
                        child: Obx(() => RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'Verify OTP, Sent on ',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textGrey,
                            ),
                            children: [
                              TextSpan(
                                text: '+91 ${_authController.phoneNumber.value}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        )),
                      ),
                      const SizedBox(height: 26),

                      // 4 OTP Boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) => SizedBox(
                          width: 58,
                          height: 58,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.borderGrey,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.buttonBlue,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              if (val.isNotEmpty && index < 3) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (val.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        )),
                      ),
                      const SizedBox(height: 16),

                      Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _authController.formattedTimer,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (_authController.canResendOtp.value)
                            GestureDetector(
                              onTap: () => _authController.startCountdown(),
                              child: Text(
                                'Resend OTP',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.buttonBlue,
                                ),
                              ),
                            ),
                        ],
                      )),
                      const SizedBox(height: 26),

                      Obx(() => ElevatedButton(
                        onPressed: _authController.isLoading.value
                            ? null
                            : () {
                                final otp = _getCombinedOtp();
                                if (otp.length < 4) {
                                  Get.snackbar(
                                    'Incomplete OTP',
                                    'Please enter the 4-digit verification code',
                                    backgroundColor: Colors.red.shade600,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                _authController.verifyOtp(otp);
                              },
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
                      )),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
