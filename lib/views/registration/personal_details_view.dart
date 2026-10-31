import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/stepper_header.dart';

class PersonalDetailsView extends StatefulWidget {
  const PersonalDetailsView({super.key});

  @override
  State<PersonalDetailsView> createState() => _PersonalDetailsViewState();
}

class _PersonalDetailsViewState extends State<PersonalDetailsView> {
  final AuthController _authController = Get.find<AuthController>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedGender;
  String? _selectedIncome;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _incomeOptions = [
    '₹15,000 - ₹25,000',
    '₹25,000 - ₹50,000',
    '₹50,000 - ₹1,00,000',
    '₹1,00,000+',
  ];

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser.value;
    if (user != null) {
      _firstNameController.text = user.firstName ?? 'Rahul';
      _lastNameController.text = user.lastName ?? 'Sharma';
      _dobController.text = user.dateOfBirth ?? '15-08-1995';
      _selectedGender = user.gender?.isNotEmpty == true ? user.gender : 'Male';
    } else {
      _firstNameController.text = 'Rahul';
      _lastNameController.text = 'Sharma';
      _dobController.text = '15-08-1995';
      _selectedGender = 'Male';
    }
    _selectedIncome = '₹25,000 - ₹50,000';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1996, 5, 20),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.buttonBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormat('dd - MM - yyyy').format(picked);
      setState(() {
        _dobController.text = formatted;
      });
    }
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
            // Back Arrow + Title (Screen 7 & Image 2 Screen 1)
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
                  'Personal Details',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // First Name & Last Name (Two Columns)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('First Name*'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          hintText: 'Your first name',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Last Name*'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          hintText: 'Your last name',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Gender Dropdown
            _buildFieldLabel('Gender*'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMedium,
              ),
              decoration: const InputDecoration(
                hintText: 'Select your gender',
              ),
              items: _genderOptions
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedGender = val);
              },
            ),
            const SizedBox(height: 18),

            // Date of Birth
            _buildFieldLabel('Date of Birth*'),
            const SizedBox(height: 6),
            TextField(
              controller: _dobController,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                hintText: 'DD - MM - YYYY',
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.textMedium,
                    size: 20,
                  ),
                  onPressed: _pickDate,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Your Monthly Household Income Dropdown (Image 2 Screen 1)
            _buildFieldLabel('Your Monthly Household Income*'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedIncome,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMedium,
              ),
              decoration: const InputDecoration(
                hintText: 'Select your monthly household income',
              ),
              items: _incomeOptions
                  .map((inc) => DropdownMenuItem(value: inc, child: Text(inc)))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedIncome = val);
              },
            ),
            const SizedBox(height: 36),

            // Continue Button -> Navigates to Personal Email ID
            Obx(
              () => ElevatedButton(
                onPressed: _authController.isLoading.value
                    ? null
                    : () {
                        _authController.savePersonalDetails(
                          firstName: _firstNameController.text.trim(),
                          lastName: _lastNameController.text.trim(),
                          gender: _selectedGender ?? 'Male',
                          dob: _dobController.text.trim(),
                          monthlyHouseholdIncome: _selectedIncome ?? '₹25,000 - ₹50,000',
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
                        'Continue',
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textMedium,
      ),
    );
  }
}
