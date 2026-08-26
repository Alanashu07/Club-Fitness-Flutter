import '../../domain/entities/exercise_entity.dart';

class ExerciseModel extends ExerciseEntity {
  const ExerciseModel({
    super.id,
    super.name,
    super.category,
    super.muscle,
    super.description,
    super.videoUrl,
    super.imageUrl,
    super.difficulty,
    super.isActive,
    super.createdAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      muscle: json['muscle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  factory ExerciseModel.fromEntity(ExerciseEntity entity) {
    return ExerciseModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      muscle: entity.muscle,
      description: entity.description,
      videoUrl: entity.videoUrl,
      imageUrl: entity.imageUrl,
      difficulty: entity.difficulty,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  ExerciseModel copyWith({
    String? id,
    String? name,
    String? category,
    String? muscle,
    String? description,
    String? videoUrl,
    String? imageUrl,
    String? difficulty,
    bool? isActive,
    String? createdAt,
  }) => ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      muscle: muscle ?? this.muscle,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      difficulty: difficulty ?? this.difficulty,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'muscle': muscle,
        'description': description,
        'videoUrl': videoUrl,
        'imageUrl': imageUrl,
        'difficulty': difficulty,
        'isActive': isActive,
        'createdAt': createdAt,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'ExerciseModel('
      'id: $id, '
      'name: $name, '
      'category: $category, '
      'muscle: $muscle, '
      'description: $description, '
      'videoUrl: $videoUrl, '
      'imageUrl: $imageUrl, '
      'difficulty: $difficulty, '
      'isActive: $isActive, '
      'createdAt: $createdAt, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is ExerciseModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // Helper function to remove empty values
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

