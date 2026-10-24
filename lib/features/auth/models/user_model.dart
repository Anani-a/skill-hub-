enum UserRole { customer, provider, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final UserRole role;
  final String? profileImageUrl;
  final String? bio;
  final bool isVerified;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.profileImageUrl,
    this.bio,
    required this.isVerified,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    UserRole? role,
    String? profileImageUrl,
    String? bio,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Mock Users
  static UserModel mockCustomer = UserModel(
    id: 'u1',
    name: 'Abel Abreham',
    email: 'abel@example.com',
    phoneNumber: '+251911223344',
    role: UserRole.customer,
    profileImageUrl: null,
    bio: 'Looking for reliable service providers',
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
  );

  static UserModel mockProvider = UserModel(
    id: 'u2',
    name: 'Bekele Tadesse',
    email: 'bekele@example.com',
    phoneNumber: '+251922334455',
    role: UserRole.provider,
    profileImageUrl: null,
    bio: 'Master electrician with 10+ years experience',
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
  );

  static UserModel mockAdmin = UserModel(
    id: 'u3',
    name: 'Admin User',
    email: 'admin@example.com',
    phoneNumber: '+251911000000',
    role: UserRole.admin,
    profileImageUrl: null,
    bio: 'Platform administrator for dispute and provider review',
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 400)),
  );
}

