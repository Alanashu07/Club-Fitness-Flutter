
import 'package:club_fitness/core/entities/user_entity.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:flutter/material.dart';

class UserRoleSelectorChip extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onSelected;

  const UserRoleSelectorChip({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: UserRole.values
          .map(
            (e) => SelectChip(
              label: e.label,
              selected: e == selected,
              onTap: () => onSelected(e),
            ),
          )
          .toList(),
    );
  }
}