import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/credit_score_controller.dart';
import '../../controllers/loan_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_logo.dart';
import '../widgets/demo_status_sheet.dart';

class HomeDashboardView extends StatefulWidget {
  const HomeDashboardView({super.key});

  @override
  State<HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<HomeDashboardView> {
  final AuthController _authController = Get.find<AuthController>();
  final LoanController _loanController = Get.find<LoanController>();
  late final CreditScoreController _creditController;

  @override
  void initState() {
    super.initState();
    // Use existing singleton from main.dart – avoids duplicate instance with stale/seeded data
    _creditController = Get.find<CreditScoreController>();
    _loanController.refreshStatus();
    _creditController.fetchScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: const AppLogo(size: 30, textColor: AppColors.primaryBlue),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.buttonBlue),
            tooltip: 'Demo Controls',
            onPressed: () => DemoStatusSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textGrey),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loanController.refreshStatus();
          await _creditController.fetchScore();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting Card
              Obx(() {
                final user = _authController.currentUser.value;
                final name = user?.firstName?.isNotEmpty == true ? user!.firstName! : 'Customer';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, $name! 👋',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your loans and credit health seamlessly.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 20),

              // Active Loan Application Card
              _buildActiveLoanCard(),
              const SizedBox(height: 20),

              // Bonus: Credit Score Meter Card
              _buildCreditScoreCard(),
              const SizedBox(height: 20),

              // Quick Actions
              Text(
                'Quick Actions',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.calculate_outlined,
                      title: 'Loan Calculator',
                      subtitle: 'Check eligibility',
                      color: AppColors.buttonBlue,
                      onTap: () => Get.toNamed(AppRoutes.loanCalculator),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.payment_outlined,
                      title: 'Mock Repay',
                      subtitle: 'Boost score',
                      color: AppColors.successGreen,
                      onTap: () => Get.toNamed(AppRoutes.repayment),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Profile Overview Card
              _buildProfileSummaryCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveLoanCard() {
    return Obx(() {
      final appId = _loanController.applicationId.value;

      // If user has not applied for any loan yet, show Apply CTA card
      if (appId.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.buttonBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.buttonBlue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Instant Cash Loan',
                            style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark)),
                        Text('Get up to ₹1,00,000 in your account',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.loanCalculator),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBlue,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Apply for Loan',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ],
          ),
        );
      }

      final status = _loanController.currentStatus.value;
      final step = _loanController.currentStep.value;

      Color badgeBg = AppColors.calcCardBg;
      Color badgeText = AppColors.buttonBlue;
      if (status == 'Disbursed') {
        badgeBg = AppColors.successBg;
        badgeText = AppColors.successGreen;
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Loan Application',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Application ID: $appId',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Amount: ₹ ${_loanController.principalAmount.value.toInt()} • Tenure: ${_loanController.tenureDays.value} Days',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (step / 6).clamp(0.1, 1.0),
                backgroundColor: AppColors.borderGrey,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.buttonBlue),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Step $step of 6',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textLight),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _loanController.statusMessage.value,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.buttonBlue,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.applicationStatus),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBlue,
                minimumSize: const Size.fromHeight(42),
              ),
              child: const Text('Track Live Status', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      );
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Red soft icon badge
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2), // soft red
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                'Log Out of CreditSea?',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Are you sure you want to log out? You will need to sign in again to access your loan account.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textGrey,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _authController.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: const Color(0xFFDC2626),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Log Out',
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditScoreCard() {
    return Obx(() {
      final score = _creditController.score.value;
      final category = _creditController.category.value;
      final onTimePercent = _creditController.onTimePercent.value;
      final utilization = _creditController.creditUtilization.value;
      final inquiries = _creditController.recentInquiries.value;
      final progress = ((score - 300) / 600).clamp(0.0, 1.0);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0052CC), Color(0xFF00388F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0052CC).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Credit Health Score',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5B5).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00E5B5), width: 1.2),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00E5B5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Score Display
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$score',
                  style: GoogleFonts.outfit(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '/ 900',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.repayment),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Boost Score',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5B5)),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('300 Poor', style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
                Text('650 Fair', style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
                Text('750 Good', style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
                Text('900 Excellent', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF00E5B5))),
              ],
            ),
            const SizedBox(height: 16),

            // 3 Live Factor Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricMini('Payment History', onTimePercent, Icons.check_circle_outline),
                  Container(width: 1, height: 26, color: Colors.white24),
                  _buildMetricMini('Utilization', utilization, Icons.pie_chart_outline),
                  Container(width: 1, height: 26, color: Colors.white24),
                  _buildMetricMini('Inquiries', '$inquiries Low', Icons.search_rounded),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricMini(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummaryCard() {
    return Obx(() {
      final user = _authController.currentUser.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Details',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.personalDetails),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.buttonBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildProfileRow('Full Name', user?.fullName ?? 'Rahul Sharma'),
            _buildProfileRow('Mobile Number', '+91 ${user?.phone ?? "8800642354"}'),
            _buildProfileRow('Date of Birth', user?.dateOfBirth ?? '15-08-1995'),
            _buildProfileRow('Gender', user?.gender ?? 'Male'),
            _buildProfileRow('PAN Card', user?.pan ?? 'ABCDE1234F'),
            _buildProfileRow('Marital Status', user?.maritalStatus ?? 'Single'),
          ],
        ),
      );
    });
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textGrey)),
          Text(value, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
