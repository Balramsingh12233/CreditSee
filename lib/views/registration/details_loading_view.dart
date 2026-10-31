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
      duration: const Duration(milliseconds: 1300),
    )..repeat();

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: const [
                    Color(0xFFE2E8F0),
                    Color(0xFFF8FAFC),
                    Color(0xFFE2E8F0),
                  ],
                  stops: const [0.1, 0.5, 0.9],
                  begin: const Alignment(-1.0, -0.2),
                  end: const Alignment(1.0, 0.2),
                  transform: _SlidingGradientTransform(slidePercent: _controller.value),
                ).createShader(bounds);
              },
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar Placeholder (Exact match with Figma Image 1 Screen 3)
                    _buildBox(
                      width: double.infinity,
                      height: 18,
                      borderRadius: 6,
                    ),
                    const SizedBox(height: 24),

                    // Main White Card with Skeleton Elements (1:1 Figma wireframe)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title skeleton
                          _buildBox(
                            width: 140,
                            height: 22,
                            borderRadius: 6,
                          ),
                          const SizedBox(height: 24),

                          // First & Last Name Two-column skeleton
                          Row(
                            children: [
                              Expanded(
                                child: _buildBox(
                                  width: double.infinity,
                                  height: 48,
                                  borderRadius: 10,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildBox(
                                  width: double.infinity,
                                  height: 48,
                                  borderRadius: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Gender Dropdown skeleton
                          _buildBox(
                            width: double.infinity,
                            height: 48,
                            borderRadius: 10,
                          ),
                          const SizedBox(height: 18),

                          // Date of Birth skeleton
                          _buildBox(
                            width: double.infinity,
                            height: 48,
                            borderRadius: 10,
                          ),
                          const SizedBox(height: 18),

                          // Marital Status skeleton
                          _buildBox(
                            width: double.infinity,
                            height: 48,
                            borderRadius: 10,
                          ),
                          const SizedBox(height: 36),

                          // Continue Button skeleton
                          _buildBox(
                            width: double.infinity,
                            height: 50,
                            borderRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBox({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
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
