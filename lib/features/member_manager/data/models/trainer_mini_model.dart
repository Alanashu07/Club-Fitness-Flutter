
import '../../domain/entities/trainer_mini_entity.dart';

class TrainerMiniModel extends TrainerMiniEntity {
  const TrainerMiniModel({
    super.id,
    super.name,
    super.staffTitle,
    super.profileImageUrl,
  });

  factory TrainerMiniModel.fromJson(Map<String, dynamic> json) {
    return TrainerMiniModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      staffTitle: json['staffTitle'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
    );
  }

  factory TrainerMiniModel.fromEntity(TrainerMiniEntity entity) {
    return TrainerMiniModel(
      id: entity.id,
      name: entity.name,
      staffTitle: entity.staffTitle,
      profileImageUrl: entity.profileImageUrl,
    );
  }

  TrainerMiniModel copyWith({
    String? id,
    String? name,
    String? staffTitle,
    String? profileImageUrl,
  }) => TrainerMiniModel(
      id: id ?? this.id,
      name: name ?? this.name,
      staffTitle: staffTitle ?? this.staffTitle,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'staffTitle': staffTitle,
        'profileImageUrl': profileImageUrl,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'TrainerMiniModel('
      'id: $id, '
      'name: $name, '
      'staffTitle: $staffTitle, '
      'profileImageUrl: $profileImageUrl, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is TrainerMiniModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

// Helper function to remove empty or default values from JSON
bool _removeEmpty(dynamic value) {
  if (value == null) return true;
  if (value is num) return value == 0;
  if (value is String) return value.isEmpty;
  if (value is List) return value.isEmpty;
  if (value is bool) return !value;
  if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
  return false;
}
}

