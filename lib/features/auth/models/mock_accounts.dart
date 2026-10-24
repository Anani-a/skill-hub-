// ─────────────────────────────────────────────────────────────────────────────
// Mock Accounts — used for demo login
// Each account maps to a role and destination route
// ─────────────────────────────────────────────────────────────────────────────

class MockAccount {
  final String email;
  final String password;
  final String role;
  final String nameEn;
  final String nameAm;
  final String route;
  final String roleIcon;

  const MockAccount({
    required this.email,
    required this.password,
    required this.role,
    required this.nameEn,
    required this.nameAm,
    required this.route,
    required this.roleIcon,
  });
}

class MockAccounts {
  static const List<MockAccount> all = [
    MockAccount(
      email: 'customer@shuk.et',
      password: 'customer123',
      role: 'customer',
      nameEn: 'Abel Abreham',
      nameAm: 'አቤል አብርሃም',
      route: '/home',
      roleIcon: '👤',
    ),
    MockAccount(
      email: 'provider@shuk.et',
      password: 'provider123',
      role: 'provider',
      nameEn: 'Dawit Bekele',
      nameAm: 'ዳዊት በቀለ',
      route: '/provider-dashboard',
      roleIcon: '🔧',
    ),
    MockAccount(
      email: 'admin@shuk.et',
      password: 'admin123',
      role: 'admin',
      nameEn: 'Sara Haile',
      nameAm: 'ሳራ ኃይሌ',
      route: '/admin-dashboard',
      roleIcon: '🛡️',
    ),
  ];

  /// Returns the matching account or null if credentials are wrong
  static MockAccount? authenticate(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      return all.firstWhere(
        (a) =>
            a.email.toLowerCase() == normalizedEmail &&
            a.password == password.trim(),
      );
    } catch (_) {
      return null;
    }
  }
}
