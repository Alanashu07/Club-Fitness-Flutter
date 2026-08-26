import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class _Exercise {
  final String name;
  final String sets;
  final String reps;
  final String rest;
  final String tip;
  final IconData icon;
  bool done = false;
  _Exercise(this.name, this.sets, this.reps, this.rest, this.tip, this.icon);
}

enum _DayStatus { completed, today, upcoming, notAssigned }

class _WorkoutDay {
  final DateTime date;
  final String focus;
  final List<_Exercise> exercises;
  final bool assigned;
  _WorkoutDay({
    required this.date,
    required this.focus,
    required this.exercises,
    required this.assigned,
  });

  int get doneCount => exercises.where((e) => e.done).length;
  double get progress => exercises.isEmpty ? 0 : doneCount / exercises.length;
}

// ─── Date helpers (no intl dependency) ─────────────────────────────────────

const _weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _weekdayFull = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _monthShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// ─── Screen ───────────────────────────────────────────────────────────────────

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});
  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  // 0 = Daily, 1 = Weekly
  int _viewMode = 0;
  late int _selectedIndex;
  late DateTime _today;
  late DateTime _weekStart;
  late List<_WorkoutDay> _week;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    // Monday of the current week
    _weekStart = _today.subtract(Duration(days: _today.weekday - 1));
    _week = _buildWeek(_weekStart);
    final todayIdx = _week.indexWhere((d) => _isSameDay(d.date, _today));
    _selectedIndex = todayIdx == -1 ? 0 : todayIdx;
  }

  // ── Dummy data ────────────────────────────────────────────────────────────
  // The trainer has only assigned workouts through Friday this week — the
  // weekend is intentionally left without a plan to demonstrate the
  // "not yet assigned" state.
  List<_WorkoutDay> _buildWeek(DateTime monday) {
    final plans = <Map<String, dynamic>>[
      {
        'focus': 'Chest & Triceps',
        'exercises': [
          _Exercise(
            'Bench Press',
            '4',
            '10',
            '60s',
            'Keep your shoulder blades pinned back.',
            Icons.fitness_center_rounded,
          ),
          _Exercise(
            'Incline Dumbbell Press',
            '3',
            '12',
            '45s',
            'Control the descent — don\u2019t bounce at the bottom.',
            Icons.fitness_center_rounded,
          ),
          _Exercise(
            'Cable Fly',
            '3',
            '15',
            '30s',
            'Squeeze at the centre for a 1-second pause.',
            Icons.sports_gymnastics_rounded,
          ),
          _Exercise(
            'Tricep Pushdown',
            '3',
            '12',
            '30s',
            'Keep elbows tucked to your sides throughout.',
            Icons.sports_gymnastics_rounded,
          ),
          _Exercise(
            'Treadmill Cooldown',
            '1',
            '15 min',
            '\u2014',
            'Easy pace — focus on breathing.',
            Icons.directions_run_rounded,
          ),
        ],
      },
      {
        'focus': 'Back & Biceps',
        'exercises': [
          _Exercise(
            'Lat Pulldown',
            '4',
            '12',
            '60s',
            'Pull to your upper chest, not your neck.',
            Icons.fitness_center_rounded,
          ),
          _Exercise(
            'Seated Cable Row',
            '3',
            '12',
            '45s',
            'Lead with your elbows, not your hands.',
            Icons.fitness_center_rounded,
          ),
          _Exercise(
            'Barbell Curl',
            '3',
            '12',
            '30s',
            'No swinging — keep elbows fixed.',
            Icons.sports_gymnastics_rounded,
          ),
          _Exercise(
            'Hammer Curl',
            '3',
            '12',
            '30s',
            'Slow and controlled on the way down.',
            Icons.sports_gymnastics_rounded,
          ),
        ],
      },
      {
        'focus': 'Leg Day',
        'exercises': [
          _Exercise(
            'Back Squat',
            '4',
            '10',
            '90s',
            'Drive through your heels.',
            Icons.fitness_center_rounded,
          ),
          _Exercise(
            'Leg Press',
            '3',
            '12',
            '60s',
            'Don\u2019t lock your knees out fully.',
            Icons.fitness_center_rounded,
          ),
          _Exercise(
            'Walking Lunges',
            '3',
            '20',
            '45s',
            'Keep your torso upright.',
            Icons.sports_gymnastics_rounded,
          ),
          _Exercise(
            'Calf Raise',
            '4',
            '15',
            '30s',
            'Pause at the top for a full squeeze.',
            Icons.sports_gymnastics_rounded,
          ),
        ],
      },
      {
        'focus': 'Shoulders & Core',
        'exercises': [
          _Exercise(
            'Overhead Press',
            '4',
            '10',
            '60s',
            'Brace your core before each rep.',
            Icons.fitness_center_rounded,
          ),
          _Exercise(
            'Lateral Raise',
            '3',
            '15',
            '30s',
            'Lead with your elbows, light weight.',
            Icons.sports_gymnastics_rounded,
          ),
          _Exercise(
            'Face Pull',
            '3',
            '15',
            '30s',
            'Pull to eye level, squeeze shoulder blades.',
            Icons.sports_gymnastics_rounded,
          ),
          _Exercise(
            'Plank Hold',
            '3',
            '45s',
            '30s',
            'Keep hips level — don\u2019t sag.',
            Icons.self_improvement_rounded,
          ),
        ],
      },
      {
        'focus': 'Full Body Conditioning',
        'exercises': [
          _Exercise(
            'Kettlebell Swing',
            '4',
            '15',
            '45s',
            'Power from your hips, not your arms.',
            Icons.fitness_center_rounded,
          ),
          _Exercise(
            'Box Step-Up',
            '3',
            '12',
            '30s',
            'Drive up through your front heel.',
            Icons.sports_gymnastics_rounded,
          ),
          _Exercise(
            'Battle Ropes',
            '4',
            '30s',
            '30s',
            'Stay low, keep waves consistent.',
            Icons.waves_rounded,
          ),
          _Exercise(
            'Treadmill Intervals',
            '1',
            '12 min',
            '\u2014',
            '1 min fast, 1 min recovery.',
            Icons.directions_run_rounded,
          ),
        ],
      },
    ];

    return List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      final hasPlan = i < plans.length; // Sat (5) & Sun (6) not assigned yet
      if (!hasPlan) {
        return _WorkoutDay(
          date: date,
          focus: 'Rest / Not Assigned',
          exercises: const [],
          assigned: false,
        );
      }
      final plan = plans[i];
      final exercises = List<_Exercise>.from(plan['exercises'] as List);
      // Mark exercises done for days strictly before today to simulate history.
      if (date.isBefore(_today)) {
        for (final e in exercises) {
          e.done = true;
        }
      } else if (_isSameDay(date, _today)) {
        for (var j = 0; j < exercises.length; j++) {
          exercises[j].done = j < 2; // partially completed today
        }
      }
      return _WorkoutDay(
        date: date,
        focus: plan['focus'] as String,
        exercises: exercises,
        assigned: true,
      );
    });
  }

  _DayStatus _statusFor(_WorkoutDay day) {
    if (!day.assigned) return _DayStatus.notAssigned;
    if (_isSameDay(day.date, _today)) return _DayStatus.today;
    if (day.date.isBefore(_today)) return _DayStatus.completed;
    return _DayStatus.upcoming;
  }

  void _openDay(int index) {
    setState(() {
      _selectedIndex = index;
      _viewMode = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    final rangeLabel =
        '${_weekStart.day} ${_monthShort[_weekStart.month - 1]} \u2013 '
        '${weekEnd.day} ${_monthShort[weekEnd.month - 1]}';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Workout Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              rangeLabel,
              style: TextStyle(
                color: Colors.white.withAOpacity(0.45),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            tooltip: 'Workout history',
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildModeToggle(),
            const SizedBox(height: 16),
            Expanded(
              child: _viewMode == 0 ? _buildDailyView() : _buildWeeklyView(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Daily / Weekly toggle ───────────────────────────────────────────────────
  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [_toggleSegment('Daily', 0), _toggleSegment('Weekly', 1)],
        ),
      ),
    );
  }

  Widget _toggleSegment(String label, int index) {
    final selected = _viewMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ── Daily view ───────────────────────────────────────────────────────────────
  Widget _buildDailyView() {
    final day = _week[_selectedIndex];
    final status = _statusFor(day);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        _buildDateStrip(),
        const SizedBox(height: 20),
        if (!day.assigned)
          _buildNotAssignedCard(day)
        else
          _buildDayDetailCard(day, status),
      ],
    );
  }

  Widget _buildDateStrip() {
    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _week.length,
        itemBuilder: (_, i) {
          final day = _week[i];
          final status = _statusFor(day);
          final selected = i == _selectedIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: Container(
              width: 56,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppTheme.primary
                      : Colors.white.withAOpacity(0.06),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayShort[i],
                    style: TextStyle(
                      color: selected
                          ? Colors.white.withAOpacity(0.85)
                          : AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${day.date.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _statusDot(status, small: true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusDot(_DayStatus status, {bool small = false}) {
    IconData? icon;
    Color color;
    switch (status) {
      case _DayStatus.completed:
        icon = Icons.check_rounded;
        color = AppTheme.success;
        break;
      case _DayStatus.today:
        icon = null;
        color = AppTheme.primary;
        break;
      case _DayStatus.upcoming:
        icon = Icons.schedule_rounded;
        color = AppTheme.textSecondary;
        break;
      case _DayStatus.notAssigned:
        icon = Icons.lock_outline_rounded;
        color = AppTheme.textSecondary.withAOpacity(0.6);
        break;
    }
    final size = small ? 14.0 : 16.0;
    if (icon == null) {
      return Container(
        width: small ? 6 : 8,
        height: small ? 6 : 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }
    return Icon(icon, color: color, size: size);
  }

  Widget _buildDayDetailCard(_WorkoutDay day, _DayStatus status) {
    final isEditable = status == _DayStatus.today;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAOpacity(0.06), width: 1),
      ),
      child: Column(
        children: [
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
                      Text(
                        _weekdayFull[day.date.weekday - 1],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${day.focus} \u2014 ${day.exercises.length} exercises',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(status),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(day.exercises.length, (i) {
            final ex = day.exercises[i];
            return _ExerciseTile(
              exercise: ex,
              locked: !isEditable,
              readDone: status == _DayStatus.completed,
              onToggle: isEditable
                  ? () => setState(() => ex.done = !ex.done)
                  : null,
            );
          }),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.textSecondary,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    status == _DayStatus.completed
                        ? 'This is a past workout \u2014 view only.'
                        : status == _DayStatus.upcoming
                        ? 'Upcoming \u2014 you can mark exercises done on the day.'
                        : 'Tap an exercise to mark it as done.',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(_DayStatus status) {
    late String label;
    late Color color;
    switch (status) {
      case _DayStatus.completed:
        label = 'Completed';
        color = AppTheme.success;
        break;
      case _DayStatus.today:
        label = 'Today';
        color = AppTheme.primary;
        break;
      case _DayStatus.upcoming:
        label = 'Upcoming';
        color = const Color(0xFF29B6F6);
        break;
      case _DayStatus.notAssigned:
        label = 'Not Assigned';
        color = AppTheme.textSecondary;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildNotAssignedCard(_WorkoutDay day) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAOpacity(0.06), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withAOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              color: AppTheme.textSecondary,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _weekdayFull[day.date.weekday - 1],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No workout has been assigned for this day yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your trainer will assign one soon \u2014 check back later.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Weekly view ──────────────────────────────────────────────────────────────
  Widget _buildWeeklyView() {
    final assignedDays = _week.where((d) => d.assigned).toList();
    final totalExercises = assignedDays.fold<int>(
      0,
      (sum, d) => sum + d.exercises.length,
    );
    final totalDone = assignedDays.fold<int>(0, (sum, d) => sum + d.doneCount);
    final weekProgress = totalExercises == 0 ? 0.0 : totalDone / totalExercises;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        _buildWeekSummaryCard(
          assignedDays.length,
          totalDone,
          totalExercises,
          weekProgress,
        ),
        const SizedBox(height: 18),
        ...List.generate(_week.length, (i) => _buildWeekDayRow(i)),
      ],
    );
  }

  Widget _buildWeekSummaryCard(
    int assignedDays,
    int done,
    int total,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A0008), Color(0xFF1A1A1A)],
        ),
        border: Border.all(color: AppTheme.primary.withAOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withAOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This Week\u2019s Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$done of $total exercises done \u00b7 $assignedDays days assigned',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDayRow(int index) {
    final day = _week[index];
    final status = _statusFor(day);
    final accent = !day.assigned
        ? AppTheme.textSecondary
        : status == _DayStatus.completed
        ? AppTheme.success
        : status == _DayStatus.today
        ? AppTheme.primary
        : const Color(0xFF29B6F6);

    return GestureDetector(
      onTap: () => _openDay(index),
      child: Container(
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withAOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: day.assigned
                    ? Text(
                        '${day.date.day}',
                        style: TextStyle(
                          color: accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : Icon(Icons.lock_outline_rounded, color: accent, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _weekdayFull[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    day.assigned
                        ? '${day.focus} \u00b7 ${day.exercises.length} exercises'
                        : 'No workout assigned',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (day.assigned)
              Text(
                '${day.doneCount}/${day.exercises.length}',
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Exercise tile ────────────────────────────────────────────────────────────

class _ExerciseTile extends StatelessWidget {
  final _Exercise exercise;
  final bool locked;
  final bool readDone;
  final VoidCallback? onToggle;
  const _ExerciseTile({
    required this.exercise,
    required this.locked,
    required this.readDone,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final done = exercise.done;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(top: 2),
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
                  : locked
                  ? Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white.withAOpacity(0.3),
                      size: 12,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
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
                exercise.icon,
                size: 17,
                color: done ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
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
                    '${exercise.sets} sets \u00b7 ${exercise.reps} reps \u00b7 ${exercise.rest} rest',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withAOpacity(
                        done ? 0.5 : 1,
                      ),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.tip,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSecondary.withAOpacity(
                        done ? 0.4 : 0.8,
                      ),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (!done && !locked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${exercise.sets}\u00d7${exercise.reps}',
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
