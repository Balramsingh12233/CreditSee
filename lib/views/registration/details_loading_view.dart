import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

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
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Smooth transition to Personal Details screen
    _timer = Timer(const Duration(milliseconds: 1600), () {
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
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Rounded Pill Bar (Exact 1:1 match with Figma wireframe) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: _shimmerBox(
                    width: double.infinity,
                    height: 16,
                    radius: 8,
                  ),
                ),
                const SizedBox(height: 10),

                // ── White Card (Extends seamlessly to bottom with top rounded corners) ──
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title skeleton bar
                        _shimmerBox(width: 150, height: 20, radius: 6),
                        const SizedBox(height: 24),

                        // Two-Column: First Name & Last Name (Label + Input)
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _shimmerBox(width: 80, height: 12, radius: 4),
                                  const SizedBox(height: 8),
                                  _shimmerBox(width: double.infinity, height: 48, radius: 10),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _shimmerBox(width: 80, height: 12, radius: 4),
                                  const SizedBox(height: 8),
                                  _shimmerBox(width: double.infinity, height: 48, radius: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Gender Field (Label + Input)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _shimmerBox(width: 70, height: 12, radius: 4),
                            const SizedBox(height: 8),
                            _shimmerBox(width: double.infinity, height: 48, radius: 10),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Date of Birth Field (Label + Input)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _shimmerBox(width: 100, height: 12, radius: 4),
                            const SizedBox(height: 8),
                            _shimmerBox(width: double.infinity, height: 48, radius: 10),
                          ],
                        ),

                        const Spacer(),

                        // Bottom Continue Button skeleton
                        _shimmerBox(width: double.infinity, height: 50, radius: 10),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
          Color(0xFFF1F5F9),
          Color(0xFFFFFFFF),
          Color(0xFFF1F5F9),
          Color(0xFFE2E8F0),
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        transform: _SlidingGradientTransform(slidePercent: _controller.value),
      ).createShader(bounds),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
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
