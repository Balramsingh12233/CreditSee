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

  String? _selectedPurpose;

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
  void initState() {
    super.initState();
    // Use postFrameCallback to avoid setState-during-build with Obx
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loanController.principalAmount.value = 30000.0;
      _loanController.tenureDays.value = 40;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const AppLogo(size: 30, isVertical: false, textColor: AppColors.primaryBlue),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                    // Back Arrow + Title (Inside Card — 1:1 Figma Matching)
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
                          'Apply for loan',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
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

            // Two Dashed Border Chips: Interest Per Day 1% | Processing Fee 10% (Figma UI)
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

            // Purpose of Loan Dropdown with hint 'Select purpose of loan'
            Text(
              'Purpose of Loan*',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedPurpose,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMedium),
              decoration: const InputDecoration(
                hintText: 'Select purpose of loan',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _loanPurposes
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedPurpose = val);
                if (val != null) _loanController.updatePurpose(val);
              },
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

            // Principal Amount Slider (5,000 to 2,00,000)
            Obx(
              () => SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.buttonBlue,
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                  thumbColor: AppColors.buttonBlue,
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                ),
                child: Slider(
                  value: _loanController.principalAmount.value.clamp(5000, 200000),
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

            // Tenure Slider: 20 Days to 45 Days (Strictly matching Figma left screenshot)
            Obx(
              () => SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.buttonBlue,
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                  thumbColor: AppColors.buttonBlue,
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                ),
                child: Slider(
                  value: _loanController.tenureDays.value.toDouble().clamp(20.0, 45.0),
                  min: 20,
                  max: 45,
                  divisions: 25,
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
                  Text(
                    '20 Days',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textLight),
                  ),
                  Text(
                    '45 Days',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Breakdown Card (Matching Figma: Light blue card, blue values on right, 3 rows)
            Obx(
              () => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B82F6), width: 1.2),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'Principle Amount',
                      currencyFormatter.format(_loanController.principalAmount.value),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'Interest',
                      '1%',
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'Total Payable',
                      currencyFormatter.format(_loanController.totalPayable),
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cyan/Teal Note (Strictly matching Figma left screenshot)
            Center(
              child: Text(
                'Thank you for choosing CreditSea. Please accept to proceed with the loan details.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: const Color(0xFF0284C7),
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      // Pinned Action Buttons at the bottom (1:1 Figma placement)
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Apply Button (Solid Blue)
              Obx(
                () => ElevatedButton(
                  onPressed: _loanController.isLoading.value
                      ? null
                      : () {
                          _loanController.proceedToOffer();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBlue,
                    minimumSize: const Size.fromHeight(48),
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
              const SizedBox(height: 10),

              // Cancel Button (Outlined White with Blue border)
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.buttonBlue, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
            ],
          ),
        ),
      ),
    ),
    );
  }

  // Dashed border chip matching Figma
  Widget _buildDashedBadge(String text) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFF60A5FA),
        radius: 8.0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
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
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.textDark : const Color(0xFF334155),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: isBold ? 16 : 14.5,
            fontWeight: FontWeight.bold,
            color: AppColors.buttonBlue, // Always bold blue in Figma!
          ),
        ),
      ],
    );
  }
}

// Custom Painter for authentic dashed borders (matching Figma chips)
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    this.radius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.2;
    const dashWidth = 5.0;
    const dashSpace = 3.5;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length) ? dashWidth : metric.length - distance;
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
