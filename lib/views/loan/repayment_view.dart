import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/credit_score_controller.dart';
import '../../controllers/loan_controller.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../dashboard/home_dashboard_view.dart';

/// Full mock Razorpay/UPI repayment screen.
/// Shows EMI breakdown, selectable payment methods, real processing animation.
class RepaymentView extends StatefulWidget {
  const RepaymentView({super.key});

  @override
  State<RepaymentView> createState() => _RepaymentViewState();
}

class _RepaymentViewState extends State<RepaymentView> {
  final LoanController _loanCtrl = Get.find<LoanController>();
  final CreditScoreController _creditCtrl = Get.find<CreditScoreController>();

  int _selectedMethod = 0; // 0=UPI, 1=Card, 2=NetBanking, 3=Wallet

  // UPI form
  final _upiController = TextEditingController();
  bool _upiValid = true;

  // Card form
  final _cardNumberCtrl = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();

  bool _isProcessing = false;
  bool _paymentSuccess = false;
  int _processingStep = 0; // 0-4 processing steps
  Timer? _processingTimer;

  // EMI breakdown data
  late final double _principal;
  late final double _interest;
  late final double _processingFee;
  late final double _totalPayable;
  late final String _appId;
  late final int _oldCreditScore;
  late final int _newCreditScore;
  late final int _scoreIncrease;

  @override
  void initState() {
    super.initState();
    _principal = _loanCtrl.offerAmount.value;
    _interest = (_principal * 0.01 * (_loanCtrl.offerTenureDays.value / 30));
    _processingFee = _principal * 0.10;
    _totalPayable = _loanCtrl.offerPayable.value;
    _appId = _loanCtrl.applicationId.value;
    _oldCreditScore = _creditCtrl.score.value;
    _scoreIncrease = _calculateScoreIncrease();
    _newCreditScore = (_oldCreditScore + _scoreIncrease).clamp(300, 900);
  }

  int _calculateScoreIncrease() {
    // Early full repayment = maximum boost
    int increase = 20;
    if (_creditCtrl.score.value < 700) increase = 30; // more benefit for low scorers
    if (_creditCtrl.onTimePayments.value == '0') increase = 25; // first repayment
    return increase;
  }

  @override
  void dispose() {
    _processingTimer?.cancel();
    _upiController.dispose();
    _cardNumberCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    _cardNameCtrl.dispose();
    super.dispose();
  }

  // ─── Payment Processing Flow ─────────────────────────────────────────────────

  void _startPayment() {
    final isValid = _validateCurrentMethod();
    if (!isValid) return;

    setState(() {
      _isProcessing = true;
      _processingStep = 0;
    });

    HapticFeedback.mediumImpact();

    // Simulate real payment gateway steps
    final steps = [
      'Connecting to payment gateway...',
      'Verifying payment details...',
      'Processing with bank...',
      'Confirming transaction...',
      'Updating loan account...',
    ];

    int stepIndex = 0;
    _processingTimer = Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (stepIndex < steps.length - 1) {
        stepIndex++;
        setState(() => _processingStep = stepIndex);
      } else {
        t.cancel();
        _onPaymentComplete();
      }
    });
  }

  bool _validateCurrentMethod() {
    if (_selectedMethod == 0) {
      // UPI validation
      final upi = _upiController.text.trim();
      final upiRegex = RegExp(r'^[\w.\-]+@[\w]+$');
      if (!upiRegex.hasMatch(upi)) {
        setState(() => _upiValid = false);
        Get.snackbar(
          'Invalid UPI ID',
          'Please enter a valid UPI ID (e.g., name@okicici)',
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
        return false;
      }
      setState(() => _upiValid = true);
    } else if (_selectedMethod == 1) {
      // Card validation
      if (_cardNumberCtrl.text.replaceAll(' ', '').length < 16 ||
          _cardExpiryCtrl.text.length < 5 ||
          _cardCvvCtrl.text.length < 3) {
        Get.snackbar(
          'Incomplete Card Details',
          'Please fill in all card details correctly',
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _onPaymentComplete() async {
    HapticFeedback.heavyImpact();

    setState(() {
      _isProcessing = false;
      _paymentSuccess = true;
    });

    // Update loan state
    await _loanCtrl.performMockRepayment();

    // Update credit score with proper logic
    await _creditCtrl.recordOnTimeRepayment(
      loanAmount: _totalPayable,
      isEarlyRepayment: false,
    );

    // Push notification
    await NotificationService.showRepaymentSuccess(
      applicationId: _appId,
      amount: _totalPayable,
      creditScoreIncrease: _scoreIncrease,
      newScore: _newCreditScore,
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_paymentSuccess && !_isProcessing,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _paymentSuccess) {
          Get.offAll(() => const HomeDashboardView());
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          title: Text(
            'Loan Repayment',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          leading: _paymentSuccess || _isProcessing
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: Get.back,
                ),
        ),
        body: _paymentSuccess
            ? _buildSuccessScreen()
            : _isProcessing
                ? _buildProcessingScreen()
                : _buildPaymentForm(),
      ),
    );
  }

  // ─── PAYMENT FORM ─────────────────────────────────────────────────────────────

  Widget _buildPaymentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── EMI Breakdown Card ──────────────────────────────────────────
          _buildEmiBreakdownCard(),
          const SizedBox(height: 16),

          // ── Payment Method Selector ─────────────────────────────────────
          _buildSectionLabel('Select Payment Method'),
          const SizedBox(height: 10),
          _buildPaymentMethodRow(),
          const SizedBox(height: 16),

          // ── Method Form ─────────────────────────────────────────────────
          _buildMethodForm(),
          const SizedBox(height: 16),

          // ── Secured Badge ───────────────────────────────────────────────
          _buildSecuredBadge(),
          const SizedBox(height: 20),

          // ── Pay Button ──────────────────────────────────────────────────
          _buildPayButton(),
          const SizedBox(height: 12),
          _buildCancellationNote(),
        ],
      ),
    );
  }

  Widget _buildEmiBreakdownCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF0047CC)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Repayment Summary',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _appId,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Breakdown rows
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _breakdownRow('Principal Amount', _principal, isBlue: false),
                _divider(),
                _breakdownRow('Interest (1%/day × ${_loanCtrl.offerTenureDays.value} days)', _interest),
                _divider(),
                _breakdownRow('Processing Fee (10%)', _processingFee),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF0066FF), width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '₹${_totalPayable.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0066FF),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Credit Score Preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00B074), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B074).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.trending_up_rounded,
                            color: Color(0xFF00B074), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Credit Score will improve after repayment',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF00B074),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_oldCreditScore → $_newCreditScore  (+$_scoreIncrease points)',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, double amount, {bool isBlue = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey)),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isBlue ? AppColors.textDark : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade100, height: 1);

  Widget _buildSectionLabel(String text) => Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      );

  // ─── PAYMENT METHOD SELECTOR ──────────────────────────────────────────────────

  Widget _buildPaymentMethodRow() {
    final methods = [
      ('UPI', Icons.account_balance_wallet_rounded, 'Google Pay, PhonePe'),
      ('Credit/Debit Card', Icons.credit_card_rounded, 'Visa, Mastercard, RuPay'),
      ('Net Banking', Icons.computer_rounded, '50+ banks supported'),
      ('Wallet', Icons.wallet_rounded, 'Paytm, Amazon Pay'),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: methods.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final (name, icon, sub) = methods[i];
          final selected = _selectedMethod == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedMethod = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF0066FF).withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? const Color(0xFF0066FF) : Colors.grey.shade200,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: selected ? const Color(0xFF0066FF) : Colors.grey.shade500,
                    size: 22,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? const Color(0xFF0066FF)
                          : AppColors.textGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── METHOD-SPECIFIC FORMS ────────────────────────────────────────────────────

  Widget _buildMethodForm() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _selectedMethod == 0
          ? _buildUpiForm()
          : _selectedMethod == 1
              ? _buildCardForm()
              : _selectedMethod == 2
                  ? _buildNetBankingForm()
                  : _buildWalletForm(),
    );
  }

  Widget _buildUpiForm() {
    return _formCard(
      key: const ValueKey('upi'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/images/upi_logo.png',
                  height: 22,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF0066FF),
                        size: 22,
                      )),
              const SizedBox(width: 8),
              Text('UPI Payment',
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          Text('UPI ID / VPA',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium)),
          const SizedBox(height: 6),
          TextField(
            controller: _upiController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'yourname@okicici',
              hintStyle:
                  GoogleFonts.inter(fontSize: 13, color: AppColors.textLight),
              prefixIcon: const Icon(Icons.alternate_email_rounded,
                  color: AppColors.textGrey, size: 18),
              errorText: _upiValid ? null : 'Invalid UPI ID',
              suffixIcon: SizedBox(
                width: 60,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Verify',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF0066FF),
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Quick pay apps
          Text('Or pay using',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textGrey)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _quickPayApp('GPay', Colors.blue.shade700, Icons.g_mobiledata_rounded),
                const SizedBox(width: 8),
                _quickPayApp('PhonePe', const Color(0xFF5F259F), Icons.phone_android_rounded),
                const SizedBox(width: 8),
                _quickPayApp('Paytm', Colors.blue.shade400, Icons.account_balance_wallet_outlined),
                const SizedBox(width: 8),
                _quickPayApp('BHIM', Colors.orange.shade700, Icons.currency_rupee_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickPayApp(String name, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        _upiController.text = 'user@${name.toLowerCase()}';
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(name,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return _formCard(
      key: const ValueKey('card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card_rounded,
                  color: Color(0xFF0066FF), size: 22),
              const SizedBox(width: 8),
              Text('Card Payment',
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              const Spacer(),
              // Card brand logos (mock)
              Row(
                children: [
                  _cardBrandBadge('VISA', Colors.blue.shade800),
                  const SizedBox(width: 6),
                  _cardBrandBadge('MC', Colors.red.shade700),
                  const SizedBox(width: 6),
                  _cardBrandBadge('RuPay', Colors.green.shade700),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Card Number',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium)),
          const SizedBox(height: 6),
          TextField(
            controller: _cardNumberCtrl,
            keyboardType: TextInputType.number,
            maxLength: 19,
            decoration: InputDecoration(
              counterText: '',
              hintText: '0000  0000  0000  0000',
              prefixIcon: const Icon(Icons.credit_card_outlined,
                  color: AppColors.textGrey, size: 18),
              hintStyle:
                  GoogleFonts.inter(fontSize: 13, color: AppColors.textLight),
            ),
            inputFormatters: [_CardNumberFormatter()],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expiry Date',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMedium)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _cardExpiryCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'MM/YY',
                        hintStyle: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textLight),
                      ),
                      inputFormatters: [_ExpiryFormatter()],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CVV',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMedium)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _cardCvvCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '•••',
                        hintStyle: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textLight),
                        suffixIcon: const Tooltip(
                          message: '3-digit code on back of card',
                          child:
                              Icon(Icons.help_outline, size: 16, color: AppColors.textLight),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Name on Card',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium)),
          const SizedBox(height: 6),
          TextField(
            controller: _cardNameCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'RAHUL SHARMA',
              hintStyle:
                  GoogleFonts.inter(fontSize: 13, color: AppColors.textLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardBrandBadge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w800)),
      );

  Widget _buildNetBankingForm() {
    final banks = [
      ('SBI', Colors.blue.shade700),
      ('HDFC', Colors.red.shade700),
      ('ICICI', Colors.orange.shade700),
      ('Axis', Colors.purple.shade700),
      ('Kotak', Colors.red.shade600),
      ('PNB', Colors.red.shade800),
    ];

    return _formCard(
      key: const ValueKey('netbanking'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.computer_rounded,
                  color: Color(0xFF0066FF), size: 22),
              const SizedBox(width: 8),
              Text('Net Banking',
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          Text('Popular Banks',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: banks.map((b) {
              final (name, color) = b;
              return GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                    color: color.withValues(alpha: 0.06),
                  ),
                  child: Center(
                    child: Text(
                      name,
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text('All other banks',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            hint: Text('Select your bank',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textLight)),
            items: ['Bank of Baroda', 'Union Bank', 'Canara Bank', 'Yes Bank']
                .map((b) =>
                    DropdownMenuItem(value: b, child: Text(b, style: GoogleFonts.inter(fontSize: 13))))
                .toList(),
            onChanged: (_) {},
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletForm() {
    final wallets = [
      ('Paytm', Colors.blue.shade500, Icons.account_balance_wallet),
      ('Amazon Pay', Colors.orange.shade600, Icons.shopping_bag),
      ('JioPay', Colors.blue.shade700, Icons.phone_android),
      ('MobiKwik', Colors.purple.shade500, Icons.wallet),
    ];

    return _formCard(
      key: const ValueKey('wallet'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wallet_rounded, color: Color(0xFF0066FF), size: 22),
              const SizedBox(width: 8),
              Text('Mobile Wallets',
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          ...wallets.map((w) {
            final (name, color, icon) = w;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 22),
                      const SizedBox(width: 12),
                      Text(name,
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _formCard({required Widget child, required ValueKey key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildSecuredBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_rounded, size: 13, color: Color(0xFF00B074)),
        const SizedBox(width: 5),
        Text(
          '256-bit SSL Encrypted · Secured by Razorpay',
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: _startPayment,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00B074),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: const Color(0xFF00B074).withValues(alpha: 0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, size: 18),
          const SizedBox(width: 8),
          Text(
            'Pay ₹${_totalPayable.toStringAsFixed(0)} Securely',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationNote() => Center(
        child: Text(
          'By proceeding, you agree to CreditSea\'s loan repayment terms.',
          style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textLight),
          textAlign: TextAlign.center,
        ),
      );

  // ─── PROCESSING SCREEN ────────────────────────────────────────────────────────

  Widget _buildProcessingScreen() {
    final steps = [
      'Connecting to gateway...',
      'Verifying payment details...',
      'Processing with bank...',
      'Confirming transaction...',
      'Updating loan account...',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated spinner
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: (_processingStep + 1) / steps.length,
                strokeWidth: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF0066FF)),
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(
                  delay: const Duration(seconds: 1),
                  duration: const Duration(milliseconds: 1200),
                ),
            const SizedBox(height: 32),
            Text(
              'Processing Payment',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${_totalPayable.toStringAsFixed(0)}',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0066FF),
              ),
            ),
            const SizedBox(height: 24),
            // Step list
            ...List.generate(steps.length, (i) {
              final done = i < _processingStep;
              final active = i == _processingStep;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: done
                          ? const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF00B074), size: 20, key: ValueKey('done'))
                          : active
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: const Color(0xFF0066FF),
                                    key: const ValueKey('active'),
                                  ),
                                )
                              : Icon(Icons.circle_outlined,
                                  color: Colors.grey.shade300,
                                  size: 20,
                                  key: ValueKey('pending$i')),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      steps[i],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.normal,
                        color: done
                            ? const Color(0xFF00B074)
                            : active
                                ? AppColors.textDark
                                : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            Text(
              'Do not close the app or press back',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SUCCESS SCREEN ────────────────────────────────────────────────────────────

  Widget _buildSuccessScreen() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Success icon
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFF00B074).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF00B074),
              size: 54,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
              )
              .fadeIn(),

          const SizedBox(height: 18),

          Text(
            'Payment Successful!',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 6),

          Text(
            '₹${_totalPayable.toStringAsFixed(0)} repaid',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00B074),
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 4),
          Text(
            'Transaction ID: TXN${DateTime.now().millisecondsSinceEpoch % 1000000}',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textGrey),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 20),

          // Credit Score Boost Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF00C48B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '🏆 Credit Score Updated!',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _scoreBox('$_oldCreditScore', 'Previous'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 20),
                    ),
                    _scoreBox('$_newCreditScore', 'New Score'),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+$_scoreIncrease points from on-time repayment',
                    style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms)
              .slideY(begin: 0.3, end: 0, delay: 500.ms),

          const SizedBox(height: 18),

          // What improved
          _buildScoreFactors()
              .animate()
              .fadeIn(delay: 600.ms),

          const SizedBox(height: 26),

          // Fully visible and tappable "Back to Dashboard" button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Get.offAll(() => const HomeDashboardView());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Back to Dashboard',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _scoreBox(String score, String label) {
    return Column(
      children: [
        Text(score,
            style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white)),
        Text(label,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  Widget _buildScoreFactors() {
    final factors = [
      ('Payment History', '✅ On-time repayment recorded', true),
      ('Credit Utilization', '📉 Loan balance reduced', true),
      ('Account Standing', '⭐ No missed payments', true),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00B074).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Improvement Factors',
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00B074)),
          ),
          const SizedBox(height: 8),
          ...factors.map((f) {
            final (factor, desc, improved) = f;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    improved
                        ? Icons.arrow_upward_rounded
                        : Icons.remove_rounded,
                    color: improved
                        ? const Color(0xFF00B074)
                        : Colors.grey,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(factor,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                        Text(desc,
                            style: GoogleFonts.inter(
                                fontSize: 10.5,
                                color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Input Formatters ─────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    text = text.substring(0, text.length.clamp(0, 5));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

