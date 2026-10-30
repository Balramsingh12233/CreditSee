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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _panController = TextEditingController();

  String? _selectedGender;
  String? _selectedMaritalStatus;
  final bool _isLoadingSkeleton = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _maritalOptions = ['Single', 'Married', 'Divorced', 'Widowed'];

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser.value;
    if (user != null) {
      _firstNameController.text = user.firstName ?? 'Rahul';
      _lastNameController.text = user.lastName ?? 'Sharma';
      _dobController.text = user.dateOfBirth ?? '15-08-1995';
      _emailController.text = user.email ?? 'rahul.sharma@example.com';
      _panController.text = user.pan ?? 'ABCDE1234F';
      _selectedGender = user.gender?.isNotEmpty == true ? user.gender : 'Male';
      _selectedMaritalStatus =
          user.maritalStatus?.isNotEmpty == true ? user.maritalStatus : 'Single';
    } else {
      _firstNameController.text = 'Rahul';
      _lastNameController.text = 'Sharma';
      _dobController.text = '15-08-1995';
      _emailController.text = 'rahul.sharma@example.com';
      _panController.text = 'ABCDE1234F';
      _selectedGender = 'Male';
      _selectedMaritalStatus = 'Single';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _panController.dispose();
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: const StepperHeader(currentStep: 1), // Step 1: Register
        ),
      ),
      body: _isLoadingSkeleton
          ? _buildSkeletonLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Arrow + Title (Screen 7 & 10)
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

                  // Marital Status Dropdown
                  _buildFieldLabel('Your Marital Status *'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMaritalStatus,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMedium,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Select',
                    ),
                    items: _maritalOptions
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedMaritalStatus = val);
                    },
                  ),
                  const SizedBox(height: 18),

                  // PAN & Email (Assignment Requirements)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('PAN Number*'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _panController,
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 10,
                              decoration: const InputDecoration(
                                counterText: '',
                                hintText: 'ABCDE1234F',
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
                            _buildFieldLabel('Email Address'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'name@email.com',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Continue Button
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
                                maritalStatus: _selectedMaritalStatus ?? 'Single',
                                email: _emailController.text.trim(),
                                pan: _panController.text.trim(),
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

  // Skeleton Loader (Screen 6 & 9 in screenshots)
  Widget _buildSkeletonLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 180,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
