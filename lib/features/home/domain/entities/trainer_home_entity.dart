class TrainerProfileEntity {
  final String id;
  final String name;
  final String staffTitle;
  final String profileImageUrl;
  final String role;

  const TrainerProfileEntity({
    this.id = '',
    this.name = '',
    this.staffTitle = '',
    this.profileImageUrl = '',
    this.role = '',
  });

  @override
  String toString() {
    return 'TrainerProfileEntity('
      'id: $id, '
      'name: $name, '
      'staffTitle: $staffTitle, '
      'profileImageUrl: $profileImageUrl, '
      'role: $role, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is TrainerProfileEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class SummaryEntity {
  final num myMembers;
  final num checkedInToday;
  final num classesToday;
  final num pendingTasks;

  const SummaryEntity({
    this.myMembers = 0,
    this.checkedInToday = 0,
    this.classesToday = 0,
    this.pendingTasks = 0,
  });

  @override
  String toString() {
    return 'SummaryEntity('
      'myMembers: $myMembers, '
      'checkedInToday: $checkedInToday, '
      'classesToday: $classesToday, '
      'pendingTasks: $pendingTasks, '
    ')';
  }
}

class PendingTaskEntity {
  final String type;
  final String title;
  final String subtitle;
  final String refId;

  const PendingTaskEntity({
    this.type = '',
    this.title = '',
    this.subtitle = '',
    this.refId = '',
  });

  @override
  String toString() {
    return 'PendingTaskEntity('
      'type: $type, '
      'title: $title, '
      'subtitle: $subtitle, '
      'refId: $refId, '
    ')';
  }
}

class TodaysClasseEntity {
  final String id;
  final String name;
  final String time;
  final String room;
  final num enrolled;
  final num capacity;
  final bool upcoming;

  const TodaysClasseEntity({
    this.id = '',
    this.name = '',
    this.time = '',
    this.room = '',
    this.enrolled = 0,
    this.capacity = 0,
    this.upcoming = false,
  });

  @override
  String toString() {
    return 'TodaysClasseEntity('
      'id: $id, '
      'name: $name, '
      'time: $time, '
      'room: $room, '
      'enrolled: $enrolled, '
      'capacity: $capacity, '
      'upcoming: $upcoming, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is TodaysClasseEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class AssignedMemberEntity {
  final String id;
  final String name;
  final String plan;
  final bool checkedInToday;
  final num workoutStreak;
  final String nextSession;

  const AssignedMemberEntity({
    this.id = '',
    this.name = '',
    this.plan = '',
    this.checkedInToday = false,
    this.workoutStreak = 0,
    this.nextSession = '',
  });

  @override
  String toString() {
    return 'AssignedMemberEntity('
      'id: $id, '
      'name: $name, '
      'plan: $plan, '
      'checkedInToday: $checkedInToday, '
      'workoutStreak: $workoutStreak, '
      'nextSession: $nextSession, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is AssignedMemberEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class RecentCheckInEntity {
  final String memberId;
  final String name;
  final String time;

  const RecentCheckInEntity({
    this.memberId = '',
    this.name = '',
    this.time = '',
  });

  @override
  String toString() {
    return 'RecentCheckInEntity('
      'memberId: $memberId, '
      'name: $name, '
      'time: $time, '
    ')';
  }
}

class WeeklyAttendanceEntity {
  final List<String> labels;
  final List<num> counts;
  final num todayIndex;
  final num total;

  const WeeklyAttendanceEntity({
    this.labels = const [],
    this.counts = const [],
    this.todayIndex = 0,
    this.total = 0,
  });

  @override
  String toString() {
    return 'WeeklyAttendanceEntity('
      'labels: $labels, '
      'counts: $counts, '
      'todayIndex: $todayIndex, '
      'total: $total, '
    ')';
  }
}

class TrainerHomeEntity {
  final TrainerProfileEntity profile;
  final SummaryEntity summary;
  final List<PendingTaskEntity> pendingTasks;
  final List<TodaysClasseEntity> todaysClasses;
  final List<AssignedMemberEntity> assignedMembers;
  final List<RecentCheckInEntity> recentCheckIns;
  final WeeklyAttendanceEntity weeklyAttendance;

  const TrainerHomeEntity({
    this.profile = const TrainerProfileEntity(),
    this.summary = const SummaryEntity(),
    this.pendingTasks = const [],
    this.todaysClasses = const [],
    this.assignedMembers = const [],
    this.recentCheckIns = const [],
    this.weeklyAttendance = const WeeklyAttendanceEntity(),
  });

  @override
  String toString() {
    return 'TrainerHomeEntity('
      'profile: $profile, '
      'summary: $summary, '
      'pendingTasks: $pendingTasks, '
      'todaysClasses: $todaysClasses, '
      'assignedMembers: $assignedMembers, '
      'recentCheckIns: $recentCheckIns, '
      'weeklyAttendance: $weeklyAttendance, '
    ')';
  }
}

