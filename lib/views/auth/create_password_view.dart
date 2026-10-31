import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/auth_header_carousel.dart';

class CreatePasswordView extends StatefulWidget {
  const CreatePasswordView({super.key});

  @override
  State<CreatePasswordView> createState() => _CreatePasswordViewState();
}

class _CreatePasswordViewState extends State<CreatePasswordView> {
  final AuthController _authController = Get.find<AuthController>();

  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
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
                    // Top Blue Section with Carousel (Screen 4: 24x7 Customer Care)
                    const AuthHeaderCarousel(initialPage: 2),

                    // Bottom White Card — Expanded fills remaining height (no blue gap)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                            // Back Arrow + Title Row
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
                                      'Create a password',
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
                            const SizedBox(height: 24),

                            // Enter Password Label
                            Text(
                              'Enter password',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMedium,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Enter Password Field
                            TextField(
                              controller: _passController,
                              obscureText: _obscurePass,
                              decoration: InputDecoration(
                                hintText: 'Enter password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePass
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textLight,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePass = !_obscurePass);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Re-enter Password Label
                            Text(
                              'Re enter password',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMedium,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Re-enter Password Field
                            TextField(
                              controller: _confirmPassController,
                              obscureText: _obscureConfirmPass,
                              decoration: InputDecoration(
                                hintText: 'Re enter password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPass
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textLight,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscureConfirmPass = !_obscureConfirmPass);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Password Criteria Note
                            Text(
                              '*your password must include at least 8 characters, inclusive of at least 1 special character',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: AppColors.textGrey,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Proceed Button
                            Obx(
                              () => ElevatedButton(
                                onPressed: _authController.isLoading.value
                                    ? null
                                    : () {
                                        final p1 = _passController.text.trim();
                                        final p2 = _confirmPassController.text.trim();
                                        _authController.createPasswordAndProceed(
                                          p1.isEmpty ? 'CreditSea@123' : p1,
                                          p2.isEmpty ? 'CreditSea@123' : p2,
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
                                        'Proceed',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
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
