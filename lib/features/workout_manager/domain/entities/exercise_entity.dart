class ExerciseEntity {
  final String id;
  final String name;
  final String category;
  final String muscle;
  final String description;
  final String videoUrl;
  final String imageUrl;
  final String difficulty;
  final bool isActive;
  final String createdAt;

  const ExerciseEntity({
    this.id = '',
    this.name = '',
    this.category = '',
    this.muscle = '',
    this.description = '',
    this.videoUrl = '',
    this.imageUrl = '',
    this.difficulty = '',
    this.isActive = false,
    this.createdAt = '',
  });

  @override
  String toString() {
    return 'ExerciseEntity('
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
    return identical(this, other) || (other is ExerciseEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

