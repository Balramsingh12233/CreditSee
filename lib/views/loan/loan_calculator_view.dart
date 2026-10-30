import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/loan_controller.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_logo.dart';

class LoanCalculatorView extends StatefulWidget {
  const LoanCalculatorView({super.key});

  @override
  State<LoanCalculatorView> createState() => _LoanCalculatorViewState();
}

class _LoanCalculatorViewState extends State<LoanCalculatorView> {
  final LoanController _loanController = Get.find<LoanController>();

  final List<String> _loanPurposes = [
    'Personal Expense',
    'Medical Emergency',
    'Business Expansion',
    'Education & Skill',
    'Home Renovation',
    'Electronics & Appliances',
    'Debt Consolidation',
  ];

  final currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Get.back(),
        ),
        title: const AppLogo(size: 32, isVertical: false, textColor: AppColors.primaryBlue),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle (Screen 11)
            Text(
              'Apply for loan',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "We've calculated your loan eligibility. Select your preferred loan amount and tenure.",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Two Badge Chips: Interest Per Day 1% | Processing Fee 10%
            Row(
              children: [
                Expanded(
                  child: _buildDashedBadge('Interest Per Day 1%'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDashedBadge('Processing Fee 10%'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Purpose of Loan Dropdown
            Text(
              'Purpose of Loan*',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: _loanController.purpose.value,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMedium),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: _loanPurposes
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) _loanController.updatePurpose(val);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Principal Amount Slider Row
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Principal Amount',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.borderGrey, width: 1.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currencyFormatter.format(_loanController.principalAmount.value),
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Principal Amount Slider
            Obx(
              () => SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.buttonBlue,
                  inactiveTrackColor: AppColors.borderGrey,
                  thumbColor: AppColors.buttonBlue,
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _loanController.principalAmount.value,
                  min: 5000,
                  max: 200000,
                  divisions: 39,
                  onChanged: (val) {
                    _loanController.updatePrincipal(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tenure Slider Row
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tenure',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.borderGrey, width: 1.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_loanController.tenureDays.value} Days',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Tenure Slider with min/max labels below
            Obx(
              () => SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.buttonBlue,
                  inactiveTrackColor: AppColors.borderGrey,
                  thumbColor: AppColors.buttonBlue,
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _loanController.tenureDays.value.toDouble(),
                  min: 20,
                  max: 90,
                  divisions: 14,
                  onChanged: (val) {
                    _loanController.updateTenure(val.toInt());
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('20 Days', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textLight)),
                  Text('90 Days', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textLight)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Breakdown Card (Light Blue Container with border)
            Obx(
              () => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.calcCardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.calcCardBorder, width: 1.2),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'Principle Amount',
                      currencyFormatter.format(_loanController.principalAmount.value),
                    ),
                    const SizedBox(height: 10),
                    _buildSummaryRow(
                      'Interest',
                      '1%',
                    ),
                    const SizedBox(height: 10),
                    _buildSummaryRow(
                      'Processing Fee (10%)',
                      currencyFormatter.format(_loanController.processingFee),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: AppColors.calcCardBorder),
                    ),
                    _buildSummaryRow(
                      'Total Payable',
                      currencyFormatter.format(_loanController.totalPayable),
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Thank you note
            Center(
              child: Text(
                'Thank you for choosing CreditSea. Please accept to proceed with the loan details.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: AppColors.textGrey,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Apply Button
            Obx(
              () => ElevatedButton(
                onPressed: _loanController.isLoading.value
                    ? null
                    : () {
                        _loanController.proceedToOffer();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBlue,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _loanController.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Apply',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel Button
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.buttonBlue,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF93C5FD),
          width: 1.2,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E40AF),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isBold ? 14.5 : 13.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.textDark : AppColors.textMedium,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? AppColors.buttonBlue : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
