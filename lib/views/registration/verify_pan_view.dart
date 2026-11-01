import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/stepper_header.dart';

class VerifyPanView extends StatefulWidget {
  const VerifyPanView({super.key});

  @override
  State<VerifyPanView> createState() => _VerifyPanViewState();
}

class _VerifyPanViewState extends State<VerifyPanView> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _panController = TextEditingController();

  bool _isValidFormat = false;

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser.value;
    final existingPan = user?.pan ?? _authController.panNumber.value;
    if (existingPan.isNotEmpty && existingPan != 'ABCDE1234F') {
      _panController.text = existingPan;
      _checkFormat(existingPan);
    }
  }

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }

  void _checkFormat(String val) {
    final regex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    setState(() {
      _isValidFormat = regex.hasMatch(val.toUpperCase().trim());
    });
  }

  void _onVerify() {
    final pan = _panController.text.trim().toUpperCase();
    final regex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (pan.isEmpty || !regex.hasMatch(pan)) {
      Get.snackbar(
        'Invalid PAN Number',
        'Please enter a valid 10-character PAN (5 letters, 4 digits, 1 letter)',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }
    _authController.verifyPan(pan);
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
                            'Verify PAN Number',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

            // PAN Card Illustration (Supports direct Figma SVG or fallback vector)
            Center(
              child: _buildPanGraphic(),
            ),
            const SizedBox(height: 32),

            // Enter Your PAN Number Label
            Text(
              'Enter Your PAN Number*',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 8),

            // PAN Number Input Field
            TextField(
              controller: _panController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
              onChanged: (val) {
                _checkFormat(val);
              },
              decoration: InputDecoration(
                counterText: '',
                hintText: 'e.g., ABCDE1234F',
                suffixIcon: _isValidFormat
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.successGreen,
                        size: 22,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),

            // Helper text showing official verification standard
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 14,
                  color: _isValidFormat ? AppColors.successGreen : AppColors.textLight,
                ),
                const SizedBox(width: 6),
                Text(
                  _isValidFormat
                      ? 'Format verified. Ready for Income Tax Dept e-KYC check'
                      : 'Must be 10 characters (5 letters, 4 digits, 1 letter)',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: _isValidFormat ? AppColors.successGreen : AppColors.textGrey,
                  ),
                ),
              ],
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
                onPressed: _authController.isPanVerifying.value ? null : _onVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBlue,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _authController.isPanVerifying.value
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

  Widget _buildPanGraphic() {
    // Use the exact Figma-exported SVG for the PAN card illustration
    return SvgPicture.asset(
      'assets/icons/pan.svg',
      width: 200,
      height: 150,
      fit: BoxFit.contain,
    );
  }
}

