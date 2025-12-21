class UserEntity {
  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
    this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}



