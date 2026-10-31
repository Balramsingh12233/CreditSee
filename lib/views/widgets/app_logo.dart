import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// AppLogo renders the uploaded Figma logo across all screens.
///
/// • isVertical = true  → full logo.svg (splash, standalone)
/// • isVertical = false → icon badge (custom painter) + "CreditSea" text side-by-side
///   matching the Figma nav-bar header exactly.
class AppLogo extends StatelessWidget {
  final double size;
  final bool isVertical;
  final Color textColor;

  const AppLogo({
    super.key,
    this.size = 64,
    this.isVertical = false,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // ── Splash / Vertical: render the full Figma logo SVG ──────────────────
    if (isVertical) {
      return SvgPicture.asset(
        'assets/images/logo.svg',
        width: size * 1.6,
        fit: BoxFit.contain,
      );
    }

    // ── Horizontal nav-bar: circular badge + "Credit Sea" text ─────────────
    // The badge uses a white circle with the green sail icon — matching Figma.
    final iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: textColor == AppColors.primaryBlue ? Colors.white : Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.70, size * 0.70),
          painter: _SailPainter(),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Credit',
                style: GoogleFonts.outfit(
                  fontSize: size * 0.44,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
              TextSpan(
                text: 'Sea',
                style: GoogleFonts.outfit(
                  fontSize: size * 0.44,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sail 1 – teal
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.15, h * 0.58)
        ..lineTo(w * 0.82, h * 0.22)
        ..lineTo(w * 0.42, h * 0.60)
        ..close(),
      Paint()..color = AppColors.accentCyan..style = PaintingStyle.fill,
    );

    // Sail 2 – lighter teal
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.28, h * 0.68)
        ..lineTo(w * 0.95, h * 0.12)
        ..lineTo(w * 0.68, h * 0.70)
        ..close(),
      Paint()..color = const Color(0xFF00E5B5)..style = PaintingStyle.fill,
    );

    // Hull
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.10, h * 0.74)
        ..quadraticBezierTo(w * 0.55, h * 0.88, w * 0.90, h * 0.72)
        ..quadraticBezierTo(w * 0.55, h * 0.80, w * 0.10, h * 0.74)
        ..close(),
      Paint()..color = const Color(0xFF00B078)..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
