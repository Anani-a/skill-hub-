import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Glass card with blur effect - primary container component
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double? elevation;
  final BoxShadow? customShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.elevation,
    this.customShadow,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusCard);
    final effectivePadding = widget.padding ?? const EdgeInsets.all(AppTheme.spacingM);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isHovered ? 1.015 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppTheme.bgElevated,
          borderRadius: effectiveRadius,
          border: Border.all(
            color: _isHovered
                ? AppTheme.primary.withValues(alpha: 0.35)
                : (widget.borderColor ?? AppTheme.outlineLight),
            width: 1.0,
          ),
          boxShadow: widget.customShadow != null
              ? [widget.customShadow!]
              : (_isHovered
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : AppTheme.shadowSmall),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: effectiveRadius,
            splashColor: AppTheme.primary.withValues(alpha: 0.1),
            highlightColor: AppTheme.primary.withValues(alpha: 0.05),
            child: Padding(
              padding: effectivePadding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient button with glow effect
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final FontWeight? fontWeight;
  final double? fontSize;
  final IconData? icon;
  final MainAxisAlignment? mainAxisAlignment;
  final Color? textColor;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.fontWeight,
    this.fontSize,
    this.icon,
    this.mainAxisAlignment,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 48,
      decoration: AppTheme.gradientButtonDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor ?? Colors.white, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontWeight: fontWeight ?? FontWeight.w600,
                    fontSize: fontSize ?? 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Category chip for service selection (Fancy pill/capsule style, no icons)
class CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.label,
    this.icon,
    this.iconColor,
    required this.backgroundColor,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      backgroundColor,
                      backgroundColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected
                ? null
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? backgroundColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Professional/Provider card with image
class ProfessionalCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final String priceLabel;
  final String price;
  final String currency;
  final ImageProvider? profileImage;
  final VoidCallback? onBook;
  final VoidCallback? onViewDetail;
  final String? viewDetailLabel;
  final bool isVerified;
  final double? distance;

  const ProfessionalCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.priceLabel,
    required this.price,
    required this.currency,
    this.profileImage,
    this.onBook,
    this.onViewDetail,
    this.viewDetailLabel,
    this.isVerified = true,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: GlassCard(
        borderRadius: BorderRadius.circular(20),
        padding: EdgeInsets.zero,
        backgroundColor: AppTheme.bgElevated.withValues(alpha: 0.85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            SizedBox(
              height: 144,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: profileImage != null
                          ? DecorationImage(
                              image: profileImage!,
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: AppTheme.bgSurface,
                    ),
                    child: profileImage == null
                        ? const Center(
                            child: Icon(Icons.person, size: 48),
                          )
                        : null,
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Rating badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppTheme.starFilled,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and verification
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (isVerified)
                        const Icon(
                          Icons.verified,
                          color: AppTheme.accentViolet,
                          size: 14,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Specialty
                  Text(
                    specialty,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (distance != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${distance!.toStringAsFixed(1)} km away',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Price and button
                  // Price details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            priceLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$price $currency',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Actions row (Side by Side)
                  Row(
                    children: [
                      if (onViewDetail != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onViewDetail,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(
                                color: AppTheme.outlineLight,
                                width: 1.2,
                              ),
                              foregroundColor: AppTheme.textPrimary,
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              viewDetailLabel ?? 'View Detail',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: GradientButton(
                          text: 'Book Now',
                          onPressed: onBook ?? () {},
                          height: 36,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon button with glass effect
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppTheme.textSecondary,
            size: size ?? 18,
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    }
    return button;
  }
}
