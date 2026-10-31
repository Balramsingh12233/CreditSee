import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  late AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();

    // Navigate to Personal Details after shimmer
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) Get.offNamed(AppRoutes.personalDetails);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: SafeArea(child: StepperHeader(currentStep: 1)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top stepper-like bar ──────────────────────────────────
                  _shimmerBox(width: double.infinity, height: 10, radius: 5),
                  const SizedBox(height: 20),

                  // ── Page title skeleton ───────────────────────────────────
                  _shimmerBox(width: 160, height: 22, radius: 6),
                  const SizedBox(height: 20),

                  // ── First Name + Last Name ────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: _shimmerBox(height: 48, radius: 10)),
                      const SizedBox(width: 12),
                      Expanded(child: _shimmerBox(height: 48, radius: 10)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Gender dropdown ───────────────────────────────────────
                  _shimmerBox(width: double.infinity, height: 48, radius: 10),
                  const SizedBox(height: 16),

                  // ── Date of Birth ─────────────────────────────────────────
                  _shimmerBox(width: double.infinity, height: 48, radius: 10),
                  const SizedBox(height: 16),

                  // ── Marital status label skeleton ─────────────────────────
                  _shimmerBox(width: 140, height: 14, radius: 5),
                  const SizedBox(height: 8),

                  // ── Marital status field ──────────────────────────────────
                  _shimmerBox(width: double.infinity, height: 48, radius: 10),
                  const SizedBox(height: 16),

                  // ── Extra field ───────────────────────────────────────────
                  _shimmerBox(width: double.infinity, height: 48, radius: 10),
                  const Spacer(),

                  // ── Continue button skeleton ──────────────────────────────
                  _shimmerBox(width: double.infinity, height: 50, radius: 10),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox({
    double? width,
    required double height,
    double radius = 8,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) => LinearGradient(
        colors: const [
          Color(0xFFE2E8F0),
          Color(0xFFF8FAFC),
          Color(0xFFE2E8F0),
        ],
        stops: const [0.1, 0.5, 0.9],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        transform: _SlidingGradientTransform(slidePercent: _controller.value),
      ).createShader(bounds),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.borderGrey,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0.0,
      0.0,
    );
  }
}
