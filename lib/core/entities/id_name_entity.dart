class IdNameEntity {
  final String id;
  final String name;

  const IdNameEntity({
    this.id = '',
    this.name = '',
  });

  @override
  String toString() {
    return 'IdNameEntity('
      'id: $id, '
      'name: $name, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is IdNameEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}
