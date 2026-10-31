import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

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
    // Splash screen (isVertical: true) renders the full logo.svg from Figma.
    // Header bar (isVertical: false) renders icon + text side by side.
    if (isVertical) {
      return SvgPicture.asset(
        'assets/images/logo.svg',
        width: size * 1.8,
        fit: BoxFit.contain,
      );
    }

    // Horizontal variant: icon badge + "CreditSea" text
    final iconWidget = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.72, size * 0.72),
          painter: _ShipSailPainter(),
        ),
      ),
    );

    final textWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Credit',
          style: GoogleFonts.outfit(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'Sea',
          style: GoogleFonts.outfit(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(width: 12),
        textWidget,
      ],
    );
  }
}

class _ShipSailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppColors.accentCyan
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = const Color(0xFF00E5B5)
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..color = const Color(0xFF00B078)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Sail 1
    final path1 = Path();
    path1.moveTo(w * 0.15, h * 0.58);
    path1.lineTo(w * 0.82, h * 0.22);
    path1.lineTo(w * 0.42, h * 0.60);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Sail 2
    final path2 = Path();
    path2.moveTo(w * 0.28, h * 0.68);
    path2.lineTo(w * 0.95, h * 0.12);
    path2.lineTo(w * 0.68, h * 0.70);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Hull curve
    final path3 = Path();
    path3.moveTo(w * 0.10, h * 0.74);
    path3.quadraticBezierTo(w * 0.55, h * 0.88, w * 0.90, h * 0.72);
    path3.quadraticBezierTo(w * 0.55, h * 0.80, w * 0.10, h * 0.74);
    path3.close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
