import 'dart:math' as math;
import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/di.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/home_entities.dart';
import '../bloc/home_bloc/home_bloc.dart';

// ─── Formatting helpers ───────────────────────────────────────────────────────

String _initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, math.min(2, parts.first.length)).toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

String _formatInr(num value) {
  final isNeg = value < 0;
  final intVal = value.abs().round();
  final str = intVal.toString();
  String result;
  if (str.length <= 3) {
    result = str;
  } else {
    final groups = <String>[];
    var rest = str.substring(0, str.length - 3);
    final last3 = str.substring(str.length - 3);
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    result = '${groups.join(',')},$last3';
  }
  return '${isNeg ? '-' : ''}₹ $result';
}

DateTime? _tryParseDate(String value) {
  if (value.isEmpty) return null;
  return DateTime.tryParse(value);
}

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String _formatShortDate(String iso) {
  final d = _tryParseDate(iso);
  if (d == null) return '';
  return '${_monthNames[d.month - 1]} ${d.day}';
}

String _timeAgo(String iso) {
  final d = _tryParseDate(iso);
  if (d == null) return '';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return _formatShortDate(iso);
}

const _accentPalette = [
  Color(0xFF29B6F6),
  Color(0xFFFFD600),
  Color(0xFF4CAF50),
  Color(0xFFC41E2D),
  Color(0xFF7B1FA2),
  Color(0xFF2E7D32),
];

Color _accentForIndex(int i) => _accentPalette[i % _accentPalette.length];

IconData _exerciseIconFor(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('run') || lower.contains('treadmill') || lower.contains('cardio')) {
    return Icons.directions_run_rounded;
  }
  if (lower.contains('fly') || lower.contains('stretch') || lower.contains('mobility')) {
    return Icons.sports_gymnastics_rounded;
  }
  return Icons.fitness_center_rounded;
}

class MemberHomeScreen extends StatelessWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(sl())..add(const GetHomeEvent("member")),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          switch(state) {
            case HomeInitial():
            case HomeLoading():
              return const Center(child: CircularProgressIndicator.adaptive());
            case HomeSuccess():
              return MemberHomeView(data: state.home.memberHome!);
            case HomeFailure():
              return FailureTextWidget(
                state.failure,
                onRetry: () => context.read<HomeBloc>().add(const GetHomeEvent("member")),
              );
          }
        }
      ),
    );
  }
}

// ─── Main Screen ──────────────────────────────────────────────────────────────

class MemberHomeView extends StatefulWidget {
  final MemberHomeEntity data;
  const MemberHomeView({super.key, required this.data});

  @override
  State<MemberHomeView> createState() => _MemberHomeViewState();
}

class _MemberHomeViewState extends State<MemberHomeView>
    with TickerProviderStateMixin {
  int _navIndex = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Local completion tracking, seeded from the entity
  late List<bool> _exerciseDone;

  MemberHomeEntity get _data => widget.data;
  List<ExerciseEntity> get _exercises => _data.todaysWorkout.exercises;

  @override
  void initState() {
    super.initState();
    _exerciseDone = List.generate(
      _exercises.length,
      (i) => _exercises[i].completed,
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant MemberHomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.todaysWorkout.exercises.length != _exercises.length) {
      _exerciseDone = List.generate(
        _exercises.length,
        (i) => _exercises[i].completed,
      );
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  int get _doneCount => _exerciseDone.where((d) => d).length;
  double get _workoutProgress =>
      _exercises.isEmpty ? 0 : _doneCount / _exercises.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildMembershipCard(),
                  const SizedBox(height: 24),
                  _buildTodayWorkout(),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  if (_data.announcements.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionLabel('Announcements & Offers', 'View all →'),
                    const SizedBox(height: 14),
                    _buildAnnouncements(),
                  ],
                  if (_data.shopPreview.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionLabel('Shop', 'Browse →'),
                    const SizedBox(height: 14),
                    _buildShopPreview(),
                  ],
                  if (_data.upcomingClasses.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildUpcomingClasses(),
                  ],
                  if (_data.feeStatus.status.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildFeeStatusBanner(),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final profile = _data.profile;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning,'
        : hour < 17
            ? 'Good afternoon,'
            : 'Good evening,';

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.background,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Club Fitness',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                context.push(Routes.notifications);
              },
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.background, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0005), AppTheme.background],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary, width: 2),
                  color: AppTheme.surface,
                  image: profile.profileImageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(profile.profileImageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profile.profileImageUrl.isEmpty
                    ? Center(
                        child: Text(
                          _initialsOf(profile.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      color: Colors.white.withAOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${profile.name} 💪',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Membership Card ─────────────────────────────────────────────────────────
  Widget _buildMembershipCard() {
    final membership = _data.membership;
    final totalDays = membership.plan.durationDays.toDouble();
    final daysLeft = membership.daysRemaining.toDouble();
    final progress = totalDays > 0 ? (daysLeft / totalDays).clamp(0.0, 1.0) : 0.0;
    final isActive = membership.status.toUpperCase() == 'ACTIVE';
    final joinedLabel = ''; // not present in entity; omit or wire from profile if available later

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A0008), Color(0xFF1A1A1A)],
        ),
        border: Border.all(color: AppTheme.primary.withAOpacity(0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MEMBERSHIP',
                    style: TextStyle(
                      color: AppTheme.primary.withAOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    membership.plan.name.isNotEmpty
                        ? membership.plan.name
                        : 'No Active Plan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isActive ? const Color(0xFF4CAF50) : AppTheme.error)
                      .withAOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isActive ? const Color(0xFF4CAF50) : AppTheme.error)
                        .withAOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: isActive ? const Color(0xFF4CAF50) : AppTheme.error,
                      size: 7,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      membership.status.isNotEmpty
                          ? membership.status.toUpperCase()
                          : 'UNKNOWN',
                      style: TextStyle(
                        color: isActive ? const Color(0xFF4CAF50) : AppTheme.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${membership.daysRemaining} days remaining',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          membership.end.isNotEmpty
                              ? 'Expires ${_formatShortDate(membership.end)}'
                              : '',
                          style: TextStyle(
                            color: Colors.white.withAOpacity(0.45),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withAOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (joinedLabel.isNotEmpty)
                _MiniStat(
                  icon: Icons.calendar_today_rounded,
                  label: 'Joined',
                  value: joinedLabel,
                ),
              if (joinedLabel.isNotEmpty) const SizedBox(width: 16),
              _MiniStat(
                icon: Icons.fitness_center_rounded,
                label: 'Trainer',
                value: membership.trainer.name.isNotEmpty
                    ? membership.trainer.name
                    : 'Not Assigned',
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(Routes.renewMembership),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Renew',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Today's Workout ─────────────────────────────────────────────────────────
  Widget _buildTodayWorkout() {
    final workout = _data.todaysWorkout;
    final hasPlan = workout.planName.isNotEmpty && _exercises.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAOpacity(0.06), width: 1),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAOpacity(0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's Workout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        hasPlan
                            ? '${workout.planName} — ${_exercises.length} exercises'
                            : 'No workout assigned for today',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasPlan)
                  // Ring progress
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CustomPaint(
                      painter: _RingProgressPainter(
                        progress: _workoutProgress,
                        color: AppTheme.primary,
                      ),
                      child: Center(
                        child: Text(
                          '$_doneCount/${_exercises.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Exercise list
          if (hasPlan)
            ...List.generate(_exercises.length, (i) {
              final ex = _exercises[i];
              final done = _exerciseDone[i];
              return _ExerciseTile(
                exercise: ex,
                done: done,
                onToggle: () => setState(() => _exerciseDone[i] = !done),
              );
            })
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Rest day — no exercises scheduled',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ),
            ),
          // Bottom CTA
          Padding(
            padding: const EdgeInsets.all(14),
            child: GestureDetector(
              onTap: () => context.push(Routes.memberWorkout),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primary.withAOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'View Full Weekly Plan →',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Stats ─────────────────────────────────────────────────────────────
  Widget _buildQuickStats() {
    final qs = _data.quickStats;
    final planTierName = _data.membership.plan.name.isNotEmpty
        ? _data.membership.plan.name.split(' ').first
        : '—';

    final stats = [
      (
        Icons.local_fire_department_rounded,
        '${qs.dayStreak}',
        'Day Streak',
        const Color(0xFFFF5722),
      ),
      (
        Icons.check_circle_rounded,
        '${qs.workoutsCompleted}',
        'Workouts Done',
        const Color(0xFF4CAF50),
      ),
      (
        Icons.shopping_bag_rounded,
        '${qs.activeOrders}',
        'Orders Active',
        const Color(0xFF29B6F6),
      ),
      (Icons.star_rounded, planTierName, 'Member Tier', const Color(0xFFFFD600)),
    ];

    return Row(
      children: stats.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final isLast = i == stats.length - 1;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (s.$4).withAOpacity(0.15), width: 1),
            ),
            child: Column(
              children: [
                Icon(s.$1, color: s.$4, size: 20),
                const SizedBox(height: 6),
                Text(
                  s.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.$3,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Announcements ───────────────────────────────────────────────────────────
  Widget _buildAnnouncements() {
    final list = _data.announcements;
    return Column(
      children: List.generate(
        list.length,
        (i) => _AnnouncementTile(
          announcement: list[i],
          accent: _accentForIndex(i),
        ),
      ),
    );
  }

  // ── Shop Preview ────────────────────────────────────────────────────────────
  Widget _buildShopPreview() {
    final products = _data.shopPreview;
    return SizedBox(
      height: 148,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (_, i) => _ProductCard(
          product: products[i],
          accent: _accentForIndex(i),
        ),
      ),
    );
  }

  // ── Upcoming Classes ────────────────────────────────────────────────────────
  Widget _buildUpcomingClasses() {
    final classes = _data.upcomingClasses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Upcoming Classes', 'Full schedule →'),
        const SizedBox(height: 14),
        ...List.generate(classes.length, (i) {
          final c = classes[i];
          final accent = _accentForIndex(i);
          final gymClass = c.gymClass;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withAOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withAOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.music_note_rounded, color: accent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gymClass.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${gymClass.dayOfWeek}, ${gymClass.startTime} · ${gymClass.trainerName}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withAOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        c.status,
                        style: TextStyle(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Fee Status Banner ───────────────────────────────────────────────────────
  Widget _buildFeeStatusBanner() {
    final fee = _data.feeStatus;
    final isPaid = fee.status.toUpperCase() == 'PAID';
    final color = isPaid ? const Color(0xFF4CAF50) : const Color(0xFFFFA000);
    final bgColor = isPaid ? const Color(0xFF0A1A0A) : const Color(0xFF1A1100);
    final subtitle = isPaid
        ? '${fee.planName} · Paid ${_formatShortDate(fee.paidDate)}'
        : '${fee.planName} · ${_formatInr(fee.amount)} due ${_formatShortDate(fee.dueDate)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withAOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPaid ? Icons.check_circle_rounded : Icons.error_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPaid ? 'Fee Paid' : 'Fee ${fee.status}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ── Section Label ───────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        if (sub.isNotEmpty)
          Text(
            sub,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
      ],
    );
  }

  // ── Bottom Nav ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home', ''),
      (
        Icons.fitness_center_rounded,
        Icons.fitness_center_outlined,
        'Workouts',
        Routes.memberWorkout,
      ),
      (Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Fees', Routes.renewMembership),
      (
        Icons.shopping_bag_rounded,
        Icons.shopping_bag_outlined,
        'Shop',
        Routes.shopHome,
      ),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile', Routes.profile),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final selected = _navIndex == i;
              return GestureDetector(
                onTap: () {
                  if (item.$4.isNotEmpty) {
                    context.push(item.$4);
                    return;
                  }
                  setState(() => _navIndex = i);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary.withAOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? item.$1 : item.$2,
                        color: selected ? AppTheme.primary : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: TextStyle(
                          color: selected ? AppTheme.primary : Colors.grey,
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 13),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final ExerciseEntity exercise;
  final bool done;
  final VoidCallback onToggle;
  const _ExerciseTile({
    required this.exercise,
    required this.done,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _exerciseIconFor(exercise.name);
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: done
              ? AppTheme.primary.withAOpacity(0.07)
              : AppTheme.surface.withAOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done
                ? AppTheme.primary.withAOpacity(0.3)
                : Colors.white.withAOpacity(0.04),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Check circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppTheme.primary : Colors.transparent,
                border: Border.all(
                  color: done
                      ? AppTheme.primary
                      : Colors.white.withAOpacity(0.2),
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Exercise icon
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: done
                    ? AppTheme.primary.withAOpacity(0.1)
                    : Colors.white.withAOpacity(0.05),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                size: 17,
                color: done ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            // Name & details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      color: done
                          ? Colors.white.withAOpacity(0.5)
                          : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white.withAOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${exercise.sets} sets · ${exercise.reps} reps · ${exercise.restSeconds}s rest',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withAOpacity(
                        done ? 0.5 : 1,
                      ),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            // Sets badge
            if (!done)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${exercise.sets}×${exercise.reps}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final AnnouncementEntity announcement;
  final Color accent;
  const _AnnouncementTile({required this.announcement, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withAOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withAOpacity(0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.campaign_rounded,
              color: accent,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      _timeAgo(announcement.createdAt),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ShopPrevieEntity product;
  final Color accent;
  const _ProductCard({required this.product, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withAOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withAOpacity(0.14),
              borderRadius: BorderRadius.circular(11),
              image: product.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product.imageUrl.isEmpty
                ? Icon(Icons.shopping_bag_rounded, color: accent, size: 21)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatInr(product.price),
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accent.withAOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add_rounded, color: accent, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Ring progress painter ────────────────────────────────────────────────────
class _RingProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 3;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withAOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    // Progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        progress * 2 * math.pi,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingProgressPainter old) => old.progress != progress;
}