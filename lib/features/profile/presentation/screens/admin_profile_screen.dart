import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _AdminHeader(),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.group_outlined,
                    label: 'Members',
                    value: '312',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.sports_gymnastics_outlined,
                    label: 'Trainers',
                    value: '14',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.fitness_center,
                    label: 'Templates',
                    value: '27',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'People Management'),
            const SizedBox(height: 12),
            _AdminTile(
              icon: Icons.sports_gymnastics_outlined,
              title: 'Manage trainers',
              subtitle: 'Add, edit, or remove trainer accounts',
              color: AppTheme.primary,
              onTap: () {},
            ),
            _AdminTile(
              icon: Icons.groups_outlined,
              title: 'Manage members',
              subtitle: 'View memberships, status, and access',
              color: AppTheme.primary,
              onTap: () {},
            ),
            _AdminTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Staff roles & permissions',
              subtitle: 'Control who can access what',
              color: AppTheme.primary,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Workouts'),
            const SizedBox(height: 12),
            _AdminTile(
              icon: Icons.add_circle_outline,
              title: 'Create workout',
              subtitle: 'Build a new workout for members or trainers',
              color: AppTheme.success,
              onTap: () {},
            ),
            _AdminTile(
              icon: Icons.copy_all_outlined,
              title: 'Workout templates',
              subtitle: 'Create and manage reusable templates',
              color: AppTheme.success,
              onTap: () {},
            ),
            _AdminTile(
              icon: Icons.category_outlined,
              title: 'Exercise library',
              subtitle: 'Manage exercises used across workouts',
              color: AppTheme.success,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Shop & Inventory'),
            const SizedBox(height: 12),
            _AdminTile(
              icon: Icons.inventory_2_outlined,
              title: 'Manage stock',
              subtitle: 'Restock items and restrict ordering',
              color: AppTheme.warning,
              onTap: () {},
            ),
            _AdminTile(
              icon: Icons.receipt_long_outlined,
              title: 'View orders',
              subtitle: 'See pending and collected member orders',
              color: AppTheme.warning,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Site Settings'),
            const SizedBox(height: 12),
            _AdminTile(
              icon: Icons.storefront_outlined,
              title: 'Gym profile',
              subtitle: 'Name, address, hours, contact details',
              color: AppTheme.textSecondary,
              onTap: () {},
            ),
            _AdminTile(
              icon: Icons.campaign_outlined,
              title: 'Announcements & offers',
              subtitle: 'Push notifications to all members',
              color: AppTheme.textSecondary,
              onTap: () {},
            ),
            _AdminTile(
              icon: Icons.payments_outlined,
              title: 'Membership plans',
              subtitle: 'Edit pricing and plan durations',
              color: AppTheme.textSecondary,
              onTap: () => context.push(Routes.membershipPlans),
            ),
            _AdminTile(
              icon: Icons.palette_outlined,
              title: 'App appearance',
              subtitle: 'Theme, logo, and branding',
              color: AppTheme.textSecondary,
              onTap: () {},
            ),
            _AdminTile(
              icon: Icons.security_outlined,
              title: 'Security',
              subtitle: 'Password, two-factor authentication',
              color: AppTheme.textSecondary,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (previous, current) => current is AuthLogoutState || current is AuthFailure,
              listener: (context, state) {
                if(state is AuthLogoutState) {
                  context.go(Routes.login);
                } else if (state is AuthFailure) {
                  context.showToastFromFailure(state.failure);
                }
              },
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutEvent());
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.error),
                  label: const Text(
                    'Log out',
                    style: TextStyle(color: AppTheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 36,
          backgroundColor: AppTheme.surface,
          child: Icon(
            Icons.person,
            size: 38,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vishnu Kumar',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'vishnu.kumar@clubfitness.com',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Super Admin',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withAOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
