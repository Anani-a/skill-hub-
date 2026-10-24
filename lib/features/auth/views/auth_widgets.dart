import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AUTH VISUAL EFFECTS
// ─────────────────────────────────────────────────────────────────────────────

/// Custom Clipper for the wave shape separating header and content
class TopWaveClipper extends CustomClipper<Path> {
  const TopWaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.80);
    
    // Creates a smooth organic wave swoop
    // Starts high on left (80%), sweeps down to (50% x, 92% y),
    // and curves up to end on the right at (72% y).
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.98,
      size.width * 0.65,
      size.height * 0.65,
      size.width,
      size.height * 0.72,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Custom Painter that draws smooth, organic topographic contour lines
class TopographyPainter extends CustomPainter {
  const TopographyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    // Define center for the nested circular ridge
    final double cx = size.width * 0.55;
    final double cy = size.height * 0.35;

    // 1. Draw nested concentric wavy loops (representing topography ridges)
    _drawNestedLoop(canvas, paint, Offset(cx, cy), 25, 20);
    _drawNestedLoop(canvas, paint, Offset(cx - 4, cy + 6), 55, 45);
    _drawNestedLoop(canvas, paint, Offset(cx - 10, cy + 15), 90, 75);
    _drawNestedLoop(canvas, paint, Offset(cx - 18, cy + 28), 135, 110);
    _drawNestedLoop(canvas, paint, Offset(cx - 28, cy + 45), 185, 150);
    _drawNestedLoop(canvas, paint, Offset(cx - 40, cy + 65), 245, 200);

    // 2. Draw outer wrapping open contour lines
    // Upper background wave
    final path1 = Path();
    path1.moveTo(-50, size.height * 0.1);
    path1.cubicTo(
      size.width * 0.25, size.height * 0.05,
      size.width * 0.45, size.height * 0.22,
      size.width * 0.7, -20,
    );
    canvas.drawPath(path1, paint);

    // Lower background wave hugging the ridge
    final path2 = Path();
    path2.moveTo(-50, size.height * 0.58);
    path2.cubicTo(
      size.width * 0.3, size.height * 0.72,
      size.width * 0.7, size.height * 0.42,
      size.width + 50, size.height * 0.52,
    );
    canvas.drawPath(path2, paint);

    // Deepest wave
    final path3 = Path();
    path3.moveTo(-50, size.height * 0.72);
    path3.cubicTo(
      size.width * 0.35, size.height * 0.88,
      size.width * 0.75, size.height * 0.58,
      size.width + 50, size.height * 0.68,
    );
    canvas.drawPath(path3, paint);
  }

  void _drawNestedLoop(
    Canvas canvas,
    Paint paint,
    Offset center,
    double radiusX,
    double radiusY,
  ) {
    final path = Path();
    final top = Offset(center.dx, center.dy - radiusY);
    final right = Offset(center.dx + radiusX, center.dy);
    final bottom = Offset(center.dx, center.dy + radiusY);
    final left = Offset(center.dx - radiusX, center.dy);

    // Control point offsets for drawing smooth circles (Kappa factor)
    final double kx = radiusX * 0.5522847;
    final double ky = radiusY * 0.5522847;

    path.moveTo(top.dx, top.dy);
    
    // Top -> Right (wavy perturbation)
    path.cubicTo(
      top.dx + kx + 3, top.dy + 2,
      right.dx - 2, right.dy - ky - 3,
      right.dx, right.dy,
    );
    // Right -> Bottom (wavy perturbation)
    path.cubicTo(
      right.dx + 2, right.dy + ky - 1,
      bottom.dx + kx - 4, bottom.dy + 3,
      bottom.dx, bottom.dy,
    );
    // Bottom -> Left (wavy perturbation)
    path.cubicTo(
      bottom.dx - kx - 2, bottom.dy - 3,
      left.dx + 4, left.dy + ky - 2,
      left.dx, left.dy,
    );
    // Left -> Top (wavy perturbation)
    path.cubicTo(
      left.dx - 4, left.dy - ky + 3,
      top.dx - kx + 1, top.dy - 2,
      top.dx, top.dy,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Reusable header wave widget containing the topographic design
class AuthHeaderWave extends StatelessWidget {
  final double height;
  final Widget? child;

  const AuthHeaderWave({
    super.key,
    this.height = 240,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const TopWaveClipper(),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppTheme.primary,       // #512DA8 — brand primary
              AppTheme.primaryDark,   // #311B92 — dark gradient (login/welcome spec)
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: const TopographyPainter(),
              ),
            ),
            if (child != null) Positioned.fill(child: child!),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Brand header with app name + accent dot
class AuthBrandHeader extends StatelessWidget {
  final String appName;
  const AuthBrandHeader({super.key, required this.appName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          appName,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 2),
        const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Icon(Icons.circle, size: 7, color: AppTheme.primary),
        ),
      ],
    );
  }
}

/// Unified text field for all auth screens - updated to match the mockup layout
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? labelText;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixText: prefixText,
            prefixStyle: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: prefixIcon != null
                ? Container(
                    padding: const EdgeInsets.only(right: 8),
                    margin: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(prefixIcon, color: AppTheme.textTertiary, size: 18),
                        const SizedBox(width: 8),
                        Container(
                          height: 16,
                          width: 1.2,
                          color: AppTheme.outlineLight,
                        ),
                      ],
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: suffixIcon,
            filled: false, // Transparent background matching mockup
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.outlineLight, width: 1.5),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary, width: 2.0),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.error, width: 1.5),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.error, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}

/// Full-width solid primary CTA button (premium rounded look)
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

/// Horizontal "- Or ... -" divider
class AuthOrDivider extends StatelessWidget {
  final String label;
  const AuthOrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTheme.outlineLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppTheme.outlineLight)),
      ],
    );
  }
}

/// Row of Google / Facebook / Twitter social icon buttons
class AuthSocialRow extends StatelessWidget {
  const AuthSocialRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          child: CustomPaint(
            size: const Size(22, 22),
            painter: _GoogleIconPainter(),
          ),
          onTap: () {},
        ),
        const SizedBox(width: 16),
        _SocialButton(
          child: const Icon(Icons.facebook,
              color: Color(0xFF1877F2), size: 26),
          onTap: () {},
        ),
        const SizedBox(width: 16),
        _SocialButton(
          child: CustomPaint(
            size: const Size(20, 20),
            painter: _XIconPainter(),
          ),
          onTap: () {},
        ),
      ],
    );
  }
}

/// Individual circular social button
class _SocialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _SocialButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.outlineLight, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painters for social icons
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width * 0.46;

    const colors = [
      Color(0xFFEA4335), // red   — top
      Color(0xFFFBBC05), // yellow — bottom-right
      Color(0xFF34A853), // green  — bottom-left
      Color(0xFF4285F4), // blue   — left
    ];

    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.butt;
      final startAngle = -math.pi / 2 + i * (math.pi / 2);
      canvas.drawArc(arcRect, startAngle, math.pi / 2 - 0.08, false, paint);
    }

    // Horizontal arm of the "G"
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx, cy - 1.6, r * 0.72, 3.2),
        const Radius.circular(2),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _XIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    canvas.drawLine(Offset(w * 0.08, h * 0.08), Offset(w * 0.92, h * 0.92), paint);
    canvas.drawLine(Offset(w * 0.92, h * 0.08), Offset(w * 0.08, h * 0.92), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
