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
  String? _selectedMaritalStatus;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _maritalOptions = ['Single', 'Married', 'Divorced', 'Widowed'];

  @override
  void initState() {
    super.initState();
    // Figma initial state: shows clean placeholders
    final user = _authController.currentUser.value;
    if (user != null && user.firstName != null && user.firstName!.isNotEmpty && user.firstName != 'Rahul') {
      _firstNameController.text = user.firstName!;
      _lastNameController.text = user.lastName ?? '';
      _dobController.text = user.dateOfBirth ?? '';
      _selectedGender = user.gender?.isNotEmpty == true ? user.gender : null;
      _selectedMaritalStatus = user.maritalStatus?.isNotEmpty == true ? user.maritalStatus : null;
    }
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

  void _onContinue() {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final dob = _dobController.text.trim();
    final gender = _selectedGender;
    final marital = _selectedMaritalStatus;

    if (first.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your First Name',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    if (last.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your Last Name',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    if (gender == null || gender.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please select your Gender',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    if (dob.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please select your Date of Birth',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    if (marital == null || marital.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please select your Marital Status',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    _authController.savePersonalDetails(
      firstName: first,
      lastName: last,
      gender: gender,
      dob: dob,
      maritalStatus: marital,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Stepper on light grey background (Figma design)
            const StepperHeader(currentStep: 1),
            const SizedBox(height: 8),

            // White Card with rounded top corners enclosing back arrow, title & form
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
                      // Back Arrow + Title (Inside Card)
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

            // First Name & Last Name (Two Columns - 1:1 Figma)
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

            // Date of Birth (Showing DD - MM - YYYY format prompt as in Figma)
            _buildFieldLabel('Date of Birth*'),
            const SizedBox(height: 6),
            TextField(
              controller: _dobController,
              readOnly: true,
              onTap: _pickDate,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'DD - MM - YYYY',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.textLight,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
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

            // Your Marital Status Dropdown (Strictly matching Figma UI)
            _buildFieldLabel('Your Marital Status *'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedMaritalStatus,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMedium,
              ),
              decoration: const InputDecoration(
                hintText: 'Select your marital status',
              ),
              items: _maritalOptions
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedMaritalStatus = val);
              },
            ),
            const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Pinned Button at the bottom of the screen (1:1 Figma placement)
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Obx(
            () => ElevatedButton(
              onPressed: _authController.isLoading.value ? null : _onContinue,
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
        ),
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
