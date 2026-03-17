class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final bool isPremium;
  final String notificationTime;
  final String locale;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.isPremium = false,
    this.notificationTime = '08:00',
    this.locale = 'en',
    required this.createdAt,
    required this.updatedAt,
  });
}
