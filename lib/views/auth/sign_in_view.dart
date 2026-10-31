import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../widgets/auth_header_carousel.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final AuthController _authController = Get.find<AuthController>();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (_authController.phoneNumber.value.isNotEmpty) {
      _phoneController.text = _authController.phoneNumber.value;
    } else {
      _phoneController.text = '8800642354';
    }
    _passController.text = 'CreditSea@123';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Top Blue Section with Carousel (Screen 5 & 8)
                    const AuthHeaderCarousel(initialPage: 2),

                    // Bottom White Card — Expanded fills remaining height (no blue gap)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Please enter your credentials',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Mobile Number Label
                            Text(
                              'Mobile Number',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMedium,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Mobile Number Row
                            Row(
                              children: [
                                Container(
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: AppColors.borderGrey, width: 1.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                      const SizedBox(width: 6),
                                      Text(
                                        '+91',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        hintText: 'Please enter your mobile no.',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 13.5,
                                          color: AppColors.textLight,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Password Label
                            Text(
                              'Enter password',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMedium,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Password Input
                            TextField(
                              controller: _passController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Enter password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textLight,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Forgot password link
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(AppRoutes.onboarding);
                                },
                                child: Text(
                                  'Forgot password?',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.buttonBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sign In Button
                            Obx(
                              () => ElevatedButton(
                                onPressed: _authController.isLoading.value
                                    ? null
                                    : () {
                                        _authController.signIn(
                                          _phoneController.text.trim(),
                                          _passController.text.trim(),
                                        );
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
                                        'Sign In',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // New to CreditSea? Create an account
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'New to CreditSea? ',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: AppColors.textGrey,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Create an account',
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        color: AppColors.buttonBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.toNamed(AppRoutes.onboarding);
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
