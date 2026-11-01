import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/loan_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class DemoStatusSheet {
  static void show(BuildContext context) {
    final loanController = Get.find<LoanController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Evaluator Demo Controls',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Live Demo Mode',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Simulate backend status progression to evaluate tracking screen:',
                style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatusChip(ctx, loanController, 1, '1. Submitted'),
                  _buildStatusChip(ctx, loanController, 2, '2. Under Review'),
                  _buildStatusChip(ctx, loanController, 3, '3. E-KYC Done'),
                  _buildStatusChip(ctx, loanController, 4, '4. E-Nach Done'),
                  _buildStatusChip(ctx, loanController, 5, '5. E-Sign Done'),
                  _buildStatusChip(ctx, loanController, 6, '6. Disbursed 🎉'),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Get.toNamed(AppRoutes.repayment);
                },
                icon: const Icon(Icons.payment_rounded, color: Colors.white),
                label: const Text('Open Razorpay / UPI Repayment Screen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  minimumSize: const Size.fromHeight(46),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildStatusChip(
    BuildContext context,
    LoanController controller,
    int step,
    String label,
  ) {
    return Obx(() {
      final isSelected = controller.currentStep.value == step;
      return ActionChip(
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        backgroundColor: isSelected ? AppColors.buttonBlue : Colors.grey.shade100,
        side: BorderSide(
          color: isSelected ? AppColors.buttonBlue : Colors.grey.shade300,
        ),
        onPressed: () {
          Navigator.pop(context);
          controller.setDemoStep(step);
        },
      );
    });
  }
}
