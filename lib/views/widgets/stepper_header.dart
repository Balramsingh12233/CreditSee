import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class StepperHeader extends StatelessWidget {
  final int currentStep; // 1: Register, 2: Offer, 3: Approval

  const StepperHeader({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(stepNum: 1, label: 'Register'),
          _buildDivider(stepNum: 1),
          _buildStepItem(stepNum: 2, label: 'Offer'),
          _buildDivider(stepNum: 2),
          _buildStepItem(stepNum: 3, label: 'Approval'),
        ],
      ),
    );
  }

  Widget _buildStepItem({required int stepNum, required String label}) {
    final isActive = currentStep == stepNum;
    final isDone = currentStep > stepNum;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isActive ? AppColors.buttonBlue : (isDone ? AppColors.buttonBlue.withValues(alpha: 0.1) : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive || isDone ? AppColors.buttonBlue : AppColors.textLight,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 13, color: AppColors.buttonBlue)
                : Text(
                    '$stepNum',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppColors.textGrey,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppColors.buttonBlue : AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider({required int stepNum}) {
    final isPassed = currentStep > stepNum;
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isPassed ? AppColors.buttonBlue : AppColors.borderGrey,
      ),
    );
  }
}
