
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdvancedFilterSheet extends StatefulWidget {
  final Map<String, dynamic>? activeFilters;
  const AdvancedFilterSheet({super.key, this.activeFilters});
  @override
  State<AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<AdvancedFilterSheet> {
  String _plan = 'all';
  String _trainer = 'all';
  bool _checkedInToday = false;
  bool _overdueOnly = false;

  @override
  void initState() {
    super.initState();
    _plan = widget.activeFilters?['plan'] ?? 'all';
    _trainer = widget.activeFilters?['trainer'] ?? 'all';
    _checkedInToday = widget.activeFilters?['checkedInToday'] ?? false;
    _overdueOnly = widget.activeFilters?['overdueOnly'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Advanced Filter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _plan = 'all';
                    _trainer = 'all';
                    _checkedInToday = false;
                    _overdueOnly = false;
                  }),
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SheetLabel('Membership Plan'),
            const SizedBox(height: 8),
            BlocBuilder<MembersConfigBloc, MembersConfigState>(
              builder: (context, state) {
                return _chipRow(
                  [
                    (key: "all", label: "All"),
                    ...state.membershipPlans.map(
                      (e) => (key: e.id, label: e.name),
                    ),
                  ],
                  _plan,
                  (v) => setState(() => _plan = v),
                );
              },
            ),
            const SizedBox(height: 16),
            const SheetLabel('Trainer'),
            const SizedBox(height: 8),
            BlocBuilder<MembersConfigBloc, MembersConfigState>(
              builder: (context, state) {
                return _chipRow(
                  [
                    (key: "all", label: "All"),
                    ...state.trainers.map((e) => (key: e.id, label: e.name)),
                  ],
                  _trainer,
                  (v) => setState(() => _trainer = v),
                );
              },
            ),
            const SizedBox(height: 16),
            _toggle(
              'Checked in today',
              _checkedInToday,
              (v) => setState(() => _checkedInToday = v),
            ),
            _toggle(
              'Overdue fees only',
              _overdueOnly,
              (v) => setState(() => _overdueOnly = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'plan': _plan,
                'trainer': _trainer,
                'checkedInToday': _checkedInToday,
                'overdueOnly': _overdueOnly,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipRow(
    List<({String key, String label})> options,
    String selected,
    ValueChanged<String> onSelect,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options
          .map(
            (o) => SelectChip(
              label: o.label,
              selected: selected == o.key,
              small: true,
              onTap: () => onSelect(o.key),
            ),
          )
          .toList(),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primary,
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.white12,
      ),
    );
  }
}