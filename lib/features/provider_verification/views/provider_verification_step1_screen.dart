import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/mock_state_providers.dart';
import '../providers/provider_verification_provider.dart';
import 'widgets/verification_step_indicator.dart';

class ProviderVerificationStep1Screen extends ConsumerWidget {
  const ProviderVerificationStep1Screen({super.key});

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
          onPressed: () => context.go('/login'),
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
                      activeLang == 'am' ? 'ማንነትዎን ያረጋግጡ' : 'Verify Your Identity',
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
                          ? 'እባክዎ ለመረጋገጥ የሚከተሉትን ደረጃዎች ያጠናቅቁ።'
                          : 'Complete the steps below to get verified.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Step Indicator (Step 1 active)
                    const VerificationStepIndicator(currentStep: 1),

                    const SizedBox(height: 16),

                    // Card 1: National ID
                    _buildUploadCard(
                      context: context,
                      icon: Icons.badge_outlined,
                      title: activeLang == 'am' ? 'የብሔራዊ መታወቂያ ጫን' : 'Upload National ID',
                      subtitle: activeLang == 'am'
                          ? 'የብሔራዊ መታወቂያዎን ግልጽ ፎቶ ይጫኑ።'
                          : 'Upload a clear photo of your National ID.',
                      isUploaded: state.isNationalIdUploaded,
                      activeLang: activeLang,
                      onUploadPressed: () {
                        notifier.toggleNationalId();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.isNationalIdUploaded
                                  ? (activeLang == 'am' ? 'መታወቂያ ተሰርዟል' : 'National ID cleared')
                                  : (activeLang == 'am' ? 'መታወቂያ ተጫኗል!' : 'National ID uploaded!'),
                            ),
                            backgroundColor: state.isNationalIdUploaded ? AppTheme.error : AppTheme.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // Card 2: Selfie
                    _buildUploadCard(
                      context: context,
                      icon: Icons.person_outline_rounded,
                      title: activeLang == 'am' ? 'ሴልፊ ጫን' : 'Upload Selfie',
                      subtitle: activeLang == 'am'
                          ? 'ማንነትዎን ለማረጋገጥ ሴልፊ ፎቶ ያንሱ።'
                          : 'Take a selfie to verify your identity.',
                      isUploaded: state.isSelfieUploaded,
                      activeLang: activeLang,
                      onUploadPressed: () {
                        notifier.toggleSelfie();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.isSelfieUploaded
                                  ? (activeLang == 'am' ? 'ሴልፊ ተሰርዟል' : 'Selfie cleared')
                                  : (activeLang == 'am' ? 'ሴልፊ ተጫኗል!' : 'Selfie uploaded!'),
                            ),
                            backgroundColor: state.isSelfieUploaded ? AppTheme.error : AppTheme.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // Card 3: Certificates (Optional)
                    _buildUploadCard(
                      context: context,
                      icon: Icons.description_outlined,
                      title: activeLang == 'am' ? 'የምስክር ወረቀቶች (በምርጫ)' : 'Upload Certificates (Optional)',
                      subtitle: activeLang == 'am'
                          ? 'ከአገልግሎትዎ ጋር የተያያዘ ማንኛውንም የምስክር ወረቀት ያክሉ።'
                          : 'Add any certificate related to your services.',
                      isUploaded: state.isCertificateUploaded,
                      isOptional: true,
                      activeLang: activeLang,
                      onUploadPressed: () {
                        notifier.toggleCertificate();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.isCertificateUploaded
                                  ? (activeLang == 'am' ? 'የምስክር ወረቀት ተሰርዟል' : 'Certificate removed')
                                  : (activeLang == 'am' ? 'የምስክር ወረቀት ተጫኗል!' : 'Certificate uploaded!'),
                            ),
                            backgroundColor: AppTheme.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Button: Continue
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
                      if (!state.isNationalIdUploaded || !state.isSelfieUploaded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    activeLang == 'am'
                                        ? 'እባክዎ መታወቂያ እና ሴልፊ ይጫኑ'
                                        : 'Please upload National ID and Selfie to continue',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppTheme.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        return;
                      }
                      context.push('/provider-verification-step2');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      activeLang == 'am' ? 'ቀጥል' : 'Continue',
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

  Widget _buildUploadCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isUploaded,
    required String activeLang,
    required VoidCallback onUploadPressed,
    bool isOptional = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUploaded
              ? AppTheme.success.withValues(alpha: 0.4)
              : AppTheme.primaryContainer,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppTheme.success.withValues(alpha: 0.12)
                      : AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle_rounded : icon,
                  color: isUploaded ? AppTheme.success : AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onUploadPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: AppTheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isUploaded
                      ? (activeLang == 'am' ? 'ቀይር' : 'Change')
                      : (activeLang == 'am' ? 'ጫን' : 'Upload'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isUploaded ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 16,
                color: isUploaded ? AppTheme.success : AppTheme.textHint,
              ),
              const SizedBox(width: 6),
              Text(
                isUploaded
                    ? (activeLang == 'am' ? 'ተጫኗል' : 'Uploaded')
                    : (activeLang == 'am' ? 'አልተጫነም' : 'Not uploaded'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUploaded ? AppTheme.success : AppTheme.textHint,
                ),
              ),
              if (isOptional) ...[ 
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    activeLang == 'am' ? 'በምርጫ' : 'Optional',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
