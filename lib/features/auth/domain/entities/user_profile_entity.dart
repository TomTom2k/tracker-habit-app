class UserProfileEntity {
  final String id;
  final String userId; // Foreign key to auth.users
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfileEntity({
    required this.id,
    required this.userId,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileEntity && other.id == id && other.userId == userId;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}

