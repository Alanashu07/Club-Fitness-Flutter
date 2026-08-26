class NameCountEntity {
  final String name;
  final num count;

  const NameCountEntity({
    this.name = '',
    this.count = 0,
  });

  @override
  String toString() {
    return 'NameCountEntity('
      'name: $name, '
      'count: $count, '
    ')';
  }
}

