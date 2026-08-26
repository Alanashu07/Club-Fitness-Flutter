import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MembershipPlanView extends StatelessWidget {
  const MembershipPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MembershipPlansScreen();
  }
}

/// ------------------------- SCREEN -------------------------
class MembershipPlansScreen extends StatefulWidget {
  const MembershipPlansScreen({super.key});

  @override
  State<MembershipPlansScreen> createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {
  final borderSide = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppTheme.textSecondary, width: 1),
  );
  final enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppTheme.textSecondary, width: 1),
  );
  void _showPlanForm({MembershipPlanMiniEntity? plan}) {
    final isEdit = plan != null;
    final nameController = TextEditingController(text: plan?.name ?? '');
    final durationController = TextEditingController(
      text: plan?.durationDays.toString() ?? '',
    );
    final priceController = TextEditingController(
      text: plan?.price.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: plan?.description ?? '',
    );
    final featuresController = TextEditingController(
      text: plan?.features.join(', ') ?? '',
    );
    bool isActive = plan?.isActive ?? true;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEdit ? 'Edit Membership Plan' : 'Add Membership Plan',
                        style: Theme.of(ctx).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Plan Name',
                          labelText: 'Plan Name',
                          border: borderSide,
                          enabledBorder: enabledBorder,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Duration (days)',
                          labelText: 'Duration (days)',
                          border: borderSide,
                          enabledBorder: enabledBorder,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (int.tryParse(v) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Price',
                          labelText: 'Price',
                          border: borderSide,
                          enabledBorder: enabledBorder,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v) == null) {
                            return 'Enter a valid price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 2,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Description (optional)',
                          labelText: 'Description',
                          border: borderSide,
                          enabledBorder: enabledBorder,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: featuresController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Features (comma separated)',
                          labelText: 'Features',
                          border: borderSide,
                          enabledBorder: enabledBorder,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppTheme.primary,
                        title: const Text(
                          'Active',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                        value: isActive,
                        onChanged: (v) => setModalState(() => isActive = v),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;

                          final features = featuresController.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();

                          setState(() {
                            // if (isEdit) {
                            //   plan.name = nameController.text.trim();
                            //   plan.durationDays =
                            //       int.parse(durationController.text.trim());
                            //   plan.price = double.parse(priceController.text.trim());
                            //   plan.description =
                            //       descriptionController.text.trim().isEmpty
                            //           ? null
                            //           : descriptionController.text.trim();
                            //   plan.features = features;
                            //   plan.isActive = isActive;
                            // } else {
                            //   _plans.add(
                            //     MembershipPlanMiniEntity(
                            //       id: DateTime.now().millisecondsSinceEpoch.toString(),
                            //       name: nameController.text.trim(),
                            //       durationDays:
                            //           int.parse(durationController.text.trim()),
                            //       price: double.parse(priceController.text.trim()),
                            //       description:
                            //           descriptionController.text.trim(),
                            //       features: features,
                            //       isActive: isActive,
                            //     ),
                            //   );
                            // }
                          });

                          Navigator.pop(ctx);
                        },
                        child: Text(isEdit ? 'Update Plan' : 'Create Plan'),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(MembershipPlanMiniEntity plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Plan',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${plan.name}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              // setState(() => _plans.removeWhere((p) => p.id == plan.id));
              Navigator.pop(ctx);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  bool _activeOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('MEMBERSHIP PLANS')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanForm(),
        child: const Icon(Icons.add),
      ),
      body: LiquidRefresh(
        onRefresh: () => context.read<MembersConfigBloc>().add(
          GetMembershipPlansEvent(false, !_activeOnly),
        ),
        child: BlocBuilder<MembersConfigBloc, MembersConfigState>(
          builder: (context, state) {
            final plans = state.membershipPlans;
            if (plans.isEmpty) {
              return const Center(
                child: Text(
                  'No membership plans yet',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              );
            }
            return Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    const Text('Active Only'),
                    Checkbox(
                      value: _activeOnly,
                      onChanged: (value) {
                        setState(() {
                          _activeOnly = value ?? false;
                        });
                        context.read<MembersConfigBloc>().add(
                          GetMembershipPlansEvent(false, !_activeOnly),
                        );
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    plan.name,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: plan.isActive
                                        ? AppTheme.success.withAOpacity(0.15)
                                        : AppTheme.error.withAOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    plan.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: plan.isActive
                                          ? AppTheme.success
                                          : AppTheme.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${plan.durationDays} days  •  ₹${plan.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (plan.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                plan.description,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            if (plan.features.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: plan.features
                                    .map(
                                      (f) => Chip(
                                        label: Text(
                                          f,
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        backgroundColor: AppTheme.surface,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          side: const BorderSide(
                                            color: AppTheme.cardBorder,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () => _showPlanForm(plan: plan),
                                  icon: const Icon(
                                    Icons.edit,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _confirmDelete(plan),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: AppTheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
