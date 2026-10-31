import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/loan_controller.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/stepper_header.dart';

class LoanOfferView extends StatelessWidget {
  const LoanOfferView({super.key});

  @override
  Widget build(BuildContext context) {
    final loanController = Get.find<LoanController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: const StepperHeader(currentStep: 2), // Step 2: Offer
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Title (Screen 12)
              Center(
                child: Text(
                  'Our Offerings',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Rupee Coin Graphic — exact Figma SVG
              Center(
                child: SvgPicture.asset(
                  'assets/images/coin.svg',
                  width: 120,
                  height: 120,
                ),
              ),

              const SizedBox(height: 36),

              // Congratulations Offer Text
              Obx(
                () => RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      color: AppColors.textMedium,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Congratulations! ',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.successGreen,
                        ),
                      ),
                      const TextSpan(text: 'We can offer you '),
                      TextSpan(
                        text: 'Rs. ${loanController.offerAmount.value.toInt()} ',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const TextSpan(text: 'Amount Within '),
                      TextSpan(
                        text: '30 minutes ',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      TextSpan(
                        text: 'for ${loanController.offerTenureDays.value} days, ',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const TextSpan(text: 'with a payable amount of '),
                      TextSpan(
                        text: 'Rs. ${loanController.offerPayable.value.toInt()}. ',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const TextSpan(text: 'Just with few more steps.\nProceed further to'),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Accept Offer Button (Primary)
              Obx(
                () => ElevatedButton(
                  onPressed: loanController.isLoading.value
                      ? null
                      : () {
                          loanController.acceptOffer();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBlue,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: loanController.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Accept Offer',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Extend Offer Button (Secondary)
              OutlinedButton(
                onPressed: () {
                  Get.back(); // Re-adjust in calculator
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(
                  'Extend Offer',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.buttonBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
