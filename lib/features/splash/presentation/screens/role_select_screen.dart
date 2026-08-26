import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});
  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen>
    with TickerProviderStateMixin {
  int? _hoveredIndex;

  late final AnimationController _entranceCtrl;
  late final List<AnimationController> _cardCtrls;
  late final List<Animation<double>> _cardFades;
  late final List<Animation<Offset>> _cardSlides;

  final _roles = const [
    _RoleData(
      title: 'Admin',
      subtitle: 'Full control over everything',
      description:
          'Manage members, fees, workouts, products, staff, reports, and all app settings.',
      icon: Icons.admin_panel_settings_rounded,
      tag: 'OWNER / MANAGER',
      gradient: [Color(0xFF3A0010), Color(0xFF1A0008)],
      accent: AppTheme.primary,
      permissions: [
        'Member Management',
        'Fee Approvals',
        'Reports & Analytics',
        'Announcements',
        'Staff Control',
        'App Settings',
      ],
    ),
    _RoleData(
      title: 'Trainer',
      subtitle: 'Manage your members & classes',
      description:
          'Assign workouts, track attendance, mark fees, process orders and run classes.',
      icon: Icons.sports_rounded,
      tag: 'STAFF',
      gradient: [Color(0xFF001A0A), Color(0xFF0A1A0A)],
      accent: Color(0xFF4CAF50),
      permissions: [
        'Assign Workouts',
        'Mark Fee Paid',
        'Process Orders',
        'Check-in Members',
        'View Member Info',
        'Class Management',
      ],
    ),
    _RoleData(
      title: 'Member',
      subtitle: 'Your gym, your journey',
      description:
          'View workouts, pay fees, shop products, track progress, and stay updated.',
      icon: Icons.person_rounded,
      tag: 'GYM MEMBER',
      gradient: [Color(0xFF001525), Color(0xFF0A1020)],
      accent: Color(0xFF29B6F6),
      permissions: [
        'View Workouts',
        'Pay Fees',
        'Browse Shop',
        'View Facilities',
        'Announcements',
        'Progress Tracking',
      ],
    ),
    _RoleData(
      title: 'Login',
      subtitle: 'Login as User',
      description:
          'View workouts, pay fees, shop products, track progress, and stay updated.',
      icon: Icons.login_rounded,
      tag: 'GYM MEMBER',
      gradient: [Color(0xFF001525), Color(0xFF0A1020)],
      accent: Color(0xFF29B6F6),
      permissions: [
        'View Workouts',
        'Pay Fees',
        'Browse Shop',
        'View Facilities',
        'Announcements',
        'Progress Tracking',
      ],
    )
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _cardCtrls = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _cardFades = _cardCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _cardSlides = _cardCtrls
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.18),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();

    _entranceCtrl.forward();
    _staggerCards();
  }

  Future<void> _staggerCards() async {
    for (int i = 0; i < _cardCtrls.length; i++) {
      await Future.delayed(Duration(milliseconds: 180 + i * 120));
      if (mounted) _cardCtrls[i].forward();
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    for (final c in _cardCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _navigate(int index) {
    final String screen = switch (index) {
      0 => Routes.adminHome,
      1 => Routes.trainerHome,
      2 => Routes.home,
      _ => Routes.login,
    };
    context.go(screen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entranceCtrl,
                  curve: Curves.easeOut,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo row
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Club Fitness',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      // Eyebrow
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'CONTINUE AS',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Select\nyour role',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Each role has a tailored experience\ndesigned for how you use Club Fitness.',
                        style: TextStyle(
                          color: Colors.white.withAOpacity(0.4),
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),

            // ── Role cards ──────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: FadeTransition(
                      opacity: _cardFades[i],
                      child: SlideTransition(
                        position: _cardSlides[i],
                        child: _RoleCard(
                          data: _roles[i],
                          index: i,
                          isHovered: _hoveredIndex == i,
                          onTap: () => _navigate(i),
                          onHoverChange: (h) =>
                              setState(() => _hoveredIndex = h ? i : null),
                        ),
                      ),
                    ),
                  ),
                  childCount: _roles.length,
                ),
              ),
            ),

            // ── Footer ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _entranceCtrl,
                    curve: Curves.easeOut,
                  ),
                  child: Center(
                    child: Text(
                      'Tap a role to enter · Access is permission-based',
                      style: TextStyle(
                        color: Colors.white.withAOpacity(0.2),
                        fontSize: 11,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Role Data Model ──────────────────────────────────────────────────────────

class _RoleData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String tag;
  final List<Color> gradient;
  final Color accent;
  final List<String> permissions;

  const _RoleData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.tag,
    required this.gradient,
    required this.accent,
    required this.permissions,
  });
}

// ─── Role Card ────────────────────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  final _RoleData data;
  final int index;
  final bool isHovered;
  final VoidCallback onTap;
  final ValueChanged<bool> onHoverChange;

  const _RoleCard({
    required this.data,
    required this.index,
    required this.isHovered,
    required this.onTap,
    required this.onHoverChange,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.975,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) async {
        await _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: d.gradient,
            ),
            border: Border.all(
              color: d.accent.withAOpacity(widget.isHovered ? 0.6 : 0.25),
              width: widget.isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: d.accent.withAOpacity(widget.isHovered ? 0.14 : 0.06),
                blurRadius: widget.isHovered ? 24 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Card top ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon bubble
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: d.accent.withAOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: d.accent.withAOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(d.icon, color: d.accent, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: d.accent.withAOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              d.tag,
                              style: TextStyle(
                                color: d.accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            d.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d.subtitle,
                            style: TextStyle(
                              color: Colors.white.withAOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arrow
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: d.accent.withAOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: d.accent,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Divider ─────────────────────────────────────────────────
              Divider(
                height: 1,
                thickness: 0.5,
                color: d.accent.withAOpacity(0.12),
                indent: 20,
                endIndent: 20,
              ),

              // ── Description ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                child: Text(
                  d.description,
                  style: TextStyle(
                    color: Colors.white.withAOpacity(0.45),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ),

              // ── Permission chips ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: d.permissions
                      .map((p) => _PermissionChip(label: p, accent: d.accent))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Permission Chip ──────────────────────────────────────────────────────────

class _PermissionChip extends StatelessWidget {
  final String label;
  final Color accent;
  const _PermissionChip({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withAOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withAOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: accent.withAOpacity(0.85),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
