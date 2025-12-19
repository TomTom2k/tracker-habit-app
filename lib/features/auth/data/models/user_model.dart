import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.name,
    super.avatarUrl,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      name: json['name'] as String? ?? json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  factory UserModel.fromSupabaseUser(dynamic user) {
    final userData = user.userMetadata ?? {};
    return UserModel(
      id: user.id as String,
      email: user.email as String?,
      name: userData['full_name'] as String? ?? userData['name'] as String?,
      avatarUrl: userData['avatar_url'] as String?,
      createdAt: user.createdAt != null
          ? DateTime.parse(user.createdAt as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

