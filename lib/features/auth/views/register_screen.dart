import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../../provider_onboarding/providers/provider_onboarding_provider.dart';
import 'auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // Step tracking: 'form' → 'verify'
  String _step = 'form';

  // Form fields
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // OTP step
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isVerifying = false;
  bool _resendCooldown = false;
  int _resendSeconds = 30;
  String _selectedRole = 'customer';

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ── Step 1: Submit form → send verification email ──────────────────────────
  Future<void> _submitForm(String activeLang) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    // Simulate sending verification email
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _step = 'verify';
    });

    // Animate transition to verify step
    _animCtrl.reset();
    _animCtrl.forward();

    // Start resend cooldown
    _startResendCooldown();

    // Auto-focus first OTP box
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _otpFocusNodes[0].requestFocus();
    });
  }

  // ── Step 2: Verify OTP → register & navigate ───────────────────────────────
  Future<void> _verifyCode(String activeLang) async {
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length < 6) {
      _showSnackBar(
        activeLang == 'am'
            ? 'እባክዎ ሙሉ 6-አሃዝ ኮዱን ያስገቡ'
            : 'Please enter all 6 digits of the code',
        isError: true,
      );
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final roleEnum =
        _selectedRole == 'provider' ? UserRole.provider : UserRole.customer;

    ref.read(authProvider.notifier).register(
          name: name,
          email: email,
          password: _passwordController.text,
          role: roleEnum,
        );

    if (_selectedRole == 'provider') {
      ref
          .read(providerOnboardingProvider.notifier)
          .updateProfileInfo(providerName: name);
    }

    ref.read(currentRoleProvider.notifier).setRole(_selectedRole);
    setState(() => _isVerifying = false);

    _showSnackBar(
      activeLang == 'am'
          ? 'ኢሜይልዎ ተረጋግጧል! እንኳን ደህና መጡ, $name 🎉'
          : 'Email verified! Welcome, $name 🎉',
      isError: false,
    );

    if (_selectedRole == 'provider') {
      context.go('/provider-verification-step1');
    } else {
      context.go('/home');
    }
  }

  // ── Resend verification code ────────────────────────────────────────────────
  Future<void> _resendCode(String activeLang) async {
    if (_resendCooldown) return;
    _showSnackBar(
      activeLang == 'am'
          ? 'የማረጋገጫ ኮድ ወደ ${_emailController.text.trim()} ተልኳል!'
          : 'Verification code resent to ${_emailController.text.trim()}!',
      isError: false,
    );
    // Clear existing OTP
    for (final c in _otpControllers) {
      c.clear();
    }
    _otpFocusNodes[0].requestFocus();
    _startResendCooldown();
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = true;
      _resendSeconds = 30;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendSeconds--);
      if (_resendSeconds <= 0) {
        setState(() => _resendCooldown = false);
        return false;
      }
      return true;
    });
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  // ── OTP digit input handler ─────────────────────────────────────────────────
  void _onOtpChanged(String val, int index) {
    if (val.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (val.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
    // Auto-verify when all 6 digits entered
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length == 6 && mounted) {
      final activeLang = ref.read(languageProvider);
      Future.delayed(const Duration(milliseconds: 200), () {
        _verifyCode(activeLang);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final l10n = AppLocalizations(Locale(activeLang));
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Wave Header ───────────────────────────────────────────────
            AuthHeaderWave(
              height: size.height * 0.24,
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.get('app_name'),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _step == 'verify'
                            ? (activeLang == 'am'
                                ? 'ኢሜይልዎን ያረጋግጡ'
                                : 'Verify your email address')
                            : (activeLang == 'am'
                                ? 'ይመዝገቡና አገልግሎቶችን ያግኙ'
                                : 'Create your account to get started'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Step Progress Indicator ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
              child: _StepIndicator(
                currentStep: _step == 'form' ? 0 : 1,
                activeLang: activeLang,
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _step == 'form'
                    ? _buildFormStep(context, activeLang, l10n)
                    : _buildVerifyStep(context, activeLang),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // STEP 1 — Registration Form
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildFormStep(
      BuildContext context, String activeLang, AppLocalizations l10n) {
    return Container(
      color: AppTheme.bgBase,
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeLang == 'am' ? 'መለያ ይፍጠሩ' : 'Sign Up',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 32,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => context.go('/login'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: Text(activeLang == 'am' ? 'ግባ' : 'Login'),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // 1. Full Name
            _FieldLabel(
                label: activeLang == 'am' ? 'ሙሉ ስም' : 'Full Name',
                icon: Icons.person_outline_rounded),
            const SizedBox(height: 8),
            _FormField(
              controller: _nameController,
              hintText:
                  activeLang == 'am' ? 'ሙሉ ስምዎን ያስገቡ' : 'e.g. Abel Abreham',
              prefixIcon: Icons.person_outline_rounded,
              textCapitalization: TextCapitalization.words,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return activeLang == 'am'
                      ? 'ሙሉ ስምዎን ያስገቡ'
                      : 'Please enter your full name';
                }
                if (val.trim().split(' ').length < 2) {
                  return activeLang == 'am'
                      ? 'የአባት ስምዎን ያካትቱ'
                      : 'Please include your last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // 2. Email
            _FieldLabel(
                label: activeLang == 'am' ? 'ኢሜይል' : 'Email Address',
                icon: Icons.mail_outline_rounded),
            const SizedBox(height: 8),
            _FormField(
              controller: _emailController,
              hintText: 'example@email.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return activeLang == 'am'
                      ? 'ኢሜይልዎን ያስገቡ'
                      : 'Please enter your email';
                }
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(val.trim())) {
                  return activeLang == 'am'
                      ? 'ትክክለኛ ኢሜይል ያስገቡ'
                      : 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // 3. Phone Number
            _FieldLabel(
                label: activeLang == 'am' ? 'ስልክ ቁጥር' : 'Phone Number',
                icon: Icons.phone_outlined),
            const SizedBox(height: 8),
            _FormField(
              controller: _phoneController,
              hintText: '9XX XXX XXX',
              prefixIcon: Icons.phone_outlined,
              prefixText: '+251 ',
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return activeLang == 'am'
                      ? 'ስልክ ቁጥርዎን ያስገቡ'
                      : 'Please enter your phone number';
                }
                if (val.trim().length < 9) {
                  return activeLang == 'am'
                      ? 'ትክክለኛ ስልክ ቁጥር ያስገቡ'
                      : 'Enter a valid 9-digit phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),

            // 4. Role Selector
            _FieldLabel(
                label:
                    activeLang == 'am' ? 'የመለያ ዓይነት' : 'Account Type',
                icon: Icons.badge_outlined),
            const SizedBox(height: 10),
            _RoleToggle(
              selectedRole: _selectedRole,
              activeLang: activeLang,
              onChanged: (role) => setState(() => _selectedRole = role),
            ),
            const SizedBox(height: 22),

            // 5. Password
            _FieldLabel(
                label: activeLang == 'am' ? 'የይለፍ ቃል' : 'Password',
                icon: Icons.lock_outline_rounded),
            const SizedBox(height: 8),
            _FormField(
              controller: _passwordController,
              hintText: activeLang == 'am'
                  ? 'ቢያንስ 6 ቁምፊዎች'
                  : 'At least 6 characters',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return activeLang == 'am'
                      ? 'የይለፍ ቃልዎን ያስገቡ'
                      : 'Please enter a password';
                }
                if (val.length < 6) {
                  return activeLang == 'am'
                      ? 'ቢያንስ 6 ቁምፊዎች ያስፈልጋሉ'
                      : 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // 6. Confirm Password
            _FieldLabel(
                label: activeLang == 'am'
                    ? 'የይለፍ ቃል ያረጋግጡ'
                    : 'Confirm Password',
                icon: Icons.lock_outline_rounded),
            const SizedBox(height: 8),
            _FormField(
              controller: _confirmPasswordController,
              hintText: activeLang == 'am'
                  ? 'የይለፍ ቃሉን ደግመው ያስገቡ'
                  : 'Re-enter your password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return activeLang == 'am'
                      ? 'የይለፍ ቃሉን ያረጋግጡ'
                      : 'Please confirm your password';
                }
                if (val != _passwordController.text) {
                  return activeLang == 'am'
                      ? 'የይለፍ ቃሎቹ አይዛመዱም'
                      : 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            _GradientButton(
              label: activeLang == 'am' ? 'ቀጥልና ኢሜይል አረጋግጥ' : 'Continue & Verify Email',
              icon: Icons.email_rounded,
              isLoading: _isLoading,
              onPressed: () => _submitForm(activeLang),
            ),
            const SizedBox(height: 28),

            AuthOrDivider(
              label: activeLang == 'am'
                  ? '- ወይም በዚህ ይመዝገቡ -'
                  : '- Or sign up with -',
            ),
            const SizedBox(height: 24),
            const AuthSocialRow(),
            const SizedBox(height: 28),

            // Sign in link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  activeLang == 'am'
                      ? 'መለያ አለዎት? '
                      : 'Already have an account? ',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text(
                    activeLang == 'am' ? 'ግቡ' : 'Sign in',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // STEP 2 — Email Verification
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildVerifyStep(BuildContext context, String activeLang) {
    final email = _emailController.text.trim();

    return Container(
      color: AppTheme.bgBase,
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            activeLang == 'am' ? 'ኢሜይልዎን ያረጋግጡ' : 'Verify Your Email',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 32, height: 3.5,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Email sent banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.purple200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mark_email_unread_rounded,
                      color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeLang == 'am'
                            ? 'የማረጋገጫ ኮድ ተልኳል'
                            : 'Verification Code Sent',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeLang == 'am'
                            ? 'ወደ $email 6-አሃዝ ማረጋገጫ ኮድ ተልኳል። ኮዱን ከዚህ በታች ያስገቡ።'
                            : 'A 6-digit verification code was sent to $email. Enter it below.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // OTP label
          Text(
            activeLang == 'am' ? '6-አሃዝ ኮዱን ያስገቡ' : 'Enter 6-Digit Code',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // OTP Input Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              return _OtpBox(
                controller: _otpControllers[i],
                focusNode: _otpFocusNodes[i],
                onChanged: (val) => _onOtpChanged(val, i),
                onBackspace: () {
                  if (_otpControllers[i].text.isEmpty && i > 0) {
                    _otpControllers[i - 1].clear();
                    _otpFocusNodes[i - 1].requestFocus();
                  }
                },
              );
            }),
          ),
          const SizedBox(height: 36),

          // Verify Button
          _GradientButton(
            label: activeLang == 'am' ? 'አረጋግጥ' : 'Verify & Continue',
            icon: Icons.verified_user_rounded,
            isLoading: _isVerifying,
            onPressed: () => _verifyCode(activeLang),
          ),
          const SizedBox(height: 24),

          // Resend + Back
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back to edit
              TextButton.icon(
                onPressed: () {
                  setState(() => _step = 'form');
                  _animCtrl.reset();
                  _animCtrl.forward();
                },
                icon: Icon(Icons.arrow_back_rounded,
                    size: 16, color: AppTheme.textSecondary),
                label: Text(
                  activeLang == 'am' ? 'ወደ ቅጹ ተመለስ' : 'Back to Form',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),

              // Resend code
              GestureDetector(
                onTap: _resendCooldown ? null : () => _resendCode(activeLang),
                child: _resendCooldown
                    ? Text(
                        activeLang == 'am'
                            ? 'ደግሞ ይላካል ($_resendSeconds ሰ)'
                            : 'Resend in ${_resendSeconds}s',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textCaption,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Text(
                        activeLang == 'am' ? 'ኮዱን ደግሞ ላክ' : 'Resend Code',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.primary,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step Progress Indicator
// ─────────────────────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final String activeLang;

  const _StepIndicator({required this.currentStep, required this.activeLang});

  @override
  Widget build(BuildContext context) {
    final steps = [
      activeLang == 'am' ? 'ዝርዝሮች' : 'Details',
      activeLang == 'am' ? 'ኢሜይል ማረጋገጫ' : 'Email Verify',
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIndex = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stepIndex < currentStep
                  ? AppTheme.primary
                  : AppTheme.divider,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isActive = stepIndex == currentStep;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? AppTheme.primary
                    : AppTheme.bgCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted || isActive
                      ? AppTheme.primary
                      : AppTheme.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? Colors.white
                              : AppTheme.textCaption,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[stepIndex],
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? AppTheme.primary
                    : AppTheme.textCaption,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTP Single Digit Box
// ─────────────────────────────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppTheme.inputBg,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppTheme.inputBorderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primary, width: 2.0),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient Submit Button
// ─────────────────────────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: isLoading
          ? Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.primary],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                ),
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primaryDark,
                    AppTheme.primary,
                    AppTheme.primaryLight
                  ],
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
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role Toggle — Customer / Provider
// ─────────────────────────────────────────────────────────────────────────────
class _RoleToggle extends StatelessWidget {
  final String selectedRole;
  final String activeLang;
  final ValueChanged<String> onChanged;

  const _RoleToggle({
    required this.selectedRole,
    required this.activeLang,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.inputBorderColor),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _RoleOption(
            label: activeLang == 'am' ? 'ደንበኛ' : 'Customer',
            icon: Icons.person_rounded,
            isSelected: selectedRole == 'customer',
            onTap: () => onChanged('customer'),
          ),
          _RoleOption(
            label: activeLang == 'am' ? 'ባለሙያ' : 'Service Provider',
            icon: Icons.engineering_rounded,
            isSelected: selectedRole == 'provider',
            onTap: () => onChanged('provider'),
          ),
        ],
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppTheme.textCaption),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field Label
// ─────────────────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FieldLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Validated Form Field
// ─────────────────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final String? prefixText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const _FormField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.prefixText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            TextStyle(fontSize: 13, color: AppTheme.inputPlaceholder),
        prefixText: prefixText,
        prefixStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary),
        prefixIcon:
            Icon(prefixIcon, size: 20, color: AppTheme.iconSecondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppTheme.inputBorderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppTheme.inputFocusColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.statusError, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.statusError, width: 1.8),
        ),
        errorStyle:
            TextStyle(fontSize: 11, color: AppTheme.statusError),
      ),
    );
  }
}
