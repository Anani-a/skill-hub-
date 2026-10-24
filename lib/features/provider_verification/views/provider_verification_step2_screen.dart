import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/mock_state_providers.dart';
import '../providers/provider_verification_provider.dart';
import 'widgets/verification_step_indicator.dart';

class ProviderVerificationStep2Screen extends ConsumerWidget {
  const ProviderVerificationStep2Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLang = ref.watch(languageProvider);
    final state = ref.watch(providerVerificationProvider);
    final notifier = ref.read(providerVerificationProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: AppTheme.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Subtitle
                    Text(
                      activeLang == 'am' ? 'መረጃዎን ያረጋግጡ' : 'Review Your Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activeLang == 'am'
                          ? 'እባክዎ ከመላክዎ በፊት ሰነዶችዎን እንደገና ያረጋግጡ።'
                          : 'Please review your documents before submitting.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Step Indicator (Step 2 active)
                    const VerificationStepIndicator(currentStep: 2),

                    const SizedBox(height: 16),

                    // 1. National ID Review Card
                    _buildReviewDocCard(
                      context: context,
                      title: activeLang == 'am' ? 'የብሔራዊ መታወቂያ' : 'National ID',
                      isUploaded: state.isNationalIdUploaded,
                      activeLang: activeLang,
                      previewWidget: _buildMockNationalIdGraphic(),
                      onClear: () {
                        notifier.toggleNationalId();
                        context.pop();
                      },
                      onChange: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              activeLang == 'am' ? 'አዲስ መታወቂያ ይምረጡ' : 'Select new National ID photo',
                            ),
                            backgroundColor: AppTheme.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // 2. Selfie Review Card
                    _buildReviewDocCard(
                      context: context,
                      title: activeLang == 'am' ? 'ሴልፊ' : 'Selfie',
                      isUploaded: state.isSelfieUploaded,
                      activeLang: activeLang,
                      previewWidget: _buildMockSelfieGraphic(),
                      onClear: () {
                        notifier.toggleSelfie();
                        context.pop();
                      },
                      onChange: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              activeLang == 'am' ? 'አዲስ ሴልፊ ያንሱ' : 'Take a new selfie photo',
                            ),
                            backgroundColor: AppTheme.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // 3. Certificate Review Card
                    if (state.isCertificateUploaded) ...[
                      _buildReviewDocCard(
                        context: context,
                        title: activeLang == 'am' ? 'የምስክር ወረቀቶች (በምርጫ)' : 'Certificates (Optional)',
                        isUploaded: true,
                        activeLang: activeLang,
                        previewWidget: _buildMockCertificateGraphic(),
                        onChange: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                activeLang == 'am' ? 'ምስክር ወረቀት ይለውጡ' : 'Change certificate document',
                              ),
                              backgroundColor: AppTheme.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Under Review Info Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.purple200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.verified_user_outlined,
                              color: AppTheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              activeLang == 'am'
                                  ? 'ማረጋገጫዎ በግምገማ ላይ ነው። እንደጸደቀ እናሳውቅዎታለን።'
                                  : 'Your verification is under review. We will notify you once approved.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Button: Submit for Review
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
                  child: ElevatedButton(
                    onPressed: () {
                      notifier.submitForReview();
                      context.push('/provider-verification-status');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      activeLang == 'am' ? 'ለግምገማ አስገባ' : 'Submit for Review',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildReviewDocCard({
    required BuildContext context,
    required String title,
    required bool isUploaded,
    required String activeLang,
    required Widget previewWidget,
    VoidCallback? onClear,
    required VoidCallback onChange,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUploaded ? AppTheme.success.withValues(alpha: 0.35) : AppTheme.primaryContainer,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          previewWidget,
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          if (onClear != null) ...[
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                activeLang == 'am' ? 'ሰርዝ' : 'Clear',
                style: TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          TextButton(
            onPressed: onChange,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              activeLang == 'am' ? 'ቀይር' : 'Change',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockNationalIdGraphic() {
    return Container(
      width: 72,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.purple200),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              width: 20,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ),
          Positioned(
            top: 8,
            left: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 30, height: 4, color: AppTheme.primary),
                const SizedBox(height: 3),
                Container(width: 22, height: 3, color: AppTheme.primaryLight),
                const SizedBox(height: 3),
                Container(width: 26, height: 3, color: AppTheme.primaryLight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockSelfieGraphic() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryContainer,
        border: Border.all(color: AppTheme.primary, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          color: AppTheme.purple200,
          child: Icon(Icons.face_rounded, size: 36, color: AppTheme.primary),
        ),
      ),
    );
  }

  Widget _buildMockCertificateGraphic() {
    return Container(
      width: 50,
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Icon(Icons.card_membership_rounded, size: 28, color: AppTheme.secondary),
      ),
    );
  }
}
