import '../../domain/entities/trainer_home_entity.dart';

class TrainerProfileModel extends TrainerProfileEntity {
  const TrainerProfileModel({
    super.id,
    super.name,
    super.staffTitle,
    super.profileImageUrl,
    super.role,
  });

  factory TrainerProfileModel.fromJson(Map<String, dynamic> json) {
    return TrainerProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      staffTitle: json['staffTitle'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  factory TrainerProfileModel.fromEntity(TrainerProfileEntity entity) {
    return TrainerProfileModel(
      id: entity.id,
      name: entity.name,
      staffTitle: entity.staffTitle,
      profileImageUrl: entity.profileImageUrl,
      role: entity.role,
    );
  }

  TrainerProfileModel copyWith({
    String? id,
    String? name,
    String? staffTitle,
    String? profileImageUrl,
    String? role,
  }) => TrainerProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      staffTitle: staffTitle ?? this.staffTitle,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'staffTitle': staffTitle,
        'profileImageUrl': profileImageUrl,
        'role': role,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'TrainerProfileModel('
      'id: $id, '
      'name: $name, '
      'staffTitle: $staffTitle, '
      'profileImageUrl: $profileImageUrl, '
      'role: $role, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is TrainerProfileModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
    return false;
  }
}

class SummaryModel extends SummaryEntity {
  const SummaryModel({
    super.myMembers,
    super.checkedInToday,
    super.classesToday,
    super.pendingTasks,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      myMembers: json['myMembers'] as num? ?? 0,
      checkedInToday: json['checkedInToday'] as num? ?? 0,
      classesToday: json['classesToday'] as num? ?? 0,
      pendingTasks: json['pendingTasks'] as num? ?? 0,
    );
  }

  factory SummaryModel.fromEntity(SummaryEntity entity) {
    return SummaryModel(
      myMembers: entity.myMembers,
      checkedInToday: entity.checkedInToday,
      classesToday: entity.classesToday,
      pendingTasks: entity.pendingTasks,
    );
  }

  SummaryModel copyWith({
    num? myMembers,
    num? checkedInToday,
    num? classesToday,
    num? pendingTasks,
  }) => SummaryModel(
      myMembers: myMembers ?? this.myMembers,
      checkedInToday: checkedInToday ?? this.checkedInToday,
      classesToday: classesToday ?? this.classesToday,
      pendingTasks: pendingTasks ?? this.pendingTasks,
  );

  Map<String, dynamic> toJson() => {
        'myMembers': myMembers,
        'checkedInToday': checkedInToday,
        'classesToday': classesToday,
        'pendingTasks': pendingTasks,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'SummaryModel('
      'myMembers: $myMembers, '
      'checkedInToday: $checkedInToday, '
      'classesToday: $classesToday, '
      'pendingTasks: $pendingTasks, '
    ')';
  }

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
    return false;
  }
}

class PendingTaskModel extends PendingTaskEntity {
  const PendingTaskModel({
    super.type,
    super.title,
    super.subtitle,
    super.refId,
  });

  factory PendingTaskModel.fromJson(Map<String, dynamic> json) {
    return PendingTaskModel(
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      refId: json['refId'] as String? ?? '',
    );
  }

  factory PendingTaskModel.fromEntity(PendingTaskEntity entity) {
    return PendingTaskModel(
      type: entity.type,
      title: entity.title,
      subtitle: entity.subtitle,
      refId: entity.refId,
    );
  }

  PendingTaskModel copyWith({
    String? type,
    String? title,
    String? subtitle,
    String? refId,
  }) => PendingTaskModel(
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      refId: refId ?? this.refId,
  );

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'subtitle': subtitle,
        'refId': refId,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'PendingTaskModel('
      'type: $type, '
      'title: $title, '
      'subtitle: $subtitle, '
      'refId: $refId, '
    ')';
  }

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
    return false;
  }
}

class TodaysClasseModel extends TodaysClasseEntity {
  const TodaysClasseModel({
    super.id,
    super.name,
    super.time,
    super.room,
    super.enrolled,
    super.capacity,
    super.upcoming,
  });

  factory TodaysClasseModel.fromJson(Map<String, dynamic> json) {
    return TodaysClasseModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      time: json['time'] as String? ?? '',
      room: json['room'] as String? ?? '',
      enrolled: json['enrolled'] as num? ?? 0,
      capacity: json['capacity'] as num? ?? 0,
      upcoming: json['upcoming'] as bool? ?? false,
    );
  }

  factory TodaysClasseModel.fromEntity(TodaysClasseEntity entity) {
    return TodaysClasseModel(
      id: entity.id,
      name: entity.name,
      time: entity.time,
      room: entity.room,
      enrolled: entity.enrolled,
      capacity: entity.capacity,
      upcoming: entity.upcoming,
    );
  }

  TodaysClasseModel copyWith({
    String? id,
    String? name,
    String? time,
    String? room,
    num? enrolled,
    num? capacity,
    bool? upcoming,
  }) => TodaysClasseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      room: room ?? this.room,
      enrolled: enrolled ?? this.enrolled,
      capacity: capacity ?? this.capacity,
      upcoming: upcoming ?? this.upcoming,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'time': time,
        'room': room,
        'enrolled': enrolled,
        'capacity': capacity,
        'upcoming': upcoming,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'TodaysClasseModel('
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
    return identical(this, other) || (other is TodaysClasseModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
    return false;
  }
}

class AssignedMemberModel extends AssignedMemberEntity {
  const AssignedMemberModel({
    super.id,
    super.name,
    super.plan,
    super.checkedInToday,
    super.workoutStreak,
    super.nextSession,
  });

  factory AssignedMemberModel.fromJson(Map<String, dynamic> json) {
    return AssignedMemberModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      checkedInToday: json['checkedInToday'] as bool? ?? false,
      workoutStreak: json['workoutStreak'] as num? ?? 0,
      nextSession: json['nextSession'] as String? ?? '',
    );
  }

  factory AssignedMemberModel.fromEntity(AssignedMemberEntity entity) {
    return AssignedMemberModel(
      id: entity.id,
      name: entity.name,
      plan: entity.plan,
      checkedInToday: entity.checkedInToday,
      workoutStreak: entity.workoutStreak,
      nextSession: entity.nextSession,
    );
  }

  AssignedMemberModel copyWith({
    String? id,
    String? name,
    String? plan,
    bool? checkedInToday,
    num? workoutStreak,
    String? nextSession,
  }) => AssignedMemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      plan: plan ?? this.plan,
      checkedInToday: checkedInToday ?? this.checkedInToday,
      workoutStreak: workoutStreak ?? this.workoutStreak,
      nextSession: nextSession ?? this.nextSession,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'plan': plan,
        'checkedInToday': checkedInToday,
        'workoutStreak': workoutStreak,
        'nextSession': nextSession,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'AssignedMemberModel('
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
    return identical(this, other) || (other is AssignedMemberModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
    return false;
  }
}

class RecentCheckInModel extends RecentCheckInEntity {
  const RecentCheckInModel({
    super.memberId,
    super.name,
    super.time,
  });

  factory RecentCheckInModel.fromJson(Map<String, dynamic> json) {
    return RecentCheckInModel(
      memberId: json['memberId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      time: json['time'] as String? ?? '',
    );
  }

  factory RecentCheckInModel.fromEntity(RecentCheckInEntity entity) {
    return RecentCheckInModel(
      memberId: entity.memberId,
      name: entity.name,
      time: entity.time,
    );
  }

  RecentCheckInModel copyWith({
    String? memberId,
    String? name,
    String? time,
  }) => RecentCheckInModel(
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      time: time ?? this.time,
  );

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'name': name,
        'time': time,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'RecentCheckInModel('
      'memberId: $memberId, '
      'name: $name, '
      'time: $time, '
    ')';
  }

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
    return false;
  }
}

class WeeklyAttendanceModel extends WeeklyAttendanceEntity {
  const WeeklyAttendanceModel({
    super.labels,
    super.counts,
    super.todayIndex,
    super.total,
  });

  factory WeeklyAttendanceModel.fromJson(Map<String, dynamic> json) {
    return WeeklyAttendanceModel(
      labels: (json['labels'] as List?)?.cast<String>() ?? const [],
      counts: (json['counts'] as List?)?.cast<num>() ?? const [],
      todayIndex: json['todayIndex'] as num? ?? 0,
      total: json['total'] as num? ?? 0,
    );
  }

  factory WeeklyAttendanceModel.fromEntity(WeeklyAttendanceEntity entity) {
    return WeeklyAttendanceModel(
      labels: entity.labels,
      counts: entity.counts,
      todayIndex: entity.todayIndex,
      total: entity.total,
    );
  }

  WeeklyAttendanceModel copyWith({
    List<String>? labels,
    List<num>? counts,
    num? todayIndex,
    num? total,
  }) => WeeklyAttendanceModel(
      labels: labels ?? this.labels,
      counts: counts ?? this.counts,
      todayIndex: todayIndex ?? this.todayIndex,
      total: total ?? this.total,
  );

  Map<String, dynamic> toJson() => {
        'labels': labels,
        'counts': counts,
        'todayIndex': todayIndex,
        'total': total,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'WeeklyAttendanceModel('
      'labels: $labels, '
      'counts: $counts, '
      'todayIndex: $todayIndex, '
      'total: $total, '
    ')';
  }

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
    return false;
  }
}

class TrainerHomeModel extends TrainerHomeEntity {
  const TrainerHomeModel({
    super.profile,
    super.summary,
    super.pendingTasks,
    super.todaysClasses,
    super.assignedMembers,
    super.recentCheckIns,
    super.weeklyAttendance,
  });

  factory TrainerHomeModel.fromJson(Map<String, dynamic> json) {
    return TrainerHomeModel(
      profile: json['profile'] != null ? TrainerProfileModel.fromJson(json['profile']) : const TrainerProfileModel(),
      summary: json['summary'] != null ? SummaryModel.fromJson(json['summary']) : const SummaryModel(),
      pendingTasks: (json['pendingTasks'] as List?)?.map((e) => PendingTaskModel.fromJson(e)).toList() ?? const [],
      todaysClasses: (json['todaysClasses'] as List?)?.map((e) => TodaysClasseModel.fromJson(e)).toList() ?? const [],
      assignedMembers: (json['assignedMembers'] as List?)?.map((e) => AssignedMemberModel.fromJson(e)).toList() ?? const [],
      recentCheckIns: (json['recentCheckIns'] as List?)?.map((e) => RecentCheckInModel.fromJson(e)).toList() ?? const [],
      weeklyAttendance: json['weeklyAttendance'] != null ? WeeklyAttendanceModel.fromJson(json['weeklyAttendance']) : const WeeklyAttendanceModel(),
    );
  }

  factory TrainerHomeModel.fromEntity(TrainerHomeEntity entity) {
    return TrainerHomeModel(
      profile: entity.profile,
      summary: entity.summary,
      pendingTasks: entity.pendingTasks,
      todaysClasses: entity.todaysClasses,
      assignedMembers: entity.assignedMembers,
      recentCheckIns: entity.recentCheckIns,
      weeklyAttendance: entity.weeklyAttendance,
    );
  }

  TrainerHomeModel copyWith({
    TrainerProfileModel? profile,
    SummaryModel? summary,
    List<PendingTaskModel>? pendingTasks,
    List<TodaysClasseModel>? todaysClasses,
    List<AssignedMemberModel>? assignedMembers,
    List<RecentCheckInModel>? recentCheckIns,
    WeeklyAttendanceModel? weeklyAttendance,
  }) => TrainerHomeModel(
      profile: profile ?? this.profile,
      summary: summary ?? this.summary,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      todaysClasses: todaysClasses ?? this.todaysClasses,
      assignedMembers: assignedMembers ?? this.assignedMembers,
      recentCheckIns: recentCheckIns ?? this.recentCheckIns,
      weeklyAttendance: weeklyAttendance ?? this.weeklyAttendance,
  );

  Map<String, dynamic> toJson() => {
        'profile': TrainerProfileModel.fromEntity(profile).toJson(),
        'summary': SummaryModel.fromEntity(summary).toJson(),
        'pendingTasks': pendingTasks.map((e) => PendingTaskModel.fromEntity(e).toJson()).toList(),
        'todaysClasses': todaysClasses.map((e) => TodaysClasseModel.fromEntity(e).toJson()).toList(),
        'assignedMembers': assignedMembers.map((e) => AssignedMemberModel.fromEntity(e).toJson()).toList(),
        'recentCheckIns': recentCheckIns.map((e) => RecentCheckInModel.fromEntity(e).toJson()).toList(),
        'weeklyAttendance': WeeklyAttendanceModel.fromEntity(weeklyAttendance).toJson(),
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'TrainerHomeModel('
      'profile: $profile, '
      'summary: $summary, '
      'pendingTasks: $pendingTasks, '
      'todaysClasses: $todaysClasses, '
      'assignedMembers: $assignedMembers, '
      'recentCheckIns: $recentCheckIns, '
      'weeklyAttendance: $weeklyAttendance, '
    ')';
  }

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
    return false;
  }
}

