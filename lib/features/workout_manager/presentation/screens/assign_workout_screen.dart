import 'dart:async';

import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/constants/constants.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/di.dart';
import 'package:club_fitness/features/workout_manager/workout_manager.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AssignWorkoutProvider extends StatelessWidget {
  const AssignWorkoutProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AssignWorkoutBloc(sl(), sl(), sl())
            ..add(const GetAllExercisesEvent())
            ..add(const GetWorkoutTemplatesEvent()),
        ),
        BlocProvider(
          create: (context) =>
              MembersListingBloc(sl())..add(const GetMembersListingEvent()),
        ),
        BlocProvider(
          create: (_) => AssignWorkoutActionsBloc(sl(), sl(), sl(), sl()),
        ),
      ],
      child: const AssignWorkoutScreen(),
    );
  }
}

// ─── Local Plan Models (assignment-only state, not backed by bloc) ────────────

class _PlanExercise {
  final ExerciseEntity exercise;
  int sets = 3;
  int reps = 15;
  int restSeconds = 60;
  String notes = '';
  _PlanExercise({required this.exercise});
}

class _WorkoutDay {
  final String day;
  final List<_PlanExercise> exercises;
  bool isRest = false;
  _WorkoutDay({required this.day, required this.exercises});
}

const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

// ─── Category → visual mapping (ExerciseEntity has no icon/color fields) ──────

IconData _iconForCategory(String category) {
  bool iconReady = IconMapper.isAvailable(category);
  if (iconReady) return IconMapper.getIconData(category);
  switch (category.toLowerCase()) {
    case 'chest':
    case 'back':
    case 'legs':
    case 'shoulders':
      return Icons.fitness_center_rounded;
    case 'arms':
      return Icons.sports_gymnastics_rounded;
    case 'core':
      return Icons.self_improvement_rounded;
    case 'cardio':
      return Icons.directions_run_rounded;
    default:
      return Icons.fitness_center_rounded;
  }
}

Color _colorForCategory(String category) {
  return AppTheme.clampColor(category.hashCode);
}

int _dayIndexFor(String dayOfWeek) {
  final normalized = dayOfWeek.trim().toLowerCase();
  for (var i = 0; i < _weekDays.length; i++) {
    if (_weekDays[i].toLowerCase() ==
        normalized.substring(
          0,
          normalized.length < 3 ? normalized.length : 3,
        )) {
      return i;
    }
  }
  return 0;
}

// ─── Main Screen ──────────────────────────────────────────────────────────────

class AssignWorkoutScreen extends StatefulWidget {
  const AssignWorkoutScreen({super.key});
  @override
  State<AssignWorkoutScreen> createState() => _AssignWorkoutScreenState();
}

class _AssignWorkoutScreenState extends State<AssignWorkoutScreen>
    with TickerProviderStateMixin {
  // Steps: 0 = Plan Type, 1 = Build Plan, 2 = Select Members, 3 = Confirm
  int _step = 0;

  // Plan config
  String _planName = '';
  final TextEditingController _planNameCtrl = TextEditingController();
  String _planType = 'weekly'; // 'daily' | 'weekly'
  int _selectedDayIndex = 0; // for weekly view
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  final _scrollCtrl = ScrollController();

  void _scrollListener() {
    if (_scrollCtrl.position.pixels >=
        0.8 * _scrollCtrl.position.maxScrollExtent) {
      context.read<AssignWorkoutBloc>().add(
        GetAllExercisesEvent(
          search: _exerciseSearch.orNull(),
          category: _categoryFilter == 'All' ? null : _categoryFilter,
          isLoadMore: true,
        ),
      );
    }
  }

  // Weekly plan: 7 days
  late final List<_WorkoutDay> _weekPlan;

  // Exercise library filter
  String _categoryFilter = 'All';
  String _exerciseSearch = '';
  Timer? _searchDebounce;

  String? _appliedTemplateId;
  // Snapshot of the plan captured the moment a template is applied, used to
  // detect whether the user has since made changes to it.
  Map<String, dynamic>? _templateSnapshot;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _stepCtrl;
  late final Animation<Offset> _stepSlide;
  late final Animation<double> _stepFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _weekPlan = _weekDays
        .map((d) => _WorkoutDay(day: d, exercises: []))
        .toList();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _stepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _stepSlide = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut));
    _stepFade = CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut);
    _stepCtrl.value = 1.0;

    _scrollCtrl.addListener(_scrollListener);
    _memberScroll.addListener(_memberScrollListener);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _stepCtrl.dispose();
    _searchDebounce?.cancel();
    _scrollCtrl.dispose();
    _memberScroll.dispose();
    _planNameCtrl.dispose();
    _memberSearchDebounce?.cancel();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 3) {
      setState(() => _step++);
      _stepCtrl.forward(from: 0);
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _stepCtrl.forward(from: 0);
    }
  }

  _WorkoutDay get _currentDay => _weekPlan[_selectedDayIndex];

  int get _totalExercises =>
      _weekPlan.fold(0, (sum, d) => sum + d.exercises.length);

  int get _selectedMemberCount => _assignTargets.length;

  final Set<String> _assignTargets = {};

  void _addExerciseToPlan(ExerciseEntity ex) {
    final day = _planType == 'weekly' ? _currentDay : _weekPlan[0];
    if (day.exercises.any((e) => e.exercise.id == ex.id)) return;
    setState(() => day.exercises.add(_PlanExercise(exercise: ex)));
  }

  void _removeExercise(int dayIdx, int exIdx) {
    setState(() => _weekPlan[dayIdx].exercises.removeAt(exIdx));
  }

  void _onSearchChanged(String value) {
    _exerciseSearch = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      context.read<AssignWorkoutBloc>().add(
        GetAllExercisesEvent(
          search: value.isEmpty ? null : value,
          category: _categoryFilter == 'All' ? null : _categoryFilter,
        ),
      );
    });
  }

  void _onCategoryChanged(String category) {
    setState(() => _categoryFilter = category);
    context.read<AssignWorkoutBloc>().add(
      GetAllExercisesEvent(
        search: _exerciseSearch.isEmpty ? null : _exerciseSearch,
        category: category == 'All' ? null : category,
      ),
    );
  }

  void _applyTemplate(TemplateDetailsEntity details) {
    setState(() {
      _planName = details.name;
      // FIX: previously this only reflected in the UI after leaving and
      // returning to Step 0, because `_InputField` used `initialValue`
      // (applied once, on first build) instead of a controller. Updating
      // the controller directly makes it show immediately.
      _planNameCtrl.text = details.name;

      _planType = details.type.isEmpty ? _planType : details.type.toLowerCase();

      final start = DateTime.tryParse(details.startDate);
      final end = DateTime.tryParse(details.endDate);
      if (start != null) _startDate = start;
      if (end != null) _endDate = end;

      for (final d in _weekPlan) {
        d.exercises.clear();
        d.isRest = false;
      }

      for (final day in details.days) {
        final idx = _dayIndexFor(day.dayOfWeek);
        final target = _weekPlan[idx];
        target.isRest = day.isRestDay;
        if (!day.isRestDay) {
          target.exercises
            ..clear()
            ..addAll(
              day.exercises.map((e) => _PlanExercise(exercise: e.exercise)),
            );
        }
      }

      // Baseline snapshot for change detection — captured *after* the plan
      // has been populated from the template.
      _templateSnapshot = _captureSnapshot();
    });
  }

  // ── Template change detection ───────────────────────────────────────────────

  Map<String, dynamic> _captureSnapshot() {
    return {
      'name': _planName,
      'type': _planType,
      'start': _startDate.toIso8601String().split('T').first,
      'end': _endDate.toIso8601String().split('T').first,
      'days': _weekPlan
          .map(
            (d) => {
              'day': d.day,
              'isRest': d.isRest,
              'exercises': d.exercises
                  .map(
                    (pe) => {
                      'id': pe.exercise.id,
                      'sets': pe.sets,
                      'reps': pe.reps,
                      'rest': pe.restSeconds,
                      'notes': pe.notes,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };
  }

  bool _hasChangesFromTemplate() {
    if (_appliedTemplateId == null || _templateSnapshot == null) return false;
    return !_deepEquals(_captureSnapshot(), _templateSnapshot);
  }

  bool _deepEquals(dynamic a, dynamic b) {
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key)) return false;
        if (!_deepEquals(a[key], b[key])) return false;
      }
      return true;
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }
    return a == b;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AssignWorkoutBloc, AssignWorkoutState>(
          listenWhen: (prev, curr) =>
              curr.selectedTemplate != null &&
              curr.selectedTemplate!.id != prev.selectedTemplate?.id,
          listener: (context, state) {
            if (state.selectedTemplate != null) {
              _applyTemplate(state.selectedTemplate!);
            }
          },
        ),
        BlocListener<AssignWorkoutActionsBloc, AssignWorkoutActionsState>(
          listener: (context, state) {
            if (state is ExerciseCreatedState) {
              context.showToast(
                'Exercise Created',
                message:
                    'New exercise ${state.exercise.name} has been added to ${state.exercise.category}',
              );
            } else if (state is AssignWorkoutActionsSuccess) {
              _showAssignedDialog(state.response);
            } else if (state is AssignWorkoutActionsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure.message),
                  backgroundColor: AppTheme.error,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildTopBar(),
              _buildStepIndicator(),
              Expanded(
                child: FadeTransition(
                  opacity: _stepFade,
                  child: SlideTransition(
                    position: _stepSlide,
                    child: _buildStepContent(),
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Bar ─────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    final titles = [
      'Plan Setup',
      'Build Workout',
      'Select Members',
      'Confirm & Assign',
    ];
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _step == 0
                  ? () => Navigator.of(context).maybePop()
                  : _prevStep,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titles[_step],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Step ${_step + 1} of 4',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (_totalExercises > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primary.withAOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$_totalExercises exercises',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Step Indicator ───────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: List.generate(4, (i) {
          final done = i < _step;
          final active = i == _step;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done || active
                          ? AppTheme.primary
                          : Colors.white.withAOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 3) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Step Router ──────────────────────────────────────────────────────────────
  Widget _buildStepContent() {
    return switch (_step) {
      0 => _buildStep0(),
      1 => _buildStep1(),
      2 => _buildStep2(),
      _ => _buildStep3(),
    };
  }

  // ── STEP 0 — Plan Setup ──────────────────────────────────────────────────────
  Widget _buildStep0() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Plan Name'),
          const SizedBox(height: 10),
          _InputField(
            hint: 'e.g. Chest & Triceps Week 1',
            icon: Icons.edit_rounded,
            controller: _planNameCtrl,
            onChanged: (v) => setState(() => _planName = v),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Plan Type'),
          const SizedBox(height: 10),
          Row(
            children: [
              _TypeCard(
                icon: Icons.today_rounded,
                title: 'Daily',
                subtitle: 'One workout for a specific day',
                selected: _planType == 'daily',
                onTap: () => setState(() => _planType = 'daily'),
              ),
              const SizedBox(width: 12),
              _TypeCard(
                icon: Icons.calendar_view_week_rounded,
                title: 'Weekly',
                subtitle: 'Full Mon–Sun workout schedule',
                selected: _planType == 'weekly',
                onTap: () => setState(() => _planType = 'weekly'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionLabel('Active Period'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  label: 'Start Date',
                  date: _startDate,
                  icon: Icons.calendar_today_rounded,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (_, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppTheme.primary,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (d != null) setState(() => _startDate = d);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateTile(
                  label: 'End Date',
                  date: _endDate,
                  icon: Icons.event_rounded,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: _startDate,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (_, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppTheme.primary,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (d != null) setState(() => _endDate = d);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primary.withAOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Duration: ${_endDate.difference(_startDate).inDays + 1} days  ·  Members can view this plan until the end date.',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Or Start from a Template'),
          const SizedBox(height: 10),
          _buildTemplateRow(),
          _buildSelectedTemplateDetails(),
        ],
      ),
    );
  }

  Widget _buildTemplateRow() {
    return BlocBuilder<AssignWorkoutBloc, AssignWorkoutState>(
      builder: (context, state) {
        if (state is WorkoutTemplateLoadingState && state.templates.isEmpty) {
          return const SizedBox(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            ),
          );
        }
        if (state.templates.isEmpty) {
          return const SizedBox(
            height: 80,
            child: Center(
              child: Text(
                'No templates yet',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
          );
        }
        final isApplying = state is SelectedTemplateLoadingState;
        return SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: state.templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final t = state.templates[i];
              final selected = _appliedTemplateId == t.id;
              return GestureDetector(
                onTap: () {
                  setState(() => _appliedTemplateId = t.id);
                  context.read<AssignWorkoutBloc>().add(
                    GetTemplateDetailsEvent(t.id),
                  );
                },
                child: Container(
                  width: 130,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.primary.withAOpacity(0.25),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.description_rounded,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                          if (selected && isApplying) ...[
                            const Spacer(),
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      Text(
                        t.name.isEmpty ? 'Untitled' : t.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${t.totalExercises} exercises',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Details card shown below the template row once a template is selected.
  Widget _buildSelectedTemplateDetails() {
    return BlocBuilder<AssignWorkoutBloc, AssignWorkoutState>(
      builder: (context, state) {
        if (_appliedTemplateId == null || state.selectedTemplate == null) {
          return const SizedBox.shrink();
        }
        final t = state.selectedTemplate!;
        return Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primary.withAOpacity(0.25),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.name.isEmpty ? 'Untitled Template' : t.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (t.type.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.type,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Created by ${t.createdBy.name.isEmpty ? 'Unknown' : t.createdBy.name}'
                ' · Used ${t.count.assignments} time(s)',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: t.days.map((d) {
                  final hasEx = !d.isRestDay && d.exercises.isNotEmpty;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: d.isRestDay
                          ? Colors.white.withAOpacity(0.05)
                          : hasEx
                          ? AppTheme.primary.withAOpacity(0.1)
                          : Colors.white.withAOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasEx
                            ? AppTheme.primary.withAOpacity(0.25)
                            : Colors.white.withAOpacity(0.06),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      d.isRestDay
                          ? '${d.dayOfWeek} · Rest'
                          : '${d.dayOfWeek} · ${d.exercises.length}',
                      style: TextStyle(
                        color: hasEx ? Colors.white : AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  List<WorkoutDayInputEntity> _buildDaysPayload() {
    if (_planType == 'weekly') {
      return _weekPlan.map(_dayToInput).toList();
    }
    // Daily plan: single day entry, labeled with the actual weekday of startDate
    // so the backend's dayOfWeek matching in getWeek/toggleExercise still lines up.
    final weekdayLabel = _weekDays[(_startDate.weekday - 1) % 7];
    return [_dayToInput(_weekPlan[0], overrideLabel: weekdayLabel)];
  }

  WorkoutDayInputEntity _dayToInput(_WorkoutDay d, {String? overrideLabel}) {
    return WorkoutDayInputEntity(
      dayOfWeek: overrideLabel ?? d.day,
      isRestDay: d.isRest,
      exercises: d.isRest
          ? const []
          : List.generate(d.exercises.length, (i) {
              final pe = d.exercises[i];
              return ExerciseInputEntity(
                exerciseId: pe.exercise.id,
                sets: pe.sets,
                reps: pe.reps,
                restSeconds: pe.restSeconds,
                notes: pe.notes,
                orderIndex: i,
              );
            }),
    );
  }

  // ── STEP 1 — Build Workout ───────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      children: [
        if (_planType == 'weekly') ...[
          const SizedBox(height: 16),
          _buildDayTabs(),
        ] else
          const SizedBox(height: 16),
        _buildCurrentDayExercises(),
        Expanded(child: _buildExercisePicker()),
      ],
    );
  }

  Widget _buildDayTabs() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 7,
        itemBuilder: (_, i) {
          final day = _weekPlan[i];
          final selected = _selectedDayIndex == i;
          final hasEx = day.exercises.isNotEmpty;
          final isRest = day.isRest;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isRest
                    ? Colors.white.withAOpacity(0.04)
                    : selected
                    ? AppTheme.primary
                    : AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? AppTheme.primary
                      : hasEx
                      ? AppTheme.primary.withAOpacity(0.3)
                      : Colors.white.withAOpacity(0.07),
                  width: selected ? 0 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    day.day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (hasEx && !selected) ...[
                    const SizedBox(width: 5),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  if (isRest) ...[
                    const SizedBox(width: 5),
                    const Text('🛌', style: TextStyle(fontSize: 10)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentDayExercises() {
    final day = _planType == 'weekly' ? _currentDay : _weekPlan[0];
    final dayIdx = _planType == 'weekly' ? _selectedDayIndex : 0;

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAOpacity(0.06), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _planType == 'weekly'
                      ? '${day.day} — ${day.exercises.length} exercises'
                      : 'Today — ${day.exercises.length} exercises',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (_planType == 'weekly')
                  GestureDetector(
                    onTap: () => setState(() {
                      day.isRest = !day.isRest;
                      if (day.isRest) day.exercises.clear();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: day.isRest
                            ? Colors.white.withAOpacity(0.08)
                            : AppTheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withAOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        day.isRest ? '🛌 Rest Day' : 'Set Rest',
                        style: TextStyle(
                          color: day.isRest
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (day.isRest)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Rest day — no exercises',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ),
            )
          else if (day.exercises.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Tap exercises below to add',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            Flexible(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: day.exercises.length,
                onReorder: (oldIdx, newIdx) {
                  setState(() {
                    if (newIdx > oldIdx) newIdx--;
                    final item = day.exercises.removeAt(oldIdx);
                    day.exercises.insert(newIdx, item);
                  });
                },
                itemBuilder: (_, i) {
                  final pe = day.exercises[i];
                  return _PlanExerciseTile(
                    key: ValueKey(pe.exercise.id + day.day + i.toString()),
                    planEx: pe,
                    index: i,
                    onRemove: () => _removeExercise(dayIdx, i),
                    onEdit: () => _editExercise(pe),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExercisePicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SearchBar(
                  hint: 'Search exercises…',
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _openAddExerciseSheet,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BlocBuilder<AssignWorkoutBloc, AssignWorkoutState>(
            builder: (context, state) {
              final categories = [
                ...state.exercise.categories.map((c) => c.name),
              ];
              return SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final c = categories[i];
                    final sel = _categoryFilter == c;
                    return GestureDetector(
                      onTap: () => _onCategoryChanged(c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.primary : AppTheme.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: sel
                                ? AppTheme.primary
                                : Colors.white.withAOpacity(0.07),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(
                            color: sel ? Colors.white : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<AssignWorkoutBloc, AssignWorkoutState>(
              builder: (context, state) {
                if (state is ExerciseLoadingState &&
                    state.exercise.exercises.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }
                if (state is AssignWorkoutFailureState &&
                    state.exercise.exercises.isEmpty) {
                  return Center(
                    child: Text(
                      state.failure.message,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                final exercises = state.exercise.exercises;
                if (exercises.isEmpty) {
                  return const Center(
                    child: Text(
                      'No exercises found',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  controller: _scrollCtrl,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: exercises.length,
                  itemBuilder: (_, i) {
                    final ex = exercises[i];
                    final day = _planType == 'weekly'
                        ? _currentDay
                        : _weekPlan[0];
                    final added = day.exercises.any(
                      (e) => e.exercise.id == ex.id,
                    );
                    return _ExerciseLibraryTile(
                      exercise: ex,
                      added: added,
                      onTap: () => _addExerciseToPlan(ex),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Opens the "create new exercise" bottom sheet.
  void _openAddExerciseSheet() {
    final categories = context
        .read<AssignWorkoutBloc>()
        .state
        .exercise
        .categories
        .map((c) => c.name)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExerciseSheet(
        existingCategories: categories,
        onSubmit: (payload) {
          context.read<AssignWorkoutActionsBloc>().add(
            CreateExerciseEvent(
              name: payload.name,
              category: payload.category,
              difficulty: payload.difficulty,
              muscle: payload.muscle,
              description: payload.description,
              videoUrl: payload.videoUrl,
              imageUrl: payload.imageUrl,
            ),
          );
        },
      ),
    );
  }

  final _memberScroll = ScrollController();

  void _memberScrollListener() {
    if (_memberScroll.position.pixels >=
        0.8 * _memberScroll.position.maxScrollExtent) {
      context.read<MembersListingBloc>().add(
        const GetMoreMembersListingEvent(),
      );
    }
  }

  Timer? _memberSearchDebounce;

  void _searchMembers(String v) {
    _memberSearchDebounce?.cancel();
    _memberSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      context.read<MembersListingBloc>().add(GetMembersListingEvent(search: v));
    });
  }

  // ── STEP 2 — Select Members ──────────────────────────────────────────────────
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: BlocBuilder<MembersListingBloc, MembersListingState>(
        builder: (context, state) {
          List<MemberListEntity> members = [];
          Summary summary = const Summary();
          if (state is MembersListingSuccess) {
            members = state.members;
            summary = state.summary;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Who gets this plan?'),
              const SizedBox(height: 4),
              Text(
                'Select one or more members to assign the plan to.',
                style: TextStyle(
                  color: Colors.white.withAOpacity(0.35),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              _SearchBar(hint: 'Search members…', onChanged: _searchMembers),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedMemberCount of ${summary.total} selected',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: members.isEmpty
                    ? const Center(
                        child: Text(
                          'No members found',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: _memberScroll,
                        physics: const BouncingScrollPhysics(),
                        itemCount: members.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final t = members[i];
                          return _MemberSelectTile(
                            target: t,
                            selected: t.id.isIn(_assignTargets),
                            onTap: () => setState(
                              () => _assignTargets.addOrRemove(t.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── STEP 3 — Confirm ─────────────────────────────────────────────────────────
  Widget _buildStep3() {
    return BlocBuilder<MembersListingBloc, MembersListingState>(
      builder: (context, state) {
        List<MemberListEntity> members = [];
        if (state is MembersListingSuccess) {
          members = state.members;
        }

        final selected = members
            .where((element) => element.id.isIn(_assignTargets))
            .toList();
        final totalEx = _weekPlan.fold(0, (s, d) => s + d.exercises.length);
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2A0008), Color(0xFF1A1A1A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primary.withAOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: AppTheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _planName.isEmpty ? 'Unnamed Plan' : _planName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '${_planType == 'weekly' ? 'Weekly' : 'Daily'} Plan',
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
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _ConfirmStat(
                          icon: Icons.fitness_center_rounded,
                          value: '$totalEx',
                          label: 'Exercises',
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 20),
                        _ConfirmStat(
                          icon: Icons.people_alt_rounded,
                          value: '${selected.length}',
                          label: 'Members',
                          color: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 20),
                        _ConfirmStat(
                          icon: Icons.date_range_rounded,
                          value:
                              '${_endDate.difference(_startDate).inDays + 1}d',
                          label: 'Duration',
                          color: const Color(0xFF29B6F6),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 12),
                    _ConfirmRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Start',
                      value:
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                    ),
                    const SizedBox(height: 6),
                    _ConfirmRow(
                      icon: Icons.event_rounded,
                      label: 'End',
                      value:
                          '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel('Assigned To'),
              const SizedBox(height: 12),
              ...selected.map(
                (t) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: t.avatarColor.withAOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: t.avatarColor.withAOpacity(0.18),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: Text(
                            t.initials,
                            style: TextStyle(
                              color: t.avatarColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              t.plan,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF4CAF50),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel('Weekly Breakdown'),
              const SizedBox(height: 12),
              ..._weekPlan.map((d) {
                if (d.isRest) {
                  return _WeekdayRow(
                    day: d.day,
                    label: 'Rest Day',
                    count: 0,
                    isRest: true,
                  );
                }
                return _WeekdayRow(
                  day: d.day,
                  label: '${d.exercises.length} exercises',
                  count: d.exercises.length,
                  isRest: false,
                );
              }),
              const SizedBox(height: 20),
              _NotifyToggle(
                notify: _notify,
                onToggle: (value) => setState(() => _notify = value),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _notify = true;

  // ── Bottom Bar ───────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final isLast = _step == 3;
    final canProgress = switch (_step) {
      0 => true,
      1 => _totalExercises > 0,
      2 => _selectedMemberCount > 0,
      _ => true,
    };

    return BlocBuilder<AssignWorkoutActionsBloc, AssignWorkoutActionsState>(
      builder: (context, actionState) {
        final submitting = actionState is AssignWorkoutActionsInProgress;
        final label = switch (actionState) {
          AssignWorkoutActionsInProgress(:final stage) => switch (stage) {
            AssignWorkoutStage.creatingPlan => 'Creating plan…',
            AssignWorkoutStage.savingTemplate => 'Saving template…',
            AssignWorkoutStage.assigning => 'Assigning…',
            AssignWorkoutStage.creatingExercise => 'Creating exercise…',
          },
          _ => isLast ? 'Assign Workout' : 'Continue',
        };
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: const Border(
                top: BorderSide(color: Colors.white10, width: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_step > 0 && !submitting)
                  GestureDetector(
                    onTap: _prevStep,
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withAOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                Expanded(
                  child: GestureDetector(
                    onTap: (canProgress && !submitting)
                        ? () {
                            if (isLast) {
                              _assignWorkout();
                            } else {
                              _nextStep();
                            }
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 50,
                      decoration: BoxDecoration(
                        color: canProgress
                            ? AppTheme.primary
                            : AppTheme.primary.withAOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: canProgress
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary.withAOpacity(0.3),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    isLast
                                        ? Icons.check_rounded
                                        : Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────
  void _editExercise(_PlanExercise pe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditExerciseSheet(planEx: pe),
    ).then((_) => setState(() {}));
  }

  // Entry point from the bottom bar's "Assign Workout" button. If the plan
  // started from a template and has since diverged from it, ask the user
  // whether to save the changes as a new template before assigning.
  void _assignWorkout() async {
    bool saveAsTemplate = false;
    if (_hasChangesFromTemplate()) {
      final decision = await _showTemplateChangeDialog();
      if (decision == null) return; // dialog dismissed — abort
      saveAsTemplate = decision;
    }
    if (!mounted) return;

    context.read<AssignWorkoutActionsBloc>().add(
      SubmitWorkoutAssignmentEvent(
        name: _planName.isEmpty ? 'Unnamed Plan' : _planName,
        type: _planType.toUpperCase(),
        startDate: _startDate,
        endDate: _endDate,
        days: _buildDaysPayload(),
        memberIds: _assignTargets.toList(),
        notifyMembers: _notify,
        saveAsNewTemplate: saveAsTemplate,
      ),
    );
  }

  Future<bool?> _showTemplateChangeDialog() {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Changes Detected',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'You started this plan from a template but have made changes to '
          'it. Would you like to save these changes as a new template '
          'before assigning?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Save as New Template',
                    style: TextStyle(
                      color: Colors.white,
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

  void _showAssignedDialog(AssignWorkoutResponseEntity result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4CAF50),
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              'Workout Assigned!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        content: Text(
          'Plan "${_planName.or('Unnamed Plan')}" has been assigned to '
          '${result.assigned} member(s)'
          '${result.skipped > 0 ? ' (${result.skipped} already had it active)' : ''}. '
          'They will${!_notify ? ' not' : ''} be notified.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).maybePop(); // leave the wizard
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(
    t,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    ),
  );
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withAOpacity(0.12)
                : AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppTheme.primary
                  : Colors.white.withAOpacity(0.07),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final IconData icon;
  final VoidCallback onTap;
  const _DateTile({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAOpacity(0.07), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.textSecondary, size: 14),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '${date.day} / ${date.month} / ${date.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanExerciseTile extends StatelessWidget {
  final _PlanExercise planEx;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onEdit;
  const _PlanExerciseTile({
    super.key,
    required this.planEx,
    required this.index,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final ex = planEx.exercise;
    final color = _colorForCategory(ex.category);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.drag_handle_rounded,
                color: AppTheme.textSecondary,
                size: 18,
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withAOpacity(0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_iconForCategory(ex.category), color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ex.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${planEx.sets} sets · ${planEx.reps} reps · ${planEx.restSeconds}s rest',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Icons.edit_rounded,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              color: AppTheme.error,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseLibraryTile extends StatelessWidget {
  final ExerciseEntity exercise;
  final bool added;
  final VoidCallback onTap;
  const _ExerciseLibraryTile({
    required this.exercise,
    required this.added,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForCategory(exercise.category);
    return GestureDetector(
      onTap: added ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: added ? color.withAOpacity(0.08) : AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: added
                ? color.withAOpacity(0.4)
                : Colors.white.withAOpacity(0.06),
            width: added ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withAOpacity(0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconForCategory(exercise.category),
                color: color,
                size: 15,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    exercise.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: added
                          ? Colors.white.withAOpacity(0.5)
                          : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    exercise.muscle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              added ? Icons.check_rounded : Icons.add_rounded,
              color: added ? color : AppTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberSelectTile extends StatelessWidget {
  final MemberListEntity target;
  final bool selected;
  final VoidCallback onTap;
  const _MemberSelectTile({
    required this.target,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? target.avatarColor.withAOpacity(0.08)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? target.avatarColor.withAOpacity(0.45)
                : Colors.white.withAOpacity(0.06),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: target.avatarColor.withAOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: target.avatarColor.withAOpacity(0.35),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  target.initials,
                  style: TextStyle(
                    color: target.avatarColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    target.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    target.plan,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? target.avatarColor : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? target.avatarColor
                      : Colors.white.withAOpacity(0.2),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _ConfirmStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 14),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  final String day;
  final String label;
  final int count;
  final bool isRest;
  const _WeekdayRow({
    required this.day,
    required this.label,
    required this.count,
    required this.isRest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRest
              ? Colors.white.withAOpacity(0.04)
              : count > 0
              ? AppTheme.primary.withAOpacity(0.2)
              : Colors.white.withAOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isRest
                  ? Colors.white.withAOpacity(0.05)
                  : count > 0
                  ? AppTheme.primary.withAOpacity(0.14)
                  : Colors.white.withAOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                isRest ? '🛌' : day,
                style: TextStyle(
                  color: isRest
                      ? Colors.white
                      : count > 0
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.w900,
                  fontSize: isRest ? 14 : 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isRest || count == 0
                  ? AppTheme.textSecondary
                  : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (count > 0)
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4CAF50),
              size: 16,
            ),
          if (!isRest && count == 0)
            Text(
              'No exercises',
              style: TextStyle(
                color: Colors.white.withAOpacity(0.2),
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}

class _NotifyToggle extends StatelessWidget {
  final bool notify;
  final ValueChanged<bool> onToggle;
  const _NotifyToggle({required this.notify, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAOpacity(0.06), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF29B6F6).withAOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFF29B6F6),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notify Members',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Send a push notification when plan is assigned',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
          Switch(
            value: notify,
            onChanged: onToggle,
            activeThumbColor: AppTheme.primary,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}

// ─── Add Exercise Sheet ───────────────────────────────────────────────────────

class _AddExerciseSheet extends StatefulWidget {
  final List<String> existingCategories;
  final void Function(CreateExerciseParams payload) onSubmit;
  const _AddExerciseSheet({
    required this.existingCategories,
    required this.onSubmit,
  });

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _muscleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _videoUrlCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  String _difficulty = 'Beginner';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _muscleCtrl.dispose();
    _descriptionCtrl.dispose();
    _videoUrlCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final params = CreateExerciseParams(
      category: _categoryCtrl.text.trim(),
      difficulty: _difficulty,
      name: _nameCtrl.text.trim(),
      muscle: _muscleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      videoUrl: _videoUrlCtrl.text.trim(),
      imageUrl: _imageUrlCtrl.text.trim(),
    );
    widget.onSubmit(params);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'New Exercise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                const _FormLabel('Name'),
                const SizedBox(height: 6),
                _sheetField(
                  controller: _nameCtrl,
                  hint: 'e.g. Barbell Squat',
                  required: true,
                ),
                const SizedBox(height: 14),
                const _FormLabel('Category'),
                const SizedBox(height: 6),
                TypeAheadField<String>(
                  controller: _categoryCtrl,
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty) return widget.existingCategories;
                    return widget.existingCategories
                        .where(
                          (c) =>
                              c.toLowerCase().contains(pattern.toLowerCase()),
                        )
                        .toList();
                  },
                  itemBuilder: (context, suggestion) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text(
                      suggestion,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  onSelected: (suggestion) => _categoryCtrl.text = suggestion,
                  emptyBuilder: (context) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text(
                      _categoryCtrl.text.isEmpty
                          ? 'Type to search or add a new category'
                          : 'No match — "${_categoryCtrl.text}" will be used as a new category',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  decorationBuilder: (context, child) => Material(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 4,
                    child: child,
                  ),
                  builder: (context, controller, focusNode) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                      decoration: _sheetDecoration('Existing or new category'),
                    );
                  },
                ),
                const SizedBox(height: 14),
                const _FormLabel('Muscle'),
                const SizedBox(height: 6),
                _sheetField(
                  controller: _muscleCtrl,
                  hint: 'e.g. Quadriceps',
                  required: true,
                ),
                const SizedBox(height: 14),
                const _FormLabel('Difficulty'),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withAOpacity(0.07),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _difficulty,
                    dropdownColor: AppTheme.surface,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Beginner',
                        child: Text('Beginner'),
                      ),
                      DropdownMenuItem(
                        value: 'Intermediate',
                        child: Text('Intermediate'),
                      ),
                      DropdownMenuItem(
                        value: 'Advanced',
                        child: Text('Advanced'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _difficulty = v ?? _difficulty),
                  ),
                ),
                const SizedBox(height: 14),
                const _FormLabel('Description'),
                const SizedBox(height: 6),
                _sheetField(
                  controller: _descriptionCtrl,
                  hint: 'Short description (optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                const _FormLabel('Video URL'),
                const SizedBox(height: 6),
                _sheetField(
                  controller: _videoUrlCtrl,
                  hint: 'https://... (optional)',
                ),
                const SizedBox(height: 14),
                const _FormLabel('Image URL'),
                const SizedBox(height: 6),
                _sheetField(
                  controller: _imageUrlCtrl,
                  hint: 'https://... (optional)',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Add Exercise',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String hint,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
      decoration: _sheetDecoration(hint),
    );
  }

  InputDecoration _sheetDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: AppTheme.surface,
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withAOpacity(0.07),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─── Edit Exercise Sheet ──────────────────────────────────────────────────────

class _EditExerciseSheet extends StatefulWidget {
  final _PlanExercise planEx;
  const _EditExerciseSheet({required this.planEx});
  @override
  State<_EditExerciseSheet> createState() => _EditExerciseSheetState();
}

class _EditExerciseSheetState extends State<_EditExerciseSheet> {
  late int _sets;
  late int _reps;
  late int _rest;

  @override
  void initState() {
    super.initState();
    _sets = widget.planEx.sets;
    _reps = widget.planEx.reps;
    _rest = widget.planEx.restSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.planEx.exercise;
    final color = _colorForCategory(ex.category);
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAOpacity(0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  _iconForCategory(ex.category),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${ex.category} · ${ex.muscle}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Stepper(
            label: 'Sets',
            value: _sets,
            min: 1,
            max: 10,
            onChanged: (v) {
              setState(() => _sets = v);
              widget.planEx.sets = v;
            },
          ),
          const SizedBox(height: 14),
          _Stepper(
            label: 'Reps',
            value: _reps,
            min: 1,
            max: 50,
            onChanged: (v) {
              setState(() => _reps = v);
              widget.planEx.reps = v;
            },
          ),
          const SizedBox(height: 14),
          _Stepper(
            label: 'Rest (seconds)',
            value: _rest,
            min: 15,
            max: 300,
            step: 15,
            onChanged: (v) {
              setState(() => _rest = v);
              widget.planEx.restSeconds = v;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _StepBtn(
          icon: Icons.remove_rounded,
          onTap: value > min ? () => onChanged(value - step) : null,
        ),
        const SizedBox(width: 4),
        Container(
          width: 52,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 4),
        _StepBtn(
          icon: Icons.add_rounded,
          onTap: value < max ? () => onChanged(value + step) : null,
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppTheme.primary.withAOpacity(0.14)
              : Colors.white.withAOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: onTap != null ? AppTheme.primary : Colors.white24,
          size: 18,
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final String? value;
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;
  final int maxLines;
  const _InputField({
    required this.hint,
    required this.icon,
    this.value,
    this.controller,
    required this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAOpacity(0.07), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        // `initialValue` is only honored on first build, so it's only used
        // as a fallback when no controller is supplied.
        initialValue: controller == null ? value : null,
        onChanged: onChanged,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAOpacity(0.07), width: 1),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
