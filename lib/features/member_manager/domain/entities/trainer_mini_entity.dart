class TrainerMiniEntity {
  final String id;
  final String name;
  final String staffTitle;
  final String profileImageUrl;

  const TrainerMiniEntity({
    this.id = '',
    this.name = '',
    this.staffTitle = '',
    this.profileImageUrl = '',
  });

  @override
  String toString() {
    return 'TrainerMiniEntity('
      'id: $id, '
      'name: $name, '
      'staffTitle: $staffTitle, '
      'profileImageUrl: $profileImageUrl, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is TrainerMiniEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}
