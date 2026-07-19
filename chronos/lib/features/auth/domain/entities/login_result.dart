class AuthSession {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String accessToken;
  final String refreshToken;

  AuthSession({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  String get fullName => '$firstName $lastName'.trim();
}
