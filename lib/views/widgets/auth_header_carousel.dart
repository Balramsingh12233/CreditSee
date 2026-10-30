import 'package:flutter/material.dart';
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
            // Header Logo
            const AppLogo(size: 38, isVertical: false),
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
      // 4-box grid: Car, Bike, Laptop, Phone (Screen 2)
      return Container(
        width: 140,
        height: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            _buildMiniTile(Icons.directions_car_rounded),
            _buildMiniTile(Icons.two_wheeler_rounded),
            _buildMiniTile(Icons.laptop_mac_rounded),
            _buildMiniTile(Icons.smartphone_rounded),
          ],
        ),
      );
    } else if (type == 'approval') {
      // Screen 3: Instant approval document with lightning
      return Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.verified_rounded,
              size: 80,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            const Icon(
              Icons.bolt_rounded,
              size: 56,
              color: Colors.white,
            ),
          ],
        ),
      );
    } else {
      // Screen 4 & 5: 24x7 Customer support
      return Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: 18,
              bottom: 18,
              child: Icon(
                Icons.star_rounded,
                size: 32,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            const Icon(
              Icons.support_agent_rounded,
              size: 64,
              color: Colors.white,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMiniTile(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
