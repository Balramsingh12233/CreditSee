import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (existingPan.isNotEmpty) {
      _panController.text = existingPan;
      _checkFormat(existingPan);
    } else {
      _panController.text = 'ABCDE1234F';
      _checkFormat('ABCDE1234F');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: SafeArea(
          child: StepperHeader(currentStep: 1), // Step 1: Register
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Arrow + Title (Image 2 Screen 3)
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

            // PAN Card Illustration (Pixel-perfect Figma illustration matching Image 2 Screen 3)
            Center(
              child: _buildPanCardIllustration(),
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
            const SizedBox(height: 40),

            // Verify Button (Blue full-width CTA)
            Obx(
              () => ElevatedButton(
                onPressed: _authController.isPanVerifying.value
                    ? null
                    : () {
                        final pan = _panController.text.trim();
                        _authController.verifyPan(
                          pan.isEmpty ? 'ABCDE1234F' : pan,
                        );
                      },
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Vector illustration matching the blue card on soft background in Image 2 Screen 3
  Widget _buildPanCardIllustration() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FD),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft cloud backdrop shape
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 140,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE2EDFC),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          // Floating Credit / PAN Card in Royal Blue
          Container(
            width: 155,
            height: 98,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF004DC9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0066FF).withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Metallic EMV Chip + Logo indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Metallic Chip
                    Container(
                      width: 22,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCD34D),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: const Color(0xFFF59E0B),
                          width: 1,
                        ),
                      ),
                    ),
                    // Contactless emblem
                    Icon(
                      Icons.contactless_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ],
                ),

                // Card Number Stripes placeholder
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 20,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

