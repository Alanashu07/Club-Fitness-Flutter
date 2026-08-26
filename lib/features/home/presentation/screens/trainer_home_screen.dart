import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class _AssignedMember {
  final String name;
  final String initials;
  final String plan;
  final Color avatarColor;
  final bool checkedInToday;
  final int workoutStreak;
  final String nextSession;
  const _AssignedMember(
    this.name,
    this.initials,
    this.plan,
    this.avatarColor,
    this.checkedInToday,
    this.workoutStreak,
    this.nextSession,
  );
}

class _PendingTask {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String tag;
  const _PendingTask(
    this.title,
    this.subtitle,
    this.icon,
    this.accent,
    this.tag,
  );
}

class _TodayClass {
  final String name;
  final String time;
  final String room;
  final int enrolled;
  final int capacity;
  final Color accent;
  final bool upcoming;
  const _TodayClass(
    this.name,
    this.time,
    this.room,
    this.enrolled,
    this.capacity,
    this.accent,
    this.upcoming,
  );
}

class _RecentCheckIn {
  final String name;
  final String initials;
  final String time;
  final Color avatarColor;
  const _RecentCheckIn(this.name, this.initials, this.time, this.avatarColor);
}

// ─── Dummy data ───────────────────────────────────────────────────────────────

const _assignedMembers = [
  _AssignedMember(
    'Arjun Menon',
    'AM',
    'Premium Monthly',
    Color(0xFFC41E2D),
    true,
    14,
    'Today',
  ),
  _AssignedMember(
    'Priya Nair',
    'PN',
    'Annual Plan',
    Color(0xFF7B1FA2),
    true,
    21,
    'Today',
  ),
  _AssignedMember(
    'Rahul Das',
    'RD',
    'Basic Monthly',
    Color(0xFF1565C0),
    false,
    3,
    'Tomorrow',
  ),
  _AssignedMember(
    'Sneha Pillai',
    'SP',
    'Quarterly',
    Color(0xFF2E7D32),
    true,
    8,
    'Today',
  ),
  _AssignedMember(
    'Kiran Kumar',
    'KK',
    'Premium Monthly',
    Color(0xFFE65100),
    false,
    0,
    'Not scheduled',
  ),
];

const _pendingTasks = [
  _PendingTask(
    'Assign workout to Rahul Das',
    'No plan for next week yet',
    Icons.fitness_center_rounded,
    Color(0xFFFFA000),
    'WORKOUT',
  ),
  _PendingTask(
    'Mark fee — Kiran Kumar',
    'Cash payment received at counter',
    Icons.receipt_long_rounded,
    Color(0xFF4CAF50),
    'FEE',
  ),
  _PendingTask(
    'Process order #CF-1082',
    'Whey Protein — ready for pickup',
    Icons.shopping_bag_rounded,
    Color(0xFF29B6F6),
    'ORDER',
  ),
];

const _todayClasses = [
  _TodayClass('Zumba', '8:00 AM', 'Studio A', 12, 15, Color(0xFFE91E63), false),
  _TodayClass(
    'Spinning',
    '11:00 AM',
    'Cycle Room',
    8,
    10,
    Color(0xFFFF5722),
    true,
  ),
  _TodayClass(
    'Yoga Flow',
    '6:00 PM',
    'Studio B',
    6,
    12,
    Color(0xFF29B6F6),
    false,
  ),
];

const _recentCheckIns = [
  _RecentCheckIn('Arjun Menon', 'AM', '7:02 AM', Color(0xFFC41E2D)),
  _RecentCheckIn('Priya Nair', 'PN', '7:18 AM', Color(0xFF7B1FA2)),
  _RecentCheckIn('Sneha Pillai', 'SP', '7:45 AM', Color(0xFF2E7D32)),
  _RecentCheckIn('Deepa Suresh', 'DS', '8:10 AM', Color(0xFF1565C0)),
  _RecentCheckIn('Amal Jose', 'AJ', '8:34 AM', Color(0xFFE65100)),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});
  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen>
    with TickerProviderStateMixin {
  int _navIndex = 0;
  final List<bool> _taskDone = List.filled(_pendingTasks.length, false);

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  int get _checkedInCount =>
      _assignedMembers.where((m) => m.checkedInToday).length;
  int get _pendingCount => _taskDone.where((d) => !d).length;

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
                  _buildDaySummaryRow(),
                  const SizedBox(height: 24),
                  _buildPendingTasks(),
                  const SizedBox(height: 24),
                  _buildTodayClasses(),
                  const SizedBox(height: 24),
                  _buildMyMembersSection(),
                  const SizedBox(height: 24),
                  _buildRecentCheckIns(),
                  const SizedBox(height: 24),
                  _buildAttendanceChart(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 130,
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
              color: Color(0xFF4CAF50),
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
            if (_pendingCount > 0)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.background, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$_pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
              colors: [Color(0xFF001A0A), AppTheme.background],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with green active ring
              Stack(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                        width: 2.5,
                      ),
                      color: AppTheme.surface,
                    ),
                    child: const Center(
                      child: Text(
                        'CR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.background,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withAOpacity(0.45),
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    'Coach Raj 🏋️',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withAOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withAOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'STAFF · TRAINER',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
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

  // ── Day Summary Row ─────────────────────────────────────────────────────────
  Widget _buildDaySummaryRow() {
    final items = [
      (
        '${_assignedMembers.length}',
        'My Members',
        Icons.people_alt_rounded,
        AppTheme.primary,
      ),
      (
        '$_checkedInCount',
        'Checked In',
        Icons.how_to_reg_rounded,
        const Color(0xFF4CAF50),
      ),
      (
        '${_todayClasses.length}',
        'Classes Today',
        Icons.sports_gymnastics_rounded,
        const Color(0xFF29B6F6),
      ),
      (
        '$_pendingCount',
        'Pending',
        Icons.pending_actions_rounded,
        const Color(0xFFFFA000),
      ),
    ];

    return Row(
      children: items.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final isLast = i == items.length - 1;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (s.$4).withAOpacity(0.18), width: 1),
            ),
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: (s.$4).withAOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(s.$3, color: s.$4, size: 17),
                ),
                const SizedBox(height: 7),
                Text(
                  s.$1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.$2,
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

  // ── Pending Tasks ───────────────────────────────────────────────────────────
  Widget _buildPendingTasks() {
    final remaining = _taskDone.where((d) => !d).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          'Pending Tasks',
          remaining == 0 ? '✓ All done!' : '$remaining remaining',
          remaining == 0 ? const Color(0xFF4CAF50) : AppTheme.textSecondary,
        ),
        const SizedBox(height: 14),
        ...List.generate(_pendingTasks.length, (i) {
          final task = _pendingTasks[i];
          final done = _taskDone[i];
          return _TaskTile(
            task: task,
            done: done,
            onToggle: () => setState(() => _taskDone[i] = !done),
          );
        }),
      ],
    );
  }

  // ── Today's Classes ─────────────────────────────────────────────────────────
  Widget _buildTodayClasses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel("Today's Classes", '${_todayClasses.length} sessions'),
        const SizedBox(height: 14),
        SizedBox(
          height: 128,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _todayClasses.length,
            itemBuilder: (_, i) => _ClassCard(gymClass: _todayClasses[i]),
          ),
        ),
      ],
    );
  }

  // ── My Members ──────────────────────────────────────────────────────────────
  Widget _buildMyMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('My Members', '${_assignedMembers.length} assigned'),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            children: List.generate(_assignedMembers.length, (i) {
              final m = _assignedMembers[i];
              final isLast = i == _assignedMembers.length - 1;
              return _MemberRow(member: m, isLast: isLast);
            }),
          ),
        ),
      ],
    );
  }

  // ── Recent Check-ins ────────────────────────────────────────────────────────
  Widget _buildRecentCheckIns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          'Recent Check-ins',
          '${_recentCheckIns.length} today so far',
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _recentCheckIns.length,
            itemBuilder: (_, i) => _CheckInBubble(checkIn: _recentCheckIns[i]),
          ),
        ),
      ],
    );
  }

  // ── Attendance Chart ────────────────────────────────────────────────────────
  Widget _buildAttendanceChart() {
    // Mon–Sun attendance counts for current week
    const weekData = [12, 18, 15, 22, 19, 8, 5];
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const todayIndex = 4; // Friday

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAOpacity(0.05), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Attendance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Gym-wide · This week',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withAOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withAOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  '99 total',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final val = weekData[i];
                const maxVal = 22;
                final barH = (val / maxVal) * 90.0;
                final isToday = i == todayIndex;
                final isPast = i < todayIndex;
                final color = isToday
                    ? AppTheme.primary
                    : isPast
                    ? const Color(0xFF4CAF50)
                    : Colors.white.withAOpacity(0.1);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isToday)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '$val',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400 + i * 60),
                          curve: Curves.easeOut,
                          height: barH,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: isToday
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primary.withAOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[i],
                          style: TextStyle(
                            color: isToday
                                ? Colors.white
                                : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: isToday
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Actions Grid ──────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      (Icons.qr_code_scanner_rounded, 'Scan\nCheck-in', AppTheme.primary),
      (
        Icons.fitness_center_rounded,
        'Assign\nWorkout',
        const Color(0xFF7B1FA2),
      ),
      (Icons.payments_rounded, 'Mark\nFee Paid', const Color(0xFF4CAF50)),
      (Icons.inventory_2_rounded, 'Process\nOrder', const Color(0xFF29B6F6)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Quick Actions', ''),
        const SizedBox(height: 14),
        Row(
          children: actions.asMap().entries.map((e) {
            final i = e.key;
            final a = e.value;
            final isLast = i == actions.length - 1;
            return Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.only(right: isLast ? 0 : 10),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (a.$3).withAOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: (a.$3).withAOpacity(0.14),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(a.$1, color: a.$3, size: 19),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        a.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Bottom Nav ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      (Icons.dashboard_rounded, Icons.dashboard_outlined, 'Home'),
      (Icons.people_alt_rounded, Icons.people_alt_outlined, 'Members'),
      (Icons.fitness_center_rounded, Icons.fitness_center_outlined, 'Workouts'),
      (Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Fees'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          top: BorderSide(color: Colors.white10, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
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
                onTap: () => setState(() => _navIndex = i),
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

  // ── FAB ─────────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: AppTheme.primary,
      elevation: 4,
      child: const Icon(
        Icons.qr_code_scanner_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Widget _sectionLabel(
    String title,
    String sub, [
    Color subColor = AppTheme.textSecondary,
  ]) {
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
            style: TextStyle(
              color: subColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  final _PendingTask task;
  final bool done;
  final VoidCallback onToggle;
  const _TaskTile({
    required this.task,
    required this.done,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: done ? AppTheme.surface.withAOpacity(0.4) : AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: done
                ? Colors.white.withAOpacity(0.04)
                : task.accent.withAOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Check circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? const Color(0xFF4CAF50) : Colors.transparent,
                border: Border.all(
                  color: done
                      ? const Color(0xFF4CAF50)
                      : Colors.white.withAOpacity(0.2),
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 15,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: done
                    ? Colors.white.withAOpacity(0.04)
                    : task.accent.withAOpacity(0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                task.icon,
                color: done ? AppTheme.textSecondary : task.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: done ? AppTheme.textSecondary : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondary.withAOpacity(
                        done ? 0.5 : 1,
                      ),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Tag chip
            if (!done)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: task.accent.withAOpacity(0.12),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: task.accent.withAOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  task.tag,
                  style: TextStyle(
                    color: task.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final _TodayClass gymClass;
  const _ClassCard({required this.gymClass});

  @override
  Widget build(BuildContext context) {
    final fillRatio = gymClass.enrolled / gymClass.capacity;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: gymClass.upcoming
            ? gymClass.accent.withAOpacity(0.12)
            : AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: gymClass.upcoming
              ? gymClass.accent.withAOpacity(0.5)
              : gymClass.accent.withAOpacity(0.2),
          width: gymClass.upcoming ? 1.5 : 1,
        ),
        boxShadow: gymClass.upcoming
            ? [
                BoxShadow(
                  color: gymClass.accent.withAOpacity(0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: gymClass.upcoming
                      ? gymClass.accent
                      : gymClass.accent.withAOpacity(0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  gymClass.upcoming ? 'NEXT UP' : gymClass.time,
                  style: TextStyle(
                    color: gymClass.upcoming ? Colors.white : gymClass.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: gymClass.accent,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            gymClass.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            gymClass.room,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const Spacer(),
          // Capacity bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${gymClass.enrolled}/${gymClass.capacity}',
                    style: TextStyle(
                      color: gymClass.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'enrolled',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: fillRatio,
                  minHeight: 4,
                  backgroundColor: Colors.white.withAOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(gymClass.accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final _AssignedMember member;
  final bool isLast;
  const _MemberRow({required this.member, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Colors.white10, width: 0.5),
              ),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: member.avatarColor.withAOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    member.initials,
                    style: TextStyle(
                      color: member.avatarColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              if (member.checkedInToday)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.card, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Name & plan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.plan,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Streak
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (member.workoutStreak > 0)
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFFF5722),
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${member.workoutStreak}d',
                      style: const TextStyle(
                        color: Color(0xFFFF5722),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 3),
              Text(
                member.checkedInToday ? '● In gym' : member.nextSession,
                style: TextStyle(
                  color: member.checkedInToday
                      ? const Color(0xFF4CAF50)
                      : AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Action arrow
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withAOpacity(0.2),
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _CheckInBubble extends StatelessWidget {
  final _RecentCheckIn checkIn;
  const _CheckInBubble({required this.checkIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: checkIn.avatarColor.withAOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: checkIn.avatarColor.withAOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    checkIn.initials,
                    style: TextStyle(
                      color: checkIn.avatarColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.background, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            checkIn.name.split(' ').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            checkIn.time,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
