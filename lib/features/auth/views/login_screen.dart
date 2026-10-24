import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../models/mock_accounts.dart';
import '../providers/auth_provider.dart';
import 'auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillAccount(MockAccount account) {
    setState(() {
      _emailController.text = account.email;
      _passwordController.text = account.password;
    });
  }

  Future<void> _signIn(String activeLang) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(
        activeLang == 'am'
            ? 'እባክዎ ኢሜይል እና የይለፍ ቃል ያስገቡ'
            : 'Please enter your email and password',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final account = MockAccounts.authenticate(email, password);

    if (account == null) {
      setState(() => _isLoading = false);
      _showSnackBar(
        activeLang == 'am'
            ? 'ኢሜይሉ ወይም የይለፍ ቃሉ ትክክል አይደለም'
            : 'Invalid email or password. Try a demo account.',
        isError: true,
      );
      return;
    }

    await ref.read(authProvider.notifier).login(email, password);

    if (!mounted) return;

    ref.read(currentRoleProvider.notifier).setRole(account.role);
    if (account.role == 'admin') {
      ref.read(currentRoleProvider.notifier).switchToAdmin();
    }

    setState(() => _isLoading = false);
    context.go(account.route);
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final l10n = AppLocalizations(Locale(activeLang));
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top Header Wave with topography lines ────────────────────────
            AuthHeaderWave(
              height: size.height * 0.32,
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.get('app_name'),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeLang == 'am' ? 'የአገልግሎት ማገናኛ' : 'Service Connection Platform',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom Form Sheet ────────────────────────────────────────────
            Container(
              color: AppTheme.bgBase,
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title "Sign in" with Accent Line Underneath
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeLang == 'am' ? 'ግባ' : 'Sign in',
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
                      // Back to Welcome button
                      TextButton.icon(
                        onPressed: () => context.go('/'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, size: 16),
                        label: Text(activeLang == 'am' ? 'ኋላ' : 'Back'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Demo accounts panel
                  _DemoAccountsPanel(
                    activeLang: activeLang,
                    onTap: _fillAccount,
                  ),
                  const SizedBox(height: 24),

                  // Email Field
                  AuthTextField(
                    controller: _emailController,
                    labelText: activeLang == 'am' ? 'ኢሜይል' : 'Email',
                    hintText: 'demo@email.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  AuthTextField(
                    controller: _passwordController,
                    labelText: activeLang == 'am' ? 'የይለፍ ቃል' : 'Password',
                    hintText: activeLang == 'am' ? 'የይለፍ ቃል ያስገቡ' : 'enter your password',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline_rounded,
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
                  ),
                  const SizedBox(height: 24),

                  // Remember Me Checkbox & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (val) {
                                setState(() {
                                  _rememberMe = val ?? false;
                                });
                              },
                              activeColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(
                                color: AppTheme.outlineBase,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            activeLang == 'am' ? 'አስታውሰኝ' : 'Remember Me',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          _showSnackBar(
                            activeLang == 'am'
                                ? 'የይለፍ ቃል መልሶ ማግኛ ኮድ ወደ ኢሜይልዎ ይላካል'
                                : 'Password reset link sent to your email',
                            isError: false,
                          );
                        },
                        child: Text(
                          activeLang == 'am' ? 'የይለፍ ቃል ረስተዋል?' : 'Forgot Password?',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Login Action
                  _isLoading
                      ? Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        )
                      : AuthPrimaryButton(
                          label: activeLang == 'am' ? 'ግባ' : 'Login',
                          onPressed: () => _signIn(activeLang),
                        ),
                  const SizedBox(height: 28),

                  // Or Divider
                  AuthOrDivider(
                    label: activeLang == 'am'
                        ? '- ወይም በዚህ ይግቡ -'
                        : '- Or sign in with -',
                  ),
                  const SizedBox(height: 24),

                  // Social Row
                  const AuthSocialRow(),
                  const SizedBox(height: 32),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        activeLang == 'am'
                            ? 'መለያ የለዎትም? '
                            : "Don't have an Account? ",
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(
                          activeLang == 'am' ? 'ይመዝገቡ' : 'Sign up',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Demo Accounts Quick Fill Panel ───────────────────────────────────────────
class _DemoAccountsPanel extends StatelessWidget {
  final String activeLang;
  final ValueChanged<MockAccount> onTap;

  const _DemoAccountsPanel({
    required this.activeLang,
    required this.onTap,
  });

  Color _accentFor(String role) {
    switch (role) {
      case 'provider':
        return AppTheme.success;
      case 'admin':
        return AppTheme.error;
      default:
        return AppTheme.secondary;
    }
  }

  String _roleLabel(String role, String lang) {
    if (lang == 'am') {
      switch (role) {
        case 'provider':
          return 'አቅራቢ';
        case 'admin':
          return 'አስተዳዳሪ';
        default:
          return 'ደንበኛ';
      }
    }
    switch (role) {
      case 'provider':
        return 'Provider';
      case 'admin':
        return 'Admin';
      default:
        return 'Customer';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              activeLang == 'am' ? 'ሙከራ መለያዎች — ለመሙላት ይንኩ' : 'Demo accounts — tap to fill',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: MockAccounts.all.map((account) {
            final accent = _accentFor(account.role);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: account == MockAccounts.all.last ? 0 : 8,
                ),
                child: _DemoCard(
                  account: account,
                  accent: accent,
                  roleLabel: _roleLabel(account.role, activeLang),
                  onTap: () => onTap(account),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DemoCard extends StatefulWidget {
  final MockAccount account;
  final Color accent;
  final String roleLabel;
  final VoidCallback onTap;

  const _DemoCard({
    required this.account,
    required this.accent,
    required this.roleLabel,
    required this.onTap,
  });

  @override
  State<_DemoCard> createState() => _DemoCardState();
}

class _DemoCardState extends State<_DemoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _ctrl.reverse();
    widget.onTap();
    await _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: widget.accent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.accent.withValues(alpha: 0.20),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.account.roleIcon,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.roleLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: widget.accent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.account.email,
                style: TextStyle(
                  fontSize: 9,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.account.password,
                style: TextStyle(
                  fontSize: 9,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
