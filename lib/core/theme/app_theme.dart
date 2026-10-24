import 'package:flutter/material.dart';

/// ============================================================
/// Shuk — Local Services Marketplace
/// Complete Mobile App Color System
/// Design Style: Material Design 3 (M3)
/// ============================================================
class AppTheme {
  // ========== DYNAMIC THEME STATE ==========
  static bool isDark = false;

  // ============================================================
  // 1. BRAND IDENTITY COLORS
  // ============================================================

  /// Primary brand color – main branding, primary buttons
  static const Color primary = Color(0xFF512DA8);

  /// Primary dark – splash screens, gradients
  static const Color primaryDark = Color(0xFF311B92);

  /// Primary light – hover states, selected items
  static const Color primaryLight = Color(0xFF7E57C2);

  /// Primary container – selected cards, containers
  static const Color primaryContainer = Color(0xFFEEEAF6);

  /// Secondary – promotions, highlights
  static const Color secondary = Color(0xFFFF9800);

  /// Secondary container – offer backgrounds
  static const Color secondaryContainer = Color(0xFFFFF3E0);

  /// Tertiary – information color
  static const Color tertiary = Color(0xFF2196F3);

  /// Tertiary container – info card backgrounds
  static const Color tertiaryContainer = Color(0xFFE3F2FD);

  // ============================================================
  // 2. PURPLE COLOR SCALE
  // ============================================================
  static const Color purple50  = Color(0xFFF3EEFF);
  static const Color purple100 = Color(0xFFE5DBFF);
  static const Color purple200 = Color(0xFFD1C4E9);
  static const Color purple300 = Color(0xFFB39DDB);
  static const Color purple400 = Color(0xFF9575CD);
  static const Color purple500 = Color(0xFF7E57C2);
  static const Color purple600 = Color(0xFF673AB7);
  static const Color purple700 = Color(0xFF512DA8);
  static const Color purple800 = Color(0xFF4527A0);
  static const Color purple900 = Color(0xFF311B92);

  // ============================================================
  // 3 & 4. BACKGROUND & SURFACE COLORS — DYNAMIC
  // ============================================================

  /// Scaffold / page background
  static Color get bgBase =>
      isDark ? const Color(0xFF121212) : const Color(0xFFF8F7FC);

  /// Default surface (cards, sheets, dialogs)
  static Color get bgSurface =>
      isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);

  /// Card background
  static Color get bgCard =>
      isDark ? const Color(0xFF242424) : const Color(0xFFFFFFFF);

  /// Bottom sheet background
  static Color get bgBottomSheet =>
      isDark ? const Color(0xFF202020) : const Color(0xFFFFFFFF);

  /// Dialog background
  static Color get bgDialog =>
      isDark ? const Color(0xFF242424) : const Color(0xFFFFFFFF);

  /// Drawer background
  static Color get bgDrawer =>
      isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);

  // ============================================================
  // TEXT COLORS — DYNAMIC
  // ============================================================

  static Color get textPrimary =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF212121);

  static Color get textSecondary =>
      isDark ? const Color(0xFFD1D5DB) : const Color(0xFF616161);

  static Color get textCaption =>
      isDark ? const Color(0xFFA1A1AA) : const Color(0xFF757575);

  static Color get textHint =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9E9E9E);

  static Color get textDisabled =>
      isDark ? const Color(0xFF6B7280) : const Color(0xFFBDBDBD);

  static const Color textWhite = Color(0xFFFFFFFF);

  // ============================================================
  // ICON COLORS — DYNAMIC
  // ============================================================

  static Color get iconPrimary =>
      isDark ? const Color(0xFF7E57C2) : const Color(0xFF512DA8);

  static Color get iconSecondary =>
      isDark ? const Color(0xFFD1D5DB) : const Color(0xFF757575);

  static Color get iconDisabled =>
      isDark ? const Color(0xFF6B7280) : const Color(0xFFBDBDBD);

  static const Color iconWhite = Color(0xFFFFFFFF);

  // ============================================================
  // DIVIDER & BORDER COLORS — DYNAMIC
  // ============================================================

  static Color get divider =>
      isDark ? const Color(0xFF2F2F2F) : const Color(0xFFEEEEEE);

  static Color get border =>
      isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB);

  // Convenience aliases
  static Color get outlineStrong => border;
  static Color get outlineBase   => border;
  static Color get outlineLight  => divider;
  static Color get outlineLighter => isDark ? const Color(0xFF2F2F2F) : const Color(0xFFF3F3F3);

  // ============================================================
  // 5. GRADIENT SYSTEM
  // ============================================================

  /// Primary Gradient — Splash, Hero Banner, Main CTA, Floating Button
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF512DA8), Color(0xFF7E57C2)],
  );

  /// Dark Gradient — Login, Welcome Screen
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF311B92), Color(0xFF512DA8)],
  );

  /// Background Gradient — Home Screen (Light)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF3EEFF)],
  );

  /// Background Gradient — Home Screen (Dark)
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
  );

  // ============================================================
  // 6. BUTTONS
  // ============================================================

  // Primary Button
  static const Color btnPrimaryNormal   = Color(0xFF512DA8);
  static const Color btnPrimaryHover    = Color(0xFF673AB7);
  static const Color btnPrimaryPressed  = Color(0xFF4527A0);
  static const Color btnPrimaryDisabled = Color(0xFFB39DDB);
  static const Color btnPrimaryText     = Color(0xFFFFFFFF);

  // Secondary Button (Light)
  static const Color btnSecondaryBg     = Color(0xFFFFFFFF);
  static const Color btnSecondaryBorder = Color(0xFF512DA8);
  static const Color btnSecondaryText   = Color(0xFF512DA8);

  // Secondary Button (Dark)
  static const Color btnSecondaryDarkBg     = Color(0xFF1E1E1E);
  static const Color btnSecondaryDarkBorder = Color(0xFF7E57C2);
  static const Color btnSecondaryDarkText   = Color(0xFF7E57C2);

  // ============================================================
  // 7. TEXT FIELD
  // ============================================================

  // Light
  static const Color inputBgLight         = Color(0xFFFFFFFF);
  static const Color inputBorderLight     = Color(0xFFD9D2F3);
  static const Color inputFocusLight      = Color(0xFF512DA8);
  static const Color inputErrorLight      = Color(0xFFF44336);
  static const Color inputPlaceholderLight = Color(0xFF9E9E9E);

  // Dark
  static const Color inputBgDark          = Color(0xFF1E1E1E);
  static const Color inputBorderDark      = Color(0xFF3A3A3A);
  static const Color inputFocusDark       = Color(0xFF7E57C2);
  static const Color inputErrorDark       = Color(0xFFEF5350);
  static const Color inputPlaceholderDark = Color(0xFF9CA3AF);

  // Dynamic helpers
  static Color get inputBg          => isDark ? inputBgDark : inputBgLight;
  static Color get inputBorderColor => isDark ? inputBorderDark : inputBorderLight;
  static Color get inputFocusColor  => isDark ? inputFocusDark : inputFocusLight;
  static Color get inputErrorColor  => isDark ? inputErrorDark : inputErrorLight;
  static Color get inputPlaceholder => isDark ? inputPlaceholderDark : inputPlaceholderLight;

  // ============================================================
  // 8. NAVIGATION
  // ============================================================

  // Bottom Navigation Light
  static const Color navBgLight       = Color(0xFFFFFFFF);
  static const Color navActiveLight   = Color(0xFF512DA8);
  static const Color navInactiveLight = Color(0xFF9CA3AF);

  // Bottom Navigation Dark
  static const Color navBgDark       = Color(0xFF1E1E1E);
  static const Color navActiveDark   = Color(0xFF7E57C2);
  static const Color navInactiveDark = Color(0xFF9CA3AF);

  static Color get navBg       => isDark ? navBgDark : navBgLight;
  static Color get navActive   => isDark ? navActiveDark : navActiveLight;
  static Color get navInactive => isDark ? navInactiveDark : navInactiveLight;

  // ============================================================
  // 9. CARDS
  // ============================================================

  // Light Cards
  static const Color cardBgLight       = Color(0xFFFFFFFF);
  static const Color cardSelectedLight = Color(0xFFEEEAF6);
  static const Color cardBorderLight   = Color(0xFFECECEC);

  // Dark Cards
  static const Color cardBgDark       = Color(0xFF242424);
  static const Color cardSelectedDark = Color(0xFF35235E);
  static const Color cardBorderDark   = Color(0xFF3A3A3A);

  static Color get cardBg       => isDark ? cardBgDark : cardBgLight;
  static Color get cardSelected => isDark ? cardSelectedDark : cardSelectedLight;
  static Color get cardBorder   => isDark ? cardBorderDark : cardBorderLight;

  // ============================================================
  // 10. STATUS COLORS
  // ============================================================
  static const Color statusSuccess = Color(0xFF4CAF50);
  static const Color statusWarning = Color(0xFFFFC107);
  static const Color statusError   = Color(0xFFF44336);
  static const Color statusInfo    = Color(0xFF2196F3);
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusOnline  = Color(0xFF00C853);
  static const Color statusOffline = Color(0xFF9E9E9E);

  // Convenience aliases
  static const Color success = statusSuccess;
  static const Color warning = statusWarning;
  static const Color error   = statusError;
  static const Color info    = statusInfo;

  // ============================================================
  // 11. BOOKING STATUS
  // ============================================================
  static const Color bookingPending    = Color(0xFFFFC107);
  static const Color bookingAccepted   = Color(0xFF4CAF50);
  static const Color bookingInProgress = Color(0xFF2196F3);
  static const Color bookingCompleted  = Color(0xFF512DA8);
  static const Color bookingCancelled  = Color(0xFFF44336);

  // ============================================================
  // 12. RATING COLORS
  // ============================================================
  static const Color starFilled = Color(0xFFFFC107);
  static const Color starEmpty  = Color(0xFFE0E0E0);

  // ============================================================
  // 13. PAYMENT COLORS
  // ============================================================
  static const Color paymentSuccess = Color(0xFF4CAF50);
  static const Color paymentFailed  = Color(0xFFF44336);
  static const Color paymentPending = Color(0xFFFFC107);

  // ============================================================
  // 14. NOTIFICATION COLORS
  // ============================================================
  static const Color notifMessage = Color(0xFF512DA8);
  static const Color notifBooking = Color(0xFF2196F3);
  static const Color notifPayment = Color(0xFF4CAF50);
  static const Color notifAlert   = Color(0xFFFFC107);

  // ============================================================
  // 15. SHADOW SYSTEM
  // ============================================================

  // Light shadows — purple-tinted
  static List<BoxShadow> get shadowSmall => isDark
      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 2))]
      : [BoxShadow(color: const Color(0xFF512DA8).withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))];

  static List<BoxShadow> get shadowMedium => isDark
      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 6))]
      : [BoxShadow(color: const Color(0xFF512DA8).withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 6))];

  static List<BoxShadow> get shadowLarge => isDark
      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.60), blurRadius: 30, offset: const Offset(0, 12))]
      : [BoxShadow(color: const Color(0xFF512DA8).withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 12))];

  // ============================================================
  // 17. BORDER RADIUS
  // ============================================================
  static const double radiusButton      = 16.0;
  static const double radiusCard        = 16.0;
  static const double radiusInput       = 14.0;
  static const double radiusBottomSheet = 24.0;
  static const double radiusDialog      = 20.0;
  static const double radiusChip        = 20.0;

  // ============================================================
  // 18. SPACING SYSTEM
  // ============================================================
  static const double spacingXS   = 4.0;
  static const double spacingS    = 8.0;
  static const double spacingM    = 16.0;
  static const double spacingL    = 24.0;
  static const double spacingXL   = 32.0;
  static const double spacingXXL  = 40.0;
  static const double spacingXXXL = 48.0;

  // ============================================================
  // DECORATION HELPERS
  // ============================================================

  /// Glass / frosted card decoration
  static BoxDecoration glassDecoration({
    BorderRadius? borderRadius,
    Color? borderColor,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? bgSurface.withValues(alpha: 0.8),
      borderRadius: borderRadius ?? BorderRadius.circular(radiusCard),
      border: Border.all(color: borderColor ?? border, width: 1.0),
    );
  }

  /// Standard surface decoration
  static BoxDecoration surfaceDecoration({
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? bgCard,
      borderRadius: borderRadius ?? BorderRadius.circular(radiusCard),
      border: Border.all(color: cardBorder, width: 1.0),
      boxShadow: shadowSmall,
    );
  }

  /// Primary-accent container decoration
  static BoxDecoration accentDecoration({BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: primary.withValues(alpha: 0.08),
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(color: primary.withValues(alpha: 0.2), width: 1.0),
    );
  }

  /// Gradient button / hero decoration
  static BoxDecoration gradientButtonDecoration({BorderRadius? borderRadius}) {
    return BoxDecoration(
      gradient: isDark ? darkGradient : primaryGradient,
      borderRadius: borderRadius ?? BorderRadius.circular(radiusButton),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Success state decoration
  static BoxDecoration successDecoration({BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: success.withValues(alpha: 0.08),
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(color: success.withValues(alpha: 0.2), width: 1.0),
    );
  }

  /// Error state decoration
  static BoxDecoration errorDecoration({BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: error.withValues(alpha: 0.08),
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(color: error.withValues(alpha: 0.2), width: 1.0),
    );
  }

  // ============================================================
  // LEGACY ALIASES (backward compatibility)
  // ============================================================
  static const Color primaryBrand   = primary;
  static const Color navy900        = primary;
  static const Color navy800        = Color(0xFF4527A0);
  static const Color accentViolet   = primary;
  static const Color accentAmber    = secondary;
  static const Color accentRed      = error;
  static const Color gold400        = secondary;
  static const Color gold500        = secondary;
  static const Color green500       = success;
  static const Color red500         = error;
  static const Color blue500        = tertiary;
  static const Color blueLight      = tertiaryContainer;
  static const Color amber500       = warning;
  static const Color purpleAccent   = primaryLight;

  // Text aliases (backward compatibility)
  static Color get textTertiary => textCaption;  // alias: renamed to textCaption in Shuk v2

  // Background aliases
  static Color get bgElevated   => bgCard;
  static Color get bgContainer  => isDark ? const Color(0xFF2F2F2F) : primaryContainer;

  // ============================================================
  // LIGHT THEME
  // ============================================================
  static ThemeData get lightTheme {
    return _buildThemeData(
      brightness:        Brightness.light,
      scaffoldBg:        const Color(0xFFF8F7FC),
      surfaceColor:      const Color(0xFFFFFFFF),
      cardColor:         const Color(0xFFFFFFFF),
      textColor:         const Color(0xFF212121),
      secondaryTextColor: const Color(0xFF616161),
      tertiaryTextColor:  const Color(0xFF757575),
      hintTextColor:     const Color(0xFF9E9E9E),
      borderColor:       const Color(0xFFE5E7EB),
      lighterBorderColor: const Color(0xFFEEEEEE),
      activeNavColor:    const Color(0xFF512DA8),
      inactiveNavColor:  const Color(0xFF9CA3AF),
      inputFillColor:    const Color(0xFFFFFFFF),
      inputBorderCol:    const Color(0xFFD9D2F3),
      focusBorderCol:    const Color(0xFF512DA8),
      errorBorderCol:    const Color(0xFFF44336),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================
  static ThemeData get darkTheme {
    return _buildThemeData(
      brightness:        Brightness.dark,
      scaffoldBg:        const Color(0xFF121212),
      surfaceColor:      const Color(0xFF1E1E1E),
      cardColor:         const Color(0xFF242424),
      textColor:         const Color(0xFFFFFFFF),
      secondaryTextColor: const Color(0xFFD1D5DB),
      tertiaryTextColor:  const Color(0xFFA1A1AA),
      hintTextColor:     const Color(0xFF9CA3AF),
      borderColor:       const Color(0xFF3A3A3A),
      lighterBorderColor: const Color(0xFF2F2F2F),
      activeNavColor:    const Color(0xFF7E57C2),
      inactiveNavColor:  const Color(0xFF9CA3AF),
      inputFillColor:    const Color(0xFF1E1E1E),
      inputBorderCol:    const Color(0xFF3A3A3A),
      focusBorderCol:    const Color(0xFF7E57C2),
      errorBorderCol:    const Color(0xFFEF5350),
    );
  }

  // ============================================================
  // SHARED THEME BUILDER
  // ============================================================
  static ThemeData _buildThemeData({
    required Brightness brightness,
    required Color scaffoldBg,
    required Color surfaceColor,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color tertiaryTextColor,
    required Color hintTextColor,
    required Color borderColor,
    required Color lighterBorderColor,
    required Color activeNavColor,
    required Color inactiveNavColor,
    required Color inputFillColor,
    required Color inputBorderCol,
    required Color focusBorderCol,
    required Color errorBorderCol,
  }) {
    final isLight = brightness == Brightness.light;

    final colorScheme = isLight
        ? ColorScheme.light(
            primary:          primary,
            onPrimary:        Colors.white,
            primaryContainer: primaryContainer,
            onPrimaryContainer: primary,
            secondary:        secondary,
            onSecondary:      Colors.white,
            secondaryContainer: secondaryContainer,
            onSecondaryContainer: const Color(0xFF212121),
            tertiary:         tertiary,
            onTertiary:       Colors.white,
            tertiaryContainer: tertiaryContainer,
            onTertiaryContainer: tertiary,
            surface:          surfaceColor,
            onSurface:        textColor,
            surfaceContainer: cardColor,
            error:            error,
            onError:          Colors.white,
          )
        : ColorScheme.dark(
            primary:          primaryLight,  // #7E57C2 in dark mode
            onPrimary:        Colors.white,
            primaryContainer: const Color(0xFF35235E),
            onPrimaryContainer: primaryLight,
            secondary:        secondary,
            onSecondary:      Colors.white,
            secondaryContainer: const Color(0xFF3D2600),
            onSecondaryContainer: const Color(0xFFFFF3E0),
            tertiary:         tertiary,
            onTertiary:       Colors.white,
            tertiaryContainer: const Color(0xFF0D3A5C),
            onTertiaryContainer: tertiaryContainer,
            surface:          surfaceColor,
            onSurface:        textColor,
            surfaceContainer: cardColor,
            error:            const Color(0xFFEF5350),
            onError:          Colors.white,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: colorScheme,

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: isLight ? primary : primaryLight),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,               // Section Title size from doc
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
          letterSpacing: -0.3,
        ),
      ),

      // ── Bottom Navigation Bar ────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isLight ? navBgLight : navBgDark,
        selectedItemColor: activeNavColor,
        unselectedItemColor: inactiveNavColor,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontFamily: 'Poppins',
        ),
        elevation: 8,
      ),

      // ── Text Theme (Poppins, sizes from doc) ─────────────────
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,               // Display — 32px
          fontWeight: FontWeight.w800,
          color: textColor,
          fontFamily: 'Poppins',
          letterSpacing: -1.0,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,               // App Title — 28px
          fontWeight: FontWeight.w700,
          color: textColor,
          fontFamily: 'Poppins',
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,               // Screen Title — 24px
          fontWeight: FontWeight.w700,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'Poppins',
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,               // Section Title — 20px
          fontWeight: FontWeight.w700,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        titleLarge: TextStyle(
          fontSize: 18,               // Card Title — 18px
          fontWeight: FontWeight.w700,
          color: textColor,
          fontFamily: 'Poppins',
          letterSpacing: 0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 16,               // Body — 16px
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Poppins',
          letterSpacing: 0.1,
        ),
        titleSmall: TextStyle(
          fontSize: 14,               // Caption — 14px
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,               // Body — 16px
          fontWeight: FontWeight.w400,
          color: textColor,
          fontFamily: 'Poppins',
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,               // Caption — 14px
          fontWeight: FontWeight.w400,
          color: secondaryTextColor,
          fontFamily: 'Poppins',
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,               // Label — 12px
          fontWeight: FontWeight.w400,
          color: tertiaryTextColor,
          fontFamily: 'Poppins',
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 12,               // Label — 12px
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: secondaryTextColor,
          fontFamily: 'Poppins',
        ),
      ),

      // ── Input Decoration ─────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        hintStyle: TextStyle(
          color: hintTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
        ),
        labelStyle: TextStyle(
          color: secondaryTextColor,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: inputBorderCol, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: inputBorderCol, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: focusBorderCol, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: errorBorderCol, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: errorBorderCol, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        isDense: false,
      ),

      // ── Elevated Button ───────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: activeNavColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isLight ? btnPrimaryDisabled : const Color(0xFF6B7280),
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingS + 6,  // ~14px
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: activeNavColor,
          side: BorderSide(color: activeNavColor, width: 1.5),
          backgroundColor: isLight ? btnSecondaryBg : btnSecondaryDarkBg,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingS + 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      // ── Text Button ───────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: activeNavColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusChip),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      // ── Chip ─────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? const Color(0xFFF3EEFF) : const Color(0xFF2F2F2F),
        selectedColor: activeNavColor.withValues(alpha: 0.15),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusChip),
        ),
        labelStyle: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
        secondaryLabelStyle: TextStyle(
          color: activeNavColor,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
        brightness: brightness,
      ),

      // ── Card ─────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(
            color: isLight ? cardBorderLight : cardBorderDark,
            width: 1.0,
          ),
        ),
      ),

      // ── Dialog ───────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: isLight ? bgDialog : const Color(0xFF242424),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDialog),
        ),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
        contentTextStyle: TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
      ),

      // ── Bottom Sheet ─────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? bgBottomSheet : const Color(0xFF202020),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusBottomSheet),
          ),
        ),
        elevation: 8,
      ),

      // ── Divider ───────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isLight ? const Color(0xFFEEEEEE) : const Color(0xFF2F2F2F),
        thickness: 1.0,
      ),

      // ── Switch ───────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return activeNavColor;
          return isLight ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return activeNavColor.withValues(alpha: 0.4);
          }
          return isLight ? const Color(0xFFE0E0E0) : const Color(0xFF3A3A3A);
        }),
      ),

      // ── Floating Action Button ────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusButton),
        ),
      ),

      // ── SnackBar ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? const Color(0xFF212121) : const Color(0xFFFFFFFF),
        contentTextStyle: TextStyle(
          color: isLight ? Colors.white : const Color(0xFF212121),
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
