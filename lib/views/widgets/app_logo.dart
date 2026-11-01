import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// AppLogo renders the user-uploaded Figma SVG logos across the entire app.
///
/// • isVertical = true  → assets/images/logo.svg (Splash screen vertical badge + text)
/// • textColor == Colors.white → assets/images/logo1.svg (Horizontal white logo for blue headers)
/// • other (light/white background) → assets/images/logo2.svg (Horizontal blue logo for AppBars)
class AppLogo extends StatelessWidget {
  final double size;
  final bool isVertical;
  final Color textColor;

  const AppLogo({
    super.key,
    this.size = 36,
    this.isVertical = false,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return SvgPicture.asset(
        'assets/images/logo.svg',
        width: size * 1.6,
        fit: BoxFit.contain,
      );
    }

    final isWhiteText = textColor == Colors.white;
    return SvgPicture.asset(
      isWhiteText ? 'assets/images/logo1.svg' : 'assets/images/logo2.svg',
      height: size,
      fit: BoxFit.contain,
    );
  }
}
