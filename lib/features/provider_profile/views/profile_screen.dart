import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../home/models/provider_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../profile/views/customer_profile_screen.dart';
import '../../provider_onboarding/providers/provider_onboarding_provider.dart';
import '../../../core/router/nav_helpers.dart';

class ProviderProfileScreen extends ConsumerStatefulWidget {
  final String providerId;
  final bool isShell;

  const ProviderProfileScreen({
    super.key,
    required this.providerId,
    this.isShell = false,
  });

  @override
  ConsumerState<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final l10n = AppLocalizations(Locale(activeLang));
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    AppTheme.isDark = isDark;
    final activeRole = ref.watch(currentRoleProvider);
    final isOwnProfile = widget.providerId == 'current';

    // If it's a customer viewing their own profile
    if (isOwnProfile && activeRole == 'customer') {
      return const CustomerProfileScreen();
    }

    // Hide provider self profile UI while keeping the profile nav button visible
    if (isOwnProfile && activeRole == 'provider') {
      return _buildProviderSelfPlaceholder(context, l10n, activeLang);
    }

    final providers = ref.watch(providersListProvider);
    // Find provider
    final p = providers.firstWhere((item) => item.id == widget.providerId, orElse: () => ProviderModel.mockProviders[0]);

    return _buildProviderProfile(context, l10n, activeLang, p, activeRole);
  }

  // ── Edit Provider Profile Bottom Sheet ───────────────────────────────────
  void _showProviderEditProfileSheet(BuildContext context, String activeLang, ProviderModel p) {
    final nameController = TextEditingController(text: p.name);
    final phoneController = TextEditingController(text: p.id == 'p1' ? '+251922334455' : '');
    final bioController = TextEditingController(text: p.bio);
    final rateController = TextEditingController(text: p.hourlyRateEtb.toStringAsFixed(0));
    final specialtyController = TextEditingController(text: p.specialty);
    final specialtyAmController = TextEditingController(text: p.specialtyAmharic);
    final skillsController = TextEditingController(text: p.skills.join(', '));
    final addressController = TextEditingController(text: p.address ?? '');
    final qualificationsController = TextEditingController(text: p.qualifications ?? '');
    final coverageController = TextEditingController(text: p.coverageArea ?? '');
    final hoursController = TextEditingController(text: p.workingHours ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.bgBottomSheet,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title row with icon
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        activeLang == 'am' ? 'ባለሙያ መገለጫ አርትዕ' : 'Edit Provider Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeLang == 'am' ? 'መረጃዎን ያዘምኑ' : 'Update your profile information',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildSheetField(
                            label: activeLang == 'am' ? 'ሙሉ ስም' : 'Full Name',
                            controller: nameController,
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                          _buildSheetField(
                            label: activeLang == 'am' ? 'ስልክ ቁጥር' : 'Phone Number',
                            controller: phoneController,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildSheetField(
                            label: activeLang == 'am' ? 'ስለ እኔ' : 'Bio',
                            controller: bioController,
                            icon: Icons.edit_note_rounded,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSheetField(
                                  label: activeLang == 'am' ? 'የሰዓት ዋጋ (ETB)' : 'Hourly Rate (ETB)',
                                  controller: rateController,
                                  icon: Icons.monetization_on_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSheetField(
                                  label: activeLang == 'am' ? 'አድራሻ' : 'Address',
                                  controller: addressController,
                                  icon: Icons.location_on_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSheetField(
                            label: activeLang == 'am' ? 'ሙያ (English)' : 'Specialty (English)',
                            controller: specialtyController,
                            icon: Icons.work_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                          _buildSheetField(
                            label: activeLang == 'am' ? 'ሙያ (አማርኛ)' : 'Specialty (Amharic)',
                            controller: specialtyAmController,
                            icon: Icons.work_history_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildSheetField(
                            label: activeLang == 'am' ? 'ችሎታዎች (በኮማ የተለዩ)' : 'Skills (Comma separated)',
                            controller: skillsController,
                            icon: Icons.grade_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildSheetField(
                            label: activeLang == 'am' ? 'ማረጋገጫ/ብቃት' : 'Qualifications/Certifications',
                            controller: qualificationsController,
                            icon: Icons.workspace_premium_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildSheetField(
                            label: activeLang == 'am' ? 'የስራ ክልል' : 'Service Coverage Area',
                            controller: coverageController,
                            icon: Icons.map_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildSheetField(
                            label: activeLang == 'am' ? 'የስራ ሰዓት' : 'Working Hours / Availability',
                            controller: hoursController,
                            icon: Icons.access_time_rounded,
                          ),
                          const SizedBox(height: 28),
                          // Save Button — brand purple gradient
                          SizedBox(
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
                                icon: const Icon(Icons.check_circle_outline_rounded, size: 20, color: Colors.white),
                                label: Text(
                                  activeLang == 'am' ? 'አስቀምጥ' : 'Save Changes',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                onPressed: () async {
                                  final parsedRate = double.tryParse(rateController.text.trim()) ?? p.hourlyRateEtb;
                                  final parsedSkills = skillsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

                                  ref.read(providersListProvider.notifier).updateProviderProfile(
                                    providerId: p.id,
                                    name: nameController.text.trim(),
                                    bio: bioController.text.trim(),
                                    hourlyRate: parsedRate,
                                    skills: parsedSkills,
                                    specialty: specialtyController.text.trim(),
                                    specialtyAmharic: specialtyAmController.text.trim(),
                                    address: addressController.text.trim(),
                                    qualifications: qualificationsController.text.trim(),
                                    coverageArea: coverageController.text.trim(),
                                    workingHours: hoursController.text.trim(),
                                  );

                                  await ref.read(authProvider.notifier).updateProfile(
                                    name: nameController.text.trim(),
                                    phoneNumber: phoneController.text.trim(),
                                    bio: bioController.text.trim(),
                                  );

                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                            const SizedBox(width: 8),
                                            Text(
                                              activeLang == 'am'
                                                  ? 'የባለሙያ መገለጫ በተሳካ ሁኔታ ተቀይሯል!'
                                                  : 'Provider profile updated successfully!',
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppTheme.success,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
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
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }




  // ── Reusable Sheet Input Field ───────────────────────────────────────────
  Widget _buildSheetField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppTheme.primary.withValues(alpha: 0.7)),
            filled: true,
            fillColor: AppTheme.primaryContainer.withValues(alpha: 0.18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  // ── Change Password Sheet ────────────────────────────────────────────────
  void _showChangePasswordSheet(BuildContext context, String activeLang) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.outlineLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      activeLang == 'am' ? 'ይለፍ ቃል ቀይር' : 'Change Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _buildSheetField(
                            label: activeLang == 'am' ? 'የአሁኑ ይለፍ ቃል' : 'Current Password',
                            controller: currentPassCtrl,
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                          ),
                          const SizedBox(height: 14),
                          _buildSheetField(
                            label: activeLang == 'am' ? 'አዲስ ይለፍ ቃል' : 'New Password',
                            controller: newPassCtrl,
                            icon: Icons.lock_reset_rounded,
                            isPassword: true,
                          ),
                          const SizedBox(height: 14),
                          _buildSheetField(
                            label: activeLang == 'am' ? 'አዲስ ይለፍ ቃል አረጋግጥ' : 'Confirm New Password',
                            controller: confirmPassCtrl,
                            icon: Icons.check_circle_outline_rounded,
                            isPassword: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (currentPassCtrl.text.isEmpty ||
                                    newPassCtrl.text.isEmpty ||
                                    confirmPassCtrl.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        activeLang == 'am'
                                            ? 'እባክዎ ሁሉንም ሳጥኖች ይሙሉ'
                                            : 'Please fill all password fields',
                                      ),
                                      backgroundColor: AppTheme.error,
                                    ),
                                  );
                                  return;
                                }
                                if (newPassCtrl.text != confirmPassCtrl.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        activeLang == 'am'
                                            ? 'አዲስ ይለፍ ቃሎች አይመሳሰሉም'
                                            : 'New passwords do not match',
                                      ),
                                      backgroundColor: AppTheme.error,
                                    ),
                                  );
                                  return;
                                }
                                setSheetState(() => isSaving = true);
                                await Future.delayed(const Duration(milliseconds: 800));
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        activeLang == 'am'
                                            ? 'ይለፍ ቃልዎ በተሳካ ሁኔታ ተቀይሯል!'
                                            : 'Password updated successfully!',
                                      ),
                                      backgroundColor: AppTheme.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3814B3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                activeLang == 'am' ? 'ይለፍ ቃል ቀይር' : 'Update Password',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Provider Self Profile View ───────────────────────────────────────────
  Widget _buildProviderSelfPlaceholder(BuildContext context, AppLocalizations l10n, String activeLang) {
    final providers = ref.watch(providersListProvider);
    final provider = providers.firstWhere(
      (item) => item.id == 'p1',
      orElse: () => ProviderModel.mockProviders[0],
    );
    final onboardingState = ref.watch(providerOnboardingProvider);

    final authUser = ref.watch(authProvider).asData?.value;
    final displayName = authUser?.name ?? (onboardingState.providerName.isNotEmpty ? onboardingState.providerName : 'Abel Abreham');
    final displayEmoji = onboardingState.profileEmoji.isNotEmpty ? onboardingState.profileEmoji : provider.emoji;
    final displayCategory = onboardingState.serviceCategory.isNotEmpty ? onboardingState.serviceCategory : provider.specialty;
    final displayLocation = onboardingState.locationAddress.isNotEmpty ? onboardingState.locationAddress : (provider.address ?? 'Bole, Addis Ababa');
    final displayRate = onboardingState.hourlyRateEtb > 0 ? onboardingState.hourlyRateEtb : provider.hourlyRateEtb;
    final displayBio = onboardingState.aboutText.isNotEmpty ? onboardingState.aboutText : provider.bio;
    final displaySkills = [
      if (onboardingState.skills.isNotEmpty) ...onboardingState.skills else ...provider.skills,
      if (onboardingState.certifications.isNotEmpty) ...onboardingState.certifications,
    ];

    return Scaffold(
      backgroundColor: AppTheme.isDark ? const Color(0xFF1E1435) : AppTheme.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Deep Purple Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                    onPressed: () => ProviderNavHelper.go(context, ref, tab: 0),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activeLang == 'am' ? 'የእኔ መገለጫ' : 'My Provider Profile',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
                    onPressed: () => _showProviderEditProfileSheet(context, activeLang, provider),
                  ),
                ],
              ),
            ),

            // ── Rounded White Content Sheet ───────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.bgBase,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Profile Card (Avatar + Info) ───────────────────
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.bgSurface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppTheme.outlineLighter),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.isDark ? AppTheme.primary.withValues(alpha: 0.25) : const Color(0xFFEDE7F6),
                                      border: Border.all(color: AppTheme.primary, width: 2),
                                    ),
                                    child: Center(
                                      child: Text(displayEmoji, style: const TextStyle(fontSize: 34)),
                                    ),
                                  ),
                                  if (provider.isOnline)
                                    Positioned(
                                      right: 2,
                                      bottom: 2,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2E7D32),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            displayName,
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (provider.verificationStatus == VerificationStatus.verified)
                                          Icon(Icons.verified_rounded, color: AppTheme.primary, size: 20),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      displayCategory,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.isDark ? AppTheme.primaryLight : const Color(0xFFE65100),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_rounded, size: 14, color: AppTheme.textSecondary),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            displayLocation,
                                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                            overflow: TextOverflow.ellipsis,
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

                        const SizedBox(height: 18),

                        // ── Stats Grid Chips ───────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _buildSelfStatTile(
                                label: activeLang == 'am' ? 'የተሰሩ ስራዎች' : 'Jobs Done',
                                value: '${provider.jobsCount}+',
                                color: AppTheme.primary,
                                icon: Icons.work_history_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSelfStatTile(
                                label: activeLang == 'am' ? 'ደረጃ' : 'Rating',
                                value: '${provider.rating} ★',
                                color: const Color(0xFFF9A825),
                                icon: Icons.star_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSelfStatTile(
                                label: activeLang == 'am' ? 'የሰዓት ዋጋ' : 'Hourly Rate',
                                value: '${displayRate.toInt()} ETB',
                                color: const Color(0xFF2E7D32),
                                icon: Icons.payments_rounded,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ── Bio Section ────────────────────────────────────
                        Text(
                          activeLang == 'am' ? 'ስለ እኔ' : 'About Me',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.bgSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.outlineLighter),
                          ),
                          child: Text(
                            displayBio,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ── Skills & Certifications ────────────────────────
                        Text(
                          activeLang == 'am' ? 'ችሎታዎች እና ማረጋገጫዎች' : 'Skills & Certifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: displaySkills.map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.outlineLight),
                              ),
                              child: Text(
                                skill,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // ── Account Settings & Actions ─────────────────────
                        Text(
                          activeLang == 'am' ? 'የመለያ ቅንብሮች' : 'Account & Actions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.bgSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.outlineLighter),
                          ),
                          child: Column(
                            children: [
                              _buildSelfMenuOption(
                                icon: Icons.edit_note_rounded,
                                iconColor: AppTheme.primary,
                                title: activeLang == 'am' ? 'መገለጫ አርትዕ' : 'Edit Profile Information',
                                subtitle: activeLang == 'am' ? 'ስም፣ ስልክ፣ bio እና ዋጋ ይለውጡ' : 'Update name, bio, rate & skills',
                                onTap: () => _showProviderEditProfileSheet(context, activeLang, provider),
                              ),
                              Divider(height: 1, indent: 56, color: AppTheme.outlineLighter),
                              _buildSelfMenuOption(
                                icon: Icons.lock_reset_rounded,
                                iconColor: AppTheme.primary,
                                title: activeLang == 'am' ? 'ይለፍ ቃል ቀይር' : 'Change Password',
                                subtitle: activeLang == 'am' ? 'የመለያ ይለፍ ቃልዎን ያዘምኑ' : 'Update account password',
                                onTap: () => _showChangePasswordSheet(context, activeLang),
                              ),
                              Divider(height: 1, indent: 56, color: AppTheme.outlineLighter),
                              // Language Toggle item
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.language_rounded, color: AppTheme.primary, size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        activeLang == 'am' ? 'ቋንቋ' : 'Language',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        ref.read(languageProvider.notifier).setLanguage(
                                          activeLang == 'am' ? 'en' : 'am',
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppTheme.outlineLight),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              activeLang == 'am' ? '🇪🇹 አማርኛ' : '🇺🇸 English',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(Icons.swap_horiz_rounded, size: 16, color: AppTheme.primary),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 1, indent: 56, color: AppTheme.outlineLighter),
                              // Dark Mode Toggle item
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: AppTheme.isDark
                                            ? AppTheme.primaryLight.withValues(alpha: 0.2)
                                            : AppTheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        AppTheme.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                        color: const Color(0xFFFFB300),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activeLang == 'am' ? 'ጨለማ ገጽታ (Dark Mode)' : 'Dark Mode',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            activeLang == 'am' ? 'የገጽታውን ቀለም ይቀይሩ' : 'Switch between light and dark theme',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: AppTheme.isDark,
                                      activeColor: AppTheme.primaryLight,
                                      onChanged: (val) {
                                        ref.read(themeModeProvider.notifier).setThemeMode(
                                          val ? ThemeMode.dark : ThemeMode.light,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),



                        const SizedBox(height: 16),

                        // Sign Out Button
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppTheme.bgSurface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.logout_rounded, color: Colors.red, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      activeLang == 'am' ? 'ውጣ' : 'Sign Out',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  activeLang == 'am'
                                      ? 'ከመለያዎ መውጣት ይፈልጋሉ?'
                                      : 'Are you sure you want to sign out?',
                                  style: TextStyle(color: AppTheme.textSecondary),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: Text(
                                      activeLang == 'am' ? 'ይቅር' : 'Cancel',
                                      style: TextStyle(color: Color(0xFF757575)),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      ref.read(authProvider.notifier).logout();
                                      context.go('/login');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      activeLang == 'am' ? 'ውጣ' : 'Sign Out',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  activeLang == 'am' ? 'ከመለያው ውጣ' : 'Sign Out',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.isShell
          ? null
          : ShukBottomNavBar(
              currentIndex: 4,
              activeRole: 'provider',
              activeLang: activeLang,
            ),
    );
  }

  Widget _buildSelfStatTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineLighter),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSelfMenuOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }



  Widget _buildProviderProfile(
    BuildContext context,
    AppLocalizations l10n,
    String activeLang,
    ProviderModel p,
    String activeRole,
  ) {
    final isOwnProfile = widget.providerId == 'current';
    final experience = _providerExperience[p.id] ?? '5 yrs';

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      body: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // ── 1. Top Purple Header Banner ──────────────────────────────────
            Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppTheme.isDark
                      ? const [
                          Color(0xFF1E1435),
                          Color(0xFF2E1C4D),
                        ]
                      : const [
                          Color(0xFF512DA8),
                          Color(0xFF7E57C2),
                        ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back arrow button
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          if (isOwnProfile) {
                            ProviderNavHelper.go(context, ref, tab: 0);
                          } else {
                            CustomerNavHelper.go(context, ref, tab: 0);
                          }
                        },
                      ),
                      // Action buttons: Share & Favorite
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.share_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    activeLang == 'am'
                                        ? 'የባለሙያ መገለጫ ሊንክ ተቀድቷል!'
                                        : 'Provider profile link copied!',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: _isFavorite ? Colors.redAccent : Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── 2. White Card Content Sheet ──────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 120),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Header Info (Name, Badge, Specialty, Location)
                  Center(
                    child: Column(
                      children: [
                        // Name + Verification Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              p.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (p.verificationStatus == VerificationStatus.verified) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.verified_rounded,
                                color: AppTheme.secondary,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Specialty Title
                        Text(
                          activeLang == 'am' ? p.specialtyAmharic : p.specialty,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Location & Availability Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: AppTheme.textTertiary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              p.address ?? 'Bole, Addis Ababa',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: p.isOnline ? AppTheme.success : AppTheme.textTertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              p.isOnline
                                  ? (activeLang == 'am' ? 'አሁን ይገኛል' : 'Available Now')
                                  : (activeLang == 'am' ? 'ከመስመር ውጭ' : 'Offline'),
                              style: TextStyle(
                                color: p.isOnline ? AppTheme.success : AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Stats Grid Cards
                  Row(
                    children: [
                      _buildQuickStatCard(
                        title: '${p.rating} ★',
                        titleColor: AppTheme.statusWarning,
                        subtitle: activeLang == 'am' ? '128 ግምገማዎች' : '128 reviews',
                      ),
                      const SizedBox(width: 12),
                      _buildQuickStatCard(
                        title: '${p.jobsCount}+',
                        titleColor: AppTheme.textPrimary,
                        subtitle: activeLang == 'am' ? 'የተሰሩ ስራዎች' : 'Jobs Done',
                      ),
                      const SizedBox(width: 12),
                      _buildQuickStatCard(
                        title: experience,
                        titleColor: AppTheme.textPrimary,
                        subtitle: activeLang == 'am' ? 'የስራ ልምድ' : 'Experience',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // About Provider Section
                  Text(
                    activeLang == 'am' ? 'ስለ ባለሙያው' : 'About Provider',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(16),
                    child: Text(
                      p.bio,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Specialties Tags Section
                  Text(
                    activeLang == 'am' ? 'ልዩ ሙያዎች' : 'Specialties',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.outlineLight,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Recent Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activeLang == 'am' ? 'የደንበኞች አስተያየት' : 'Recent Reviews',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        activeLang == 'am' ? 'ሁሉንም እይ' : 'View All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.statusWarning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 2,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final reviewers = ['Abel Abreham', 'Sara Haile'];
                      final comments = [
                        activeLang == 'am'
                            ? 'በጣም ምርጥ የኤሌክትሪክ ሰራተኛ ነው! ስራውን በቅንነት እና በፍጥነት አጠናቆልናል።'
                            : 'Outstanding and neat work! Fixed all issues perfectly and arrived exactly on time.',
                        activeLang == 'am'
                            ? 'ፈጣን ምላሽ ሰጭ እና በጣም ታማኝ ሰው ነው።'
                            : 'Very professional and highly experienced. Responded very quickly to our booking.',
                      ];
                      return GlassCard(
                        padding: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppTheme.secondary.withValues(alpha: 0.2),
                                      child: Text(
                                        reviewers[index][0],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reviewers[index],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          '2 days ago',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: AppTheme.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      Icons.star_rounded,
                                      color: AppTheme.statusWarning,
                                      size: 12,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              comments[index],
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── 3. Overlapping Circular Avatar ─────────────────────────────
            Positioned(
              top: 72,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.purple100,
                      border: Border.all(
                        color: AppTheme.isDark ? AppTheme.bgSurface : Colors.white,
                        width: 4.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        p.emoji,
                        style: TextStyle(fontSize: 44),
                      ),
                    ),
                  ),
                  if (p.isOnline)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFF26A69A),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.bgSurface,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isOwnProfile
          ? (widget.isShell
              ? null
              : ShukBottomNavBar(
                  currentIndex: 4,
                  activeRole: activeRole,
                  activeLang: activeLang,
                ))
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface.withValues(alpha: 0.98),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.outlineLighter,
                    width: 1.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Price Estimate Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          activeLang == 'am' ? 'የዋጋ ግምት' : 'Price Estimate',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${p.hourlyRateEtb.toInt()} ETB ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.isDark ? AppTheme.primaryLight : const Color(0xFF512DA8),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              TextSpan(
                                text: activeLang == 'am' ? '/ በሰዓት' : '/ hr',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Action Buttons Row (Message & Book Now matching reference image)
                    Row(
                      children: [
                        // Message Button (Outlined Purple)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/chat'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppTheme.bgSurface,
                              foregroundColor: AppTheme.primary,
                              side: BorderSide(color: AppTheme.primary, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            icon: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 18,
                              color: AppTheme.primary,
                            ),
                            label: Text(
                              activeLang == 'am' ? 'መልእክት' : 'Message',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Book Now Button (Solid Purple)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/booking-checkout?providerId=${p.id}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.isDark ? AppTheme.primaryLight : AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(
                              Icons.calendar_today_rounded,
                              size: 17,
                              color: Colors.white,
                            ),
                            label: Text(
                              activeLang == 'am' ? 'አሁን ያዝ' : 'Book Now',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickStatCard({
    required String title,
    required Color titleColor,
    required String subtitle,
  }) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppTheme.textTertiary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


const Map<String, String> _providerExperience = {
  'p1': '8 yrs',
  'p2': '5 yrs',
  'p3': '6 yrs',
  'p4': '4 yrs',
};

