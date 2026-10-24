import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/mock_state_providers.dart';
import 'widgets/verification_step_indicator.dart';

class ProviderVerificationStatusScreen extends ConsumerWidget {
  const ProviderVerificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: AppTheme.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          activeLang == 'am' ? 'የማረጋገጫ ሁኔታ' : 'Verification Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper (Step 3 active / Approved)
            const VerificationStepIndicator(currentStep: 3),

            Expanded(
              child: Stack(
                children: [
                  // Confetti decorative shapes background
                  ..._buildConfettiDecorations(),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Large Success Badge Circle — brand purple
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryDark, AppTheme.primary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.35),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: Colors.white,
                              size: 52,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Congratulations Heading
                          Text(
                            activeLang == 'am' ? 'እንኳን ደስ አለዎት!' : 'Congratulations!',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            activeLang == 'am'
                              ? 'አሁን የተረጋገጡ ባለሙያ ሆነዋል።'
                              : 'You are now a verified provider.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 18),

                          // Verified Chip Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryDark, AppTheme.primary],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  activeLang == 'am' ? 'ተረጋግጧል' : 'Verified Provider',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Info card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryContainer,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.purple200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    activeLang == 'am'
                                        ? 'አሁን አገልግሎቶችዎን ማከል መጀመር ይችላሉ'
                                        : 'You can now start adding your services',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Action Button: Continue
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.primaryLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    label: Text(
                      activeLang == 'am' ? 'ቀጥል' : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      context.push('/provider-onboarding-profile');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  List<Widget> _buildConfettiDecorations() {
    // Use brand palette colors for confetti — purple, orange, blue, light purple
    return [
      Positioned(top: 30,  left: 40,   child: _confettiDot(AppTheme.primary,      8)),
      Positioned(top: 60,  right: 50,  child: _confettiDot(AppTheme.secondary,    10)),
      Positioned(top: 90,  left: 90,   child: _confettiDot(AppTheme.primaryLight,  7)),
      Positioned(top: 120, right: 80,  child: _confettiDot(AppTheme.purple400,     9)),
      Positioned(top: 150, left: 30,   child: _confettiDot(AppTheme.tertiary,      8)),
      Positioned(top: 180, right: 30,  child: _confettiDot(AppTheme.secondary,    10)),
      Positioned(bottom: 120, left: 50,  child: _confettiDot(AppTheme.primaryDark,  8)),
      Positioned(bottom: 90,  right: 60, child: _confettiDot(AppTheme.tertiary,     9)),
      Positioned(bottom: 140, right: 100,child: _confettiDot(AppTheme.purple300,    7)),
    ];
  }

  Widget _confettiDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
    );
  }
}
