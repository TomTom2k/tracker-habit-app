/// Goal Entity - Domain layer
/// Represents a goal with sub-goals
class GoalEntity {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final GoalCategory category;
  final DateTime? targetDate; // Ngày mục tiêu hoàn thành
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoalEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    this.targetDate,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Goal Category enum
enum GoalCategory {
  health, // Sức khỏe
  career, // Sự nghiệp
  finance, // Tài chính
  education, // Học tập
  personal, // Cá nhân
  relationship, // Mối quan hệ
  other, // Khác
}

extension GoalCategoryExtension on GoalCategory {
  String get displayName {
    switch (this) {
      case GoalCategory.health:
        return 'Health';
      case GoalCategory.career:
        return 'Career';
      case GoalCategory.finance:
        return 'Finance';
      case GoalCategory.education:
        return 'Education';
      case GoalCategory.personal:
        return 'Personal';
      case GoalCategory.relationship:
        return 'Relationship';
      case GoalCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case GoalCategory.health:
        return 'favorite';
      case GoalCategory.career:
        return 'work';
      case GoalCategory.finance:
        return 'account_balance';
      case GoalCategory.education:
        return 'school';
      case GoalCategory.personal:
        return 'person';
      case GoalCategory.relationship:
        return 'people';
      case GoalCategory.other:
        return 'category';
    }
  }

  String get value {
    switch (this) {
      case GoalCategory.health:
        return 'health';
      case GoalCategory.career:
        return 'career';
      case GoalCategory.finance:
        return 'finance';
      case GoalCategory.education:
        return 'education';
      case GoalCategory.personal:
        return 'personal';
      case GoalCategory.relationship:
        return 'relationship';
      case GoalCategory.other:
        return 'other';
    }
  }

}

extension GoalCategoryStatic on GoalCategory {
  static GoalCategory fromString(String value) {
    switch (value) {
      case 'health':
        return GoalCategory.health;
      case 'career':
        return GoalCategory.career;
      case 'finance':
        return GoalCategory.finance;
      case 'education':
        return GoalCategory.education;
      case 'personal':
        return GoalCategory.personal;
      case 'relationship':
        return GoalCategory.relationship;
      case 'other':
      default:
        return GoalCategory.other;
    }
  }
}

