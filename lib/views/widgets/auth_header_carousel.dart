import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'app_logo.dart';

class AuthHeaderCarousel extends StatefulWidget {
  final int initialPage;
  final bool autoScroll;

  const AuthHeaderCarousel({
    super.key,
    this.initialPage = 0,
    this.autoScroll = false,
  });

  @override
  State<AuthHeaderCarousel> createState() => _AuthHeaderCarouselState();
}

class _AuthHeaderCarouselState extends State<AuthHeaderCarousel> {
  late PageController _pageController;
  late int _currentPage;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Flexible Loan Options',
      'subtitle': 'Loan types to cater to different financial needs',
      'type': 'grid',
    },
    {
      'title': 'Instant Loan Approval',
      'subtitle': 'Users will receive approval within minutes',
      'type': 'approval',
    },
    {
      'title': '24x7 Customer Care',
      'subtitle': 'Dedicated customer support team',
      'type': 'support',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final headerHeight = (size.height * 0.44).clamp(320.0, 420.0);

    return Container(
      width: double.infinity,
      height: headerHeight,
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header Logo — sized to match Figma onboarding header
            const AppLogo(height: 52, width: 185, isVertical: false),
            const SizedBox(height: 16),

            // Carousel Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, index) {
                  final item = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSlideIcon(item['type']),
                        const SizedBox(height: 18),
                        Text(
                          item['title'],
                          style: GoogleFonts.outfit(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['subtitle'],
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 3-dot Indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideIcon(String type) {
    if (type == 'grid') {
      // Slide 1: Flexible Loan Options — 4 free-floating rounded square tiles in space (no outer border/card)
      return SizedBox(
        width: 140,
        height: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFreeTile(Icons.directions_car_rounded),
                const SizedBox(width: 14),
                _buildFreeTile(Icons.two_wheeler_rounded),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFreeTile(Icons.laptop_mac_rounded),
                const SizedBox(width: 14),
                _buildFreeTile(Icons.smartphone_rounded),
              ],
            ),
          ],
        ),
      );
    } else if (type == 'approval') {
      // Slide 2: Instant Loan Approval — use the uploaded Figma SVG
      return SvgPicture.asset(
        'assets/icons/instant_loan.svg',
        width: 140,
        height: 140,
        fit: BoxFit.contain,
      );
    } else {
      // Slide 3: 24x7 Customer Care — use the uploaded Figma SVG
      return SvgPicture.asset(
        'assets/icons/24_7_customer.svg',
        width: 140,
        height: 140,
        fit: BoxFit.contain,
      );
    }
  }

  Widget _buildFreeTile(IconData icon) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
