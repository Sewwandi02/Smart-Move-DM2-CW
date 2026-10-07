class AuthUser {
  const AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roles,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> roles;

  String get name => '$firstName $lastName';
  String get role => roles.contains('ADMIN')
      ? 'ADMIN'
      : roles.contains('DRIVER')
          ? 'DRIVER'
          : 'PASSENGER';

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: (json['id'] as num).toInt(),
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        roles: (json['roles'] as List<dynamic>).map((role) => role.toString()).toList(),
      );
}
