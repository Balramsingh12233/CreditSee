import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../widgets/stepper_header.dart';

class DetailsLoadingView extends StatefulWidget {
  const DetailsLoadingView({super.key});

  @override
  State<DetailsLoadingView> createState() => _DetailsLoadingViewState();
}

class _DetailsLoadingViewState extends State<DetailsLoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _shimmerAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Smooth transition to Personal Details after simulating profile fetch
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Get.offNamed(AppRoutes.personalDetails);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: SafeArea(
          child: StepperHeader(currentStep: 1),
        ),
      ),
      body: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          final opacity = _shimmerAnimation.value;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Stepper Skeleton placeholder bar
                _buildSkeletonBox(
                  width: double.infinity,
                  height: 18,
                  opacity: opacity,
                  borderRadius: 4,
                ),
                const SizedBox(height: 24),

                // Main Details Card (Wireframe matching Figma Screen 6/Image 1 screen 3)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title bar skeleton
                      _buildSkeletonBox(
                        width: 140,
                        height: 20,
                        opacity: opacity,
                        borderRadius: 6,
                      ),
                      const SizedBox(height: 24),

                      // Two-column First & Last Name skeleton
                      Row(
                        children: [
                          Expanded(
                            child: _buildSkeletonBox(
                              width: double.infinity,
                              height: 48,
                              opacity: opacity,
                              borderRadius: 10,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSkeletonBox(
                              width: double.infinity,
                              height: 48,
                              opacity: opacity,
                              borderRadius: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Gender Dropdown skeleton
                      _buildSkeletonBox(
                        width: double.infinity,
                        height: 48,
                        opacity: opacity,
                        borderRadius: 10,
                      ),
                      const SizedBox(height: 18),

                      // Date of Birth skeleton
                      _buildSkeletonBox(
                        width: double.infinity,
                        height: 48,
                        opacity: opacity,
                        borderRadius: 10,
                      ),
                      const SizedBox(height: 18),

                      // Monthly Income Dropdown skeleton
                      _buildSkeletonBox(
                        width: double.infinity,
                        height: 48,
                        opacity: opacity,
                        borderRadius: 10,
                      ),
                      const SizedBox(height: 36),

                      // Continue Button skeleton
                      _buildSkeletonBox(
                        width: double.infinity,
                        height: 50,
                        opacity: opacity,
                        borderRadius: 10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.buttonBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Loading your application profile...',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    required double opacity,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

