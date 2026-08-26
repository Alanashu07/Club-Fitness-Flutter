import 'package:club_fitness/core/utils/utils.dart';

import '../../domain/entities/member_home_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({super.id, super.name, super.profileImageUrl});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
    );
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      name: entity.name,
      profileImageUrl: entity.profileImageUrl,
    );
  }

  ProfileModel copyWith({String? id, String? name, String? profileImageUrl}) =>
      ProfileModel(
        id: id ?? this.id,
        name: name ?? this.name,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'profileImageUrl': profileImageUrl}
        ..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'ProfileModel('
        'id: $id, '
        'name: $name, '
        'profileImageUrl: $profileImageUrl, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is ProfileModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class PlanModel extends PlanEntity {
  const PlanModel({super.id, super.name, super.durationDays, super.price});

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      durationDays: json['durationDays'] as num? ?? 0,
      price: json['price'] as num? ?? 0,
    );
  }

  factory PlanModel.fromEntity(PlanEntity entity) {
    return PlanModel(
      id: entity.id,
      name: entity.name,
      durationDays: entity.durationDays,
      price: entity.price,
    );
  }

  PlanModel copyWith({
    String? id,
    String? name,
    num? durationDays,
    num? price,
  }) => PlanModel(
    id: id ?? this.id,
    name: name ?? this.name,
    durationDays: durationDays ?? this.durationDays,
    price: price ?? this.price,
  );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'durationDays': durationDays, 'price': price}
        ..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'PlanModel('
        'id: $id, '
        'name: $name, '
        'durationDays: $durationDays, '
        'price: $price, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is PlanModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class TrainerModel extends TrainerEntity {
  const TrainerModel({super.id, super.name});

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    return TrainerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  factory TrainerModel.fromEntity(TrainerEntity entity) {
    return TrainerModel(id: entity.id, name: entity.name);
  }

  TrainerModel copyWith({String? id, String? name}) =>
      TrainerModel(id: id ?? this.id, name: name ?? this.name);

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name}
        ..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'TrainerModel('
        'id: $id, '
        'name: $name, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is TrainerModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class MembershipModel extends MembershipEntity {
  const MembershipModel({
    super.plan,
    super.status,
    super.start,
    super.end,
    super.daysRemaining,
    super.trainer,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      plan: json['plan'] != null
          ? PlanModel.fromJson(json['plan'])
          : const PlanModel(),
      status: json['status'] as String? ?? '',
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
      daysRemaining: json['daysRemaining'] as num? ?? 0,
      trainer: json['trainer'] != null
          ? TrainerModel.fromJson(json['trainer'])
          : const TrainerModel(),
    );
  }

  factory MembershipModel.fromEntity(MembershipEntity entity) {
    return MembershipModel(
      plan: entity.plan,
      status: entity.status,
      start: entity.start,
      end: entity.end,
      daysRemaining: entity.daysRemaining,
      trainer: entity.trainer,
    );
  }

  MembershipModel copyWith({
    PlanModel? plan,
    String? status,
    String? start,
    String? end,
    num? daysRemaining,
    TrainerModel? trainer,
  }) => MembershipModel(
    plan: plan ?? this.plan,
    status: status ?? this.status,
    start: start ?? this.start,
    end: end ?? this.end,
    daysRemaining: daysRemaining ?? this.daysRemaining,
    trainer: trainer ?? this.trainer,
  );

  Map<String, dynamic> toJson() => {
    'plan': PlanModel.fromEntity(plan).toJson(),
    'status': status,
    'start': start,
    'end': end,
    'daysRemaining': daysRemaining,
    'trainer': TrainerModel.fromEntity(trainer).toJson(),
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MembershipModel('
        'plan: $plan, '
        'status: $status, '
        'start: $start, '
        'end: $end, '
        'daysRemaining: $daysRemaining, '
        'trainer: $trainer, '
        ')';
  }

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class ExerciseModel extends ExerciseEntity {
  const ExerciseModel({
    super.id,
    super.name,
    super.sets,
    super.reps,
    super.restSeconds,
    super.completed,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sets: json['sets'] as num? ?? 0,
      reps: json['reps'] as num? ?? 0,
      restSeconds: json['restSeconds'] as num? ?? 0,
      completed: json['completed'] as bool? ?? false,
    );
  }

  factory ExerciseModel.fromEntity(ExerciseEntity entity) {
    return ExerciseModel(
      id: entity.id,
      name: entity.name,
      sets: entity.sets,
      reps: entity.reps,
      restSeconds: entity.restSeconds,
      completed: entity.completed,
    );
  }

  ExerciseModel copyWith({
    String? id,
    String? name,
    num? sets,
    num? reps,
    num? restSeconds,
    bool? completed,
  }) => ExerciseModel(
    id: id ?? this.id,
    name: name ?? this.name,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    restSeconds: restSeconds ?? this.restSeconds,
    completed: completed ?? this.completed,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sets': sets,
    'reps': reps,
    'restSeconds': restSeconds,
    'completed': completed,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'ExerciseModel('
        'id: $id, '
        'name: $name, '
        'sets: $sets, '
        'reps: $reps, '
        'restSeconds: $restSeconds, '
        'completed: $completed, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is ExerciseModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class TodaysWorkoutModel extends TodaysWorkoutEntity {
  const TodaysWorkoutModel({
    super.planName,
    super.exercises,
    super.doneCount,
    super.totalCount,
  });

  factory TodaysWorkoutModel.fromJson(Map<String, dynamic> json) {
    return TodaysWorkoutModel(
      planName: json['planName'] as String? ?? '',
      exercises:
          (json['exercises'] as List?)
              ?.map((e) => ExerciseModel.fromJson(e))
              .toList() ??
          const [],
      doneCount: json['doneCount'] as num? ?? 0,
      totalCount: json['totalCount'] as num? ?? 0,
    );
  }

  factory TodaysWorkoutModel.fromEntity(TodaysWorkoutEntity entity) {
    return TodaysWorkoutModel(
      planName: entity.planName,
      exercises: entity.exercises,
      doneCount: entity.doneCount,
      totalCount: entity.totalCount,
    );
  }

  TodaysWorkoutModel copyWith({
    String? planName,
    List<ExerciseModel>? exercises,
    num? doneCount,
    num? totalCount,
  }) => TodaysWorkoutModel(
    planName: planName ?? this.planName,
    exercises: exercises ?? this.exercises,
    doneCount: doneCount ?? this.doneCount,
    totalCount: totalCount ?? this.totalCount,
  );

  Map<String, dynamic> toJson() => {
    'planName': planName,
    'exercises': exercises
        .map((e) => ExerciseModel.fromEntity(e).toJson())
        .toList(),
    'doneCount': doneCount,
    'totalCount': totalCount,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'TodaysWorkoutModel('
        'planName: $planName, '
        'exercises: $exercises, '
        'doneCount: $doneCount, '
        'totalCount: $totalCount, '
        ')';
  }

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class QuickStatsModel extends QuickStatsEntity {
  const QuickStatsModel({
    super.dayStreak,
    super.workoutsCompleted,
    super.activeOrders,
  });

  factory QuickStatsModel.fromJson(Map<String, dynamic> json) {
    return QuickStatsModel(
      dayStreak: json['dayStreak'] as num? ?? 0,
      workoutsCompleted: json['workoutsCompleted'] as num? ?? 0,
      activeOrders: json['activeOrders'] as num? ?? 0,
    );
  }

  factory QuickStatsModel.fromEntity(QuickStatsEntity entity) {
    return QuickStatsModel(
      dayStreak: entity.dayStreak,
      workoutsCompleted: entity.workoutsCompleted,
      activeOrders: entity.activeOrders,
    );
  }

  QuickStatsModel copyWith({
    num? dayStreak,
    num? workoutsCompleted,
    num? activeOrders,
  }) => QuickStatsModel(
    dayStreak: dayStreak ?? this.dayStreak,
    workoutsCompleted: workoutsCompleted ?? this.workoutsCompleted,
    activeOrders: activeOrders ?? this.activeOrders,
  );

  Map<String, dynamic> toJson() => {
    'dayStreak': dayStreak,
    'workoutsCompleted': workoutsCompleted,
    'activeOrders': activeOrders,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'QuickStatsModel('
        'dayStreak: $dayStreak, '
        'workoutsCompleted: $workoutsCompleted, '
        'activeOrders: $activeOrders, '
        ')';
  }

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    super.id,
    super.title,
    super.body,
    super.audienceType,
    super.audienceUserIds,
    super.isDraft,
    super.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      audienceType: json['audienceType'] as String? ?? '',
      audienceUserIds:
          (json['audienceUserIds'] as List?)?.cast<String>() ?? const [],
      isDraft: json['isDraft'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  factory AnnouncementModel.fromEntity(AnnouncementEntity entity) {
    return AnnouncementModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      audienceType: entity.audienceType,
      audienceUserIds: entity.audienceUserIds,
      isDraft: entity.isDraft,
      createdAt: entity.createdAt,
    );
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? body,
    String? audienceType,
    List<String>? audienceUserIds,
    bool? isDraft,
    String? createdAt,
  }) => AnnouncementModel(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    audienceType: audienceType ?? this.audienceType,
    audienceUserIds: audienceUserIds ?? this.audienceUserIds,
    isDraft: isDraft ?? this.isDraft,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'audienceType': audienceType,
    'audienceUserIds': audienceUserIds,
    'isDraft': isDraft,
    'createdAt': createdAt,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'AnnouncementModel('
        'id: $id, '
        'title: $title, '
        'body: $body, '
        'audienceType: $audienceType, '
        'audienceUserIds: $audienceUserIds, '
        'isDraft: $isDraft, '
        'createdAt: $createdAt, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AnnouncementModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class ShopPrevieModel extends ShopPrevieEntity {
  const ShopPrevieModel({
    super.id,
    super.name,
    super.price,
    super.stockCount,
    super.imageUrl,
    super.isFeatured,
    super.isActive,
    super.createdAt,
  });

  factory ShopPrevieModel.fromJson(Map<String, dynamic> json) {
    return ShopPrevieModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: json['price']?.toString().toNum ?? 0,
      stockCount: json['stockCount'] as num? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      isFeatured: json['isFeatured'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  factory ShopPrevieModel.fromEntity(ShopPrevieEntity entity) {
    return ShopPrevieModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      stockCount: entity.stockCount,
      imageUrl: entity.imageUrl,
      isFeatured: entity.isFeatured,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  ShopPrevieModel copyWith({
    String? id,
    String? name,
    num? price,
    num? stockCount,
    String? imageUrl,
    bool? isFeatured,
    bool? isActive,
    String? createdAt,
  }) => ShopPrevieModel(
    id: id ?? this.id,
    name: name ?? this.name,
    price: price ?? this.price,
    stockCount: stockCount ?? this.stockCount,
    imageUrl: imageUrl ?? this.imageUrl,
    isFeatured: isFeatured ?? this.isFeatured,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'stockCount': stockCount,
    'imageUrl': imageUrl,
    'isFeatured': isFeatured,
    'isActive': isActive,
    'createdAt': createdAt,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'ShopPrevieModel('
        'id: $id, '
        'name: $name, '
        'price: $price, '
        'stockCount: $stockCount, '
        'imageUrl: $imageUrl, '
        'isFeatured: $isFeatured, '
        'isActive: $isActive, '
        'createdAt: $createdAt, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShopPrevieModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class GymClassModel extends GymClassEntity {
  const GymClassModel({
    super.id,
    super.name,
    super.dayOfWeek,
    super.startTime,
    super.room,
    super.capacity,
    super.trainerName,
  });

  factory GymClassModel.fromJson(Map<String, dynamic> json) {
    return GymClassModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dayOfWeek: json['dayOfWeek'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      room: json['room'] as String? ?? '',
      capacity: json['capacity'] as num? ?? 0,
      trainerName: json['trainerName'] as String? ?? '',
    );
  }

  factory GymClassModel.fromEntity(GymClassEntity entity) {
    return GymClassModel(
      id: entity.id,
      name: entity.name,
      dayOfWeek: entity.dayOfWeek,
      startTime: entity.startTime,
      room: entity.room,
      capacity: entity.capacity,
      trainerName: entity.trainerName,
    );
  }

  GymClassModel copyWith({
    String? id,
    String? name,
    String? dayOfWeek,
    String? startTime,
    String? room,
    num? capacity,
    String? trainerName,
  }) => GymClassModel(
    id: id ?? this.id,
    name: name ?? this.name,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    startTime: startTime ?? this.startTime,
    room: room ?? this.room,
    capacity: capacity ?? this.capacity,
    trainerName: trainerName ?? this.trainerName,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'room': room,
    'capacity': capacity,
    'trainerName': trainerName,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'GymClassModel('
        'id: $id, '
        'name: $name, '
        'dayOfWeek: $dayOfWeek, '
        'startTime: $startTime, '
        'room: $room, '
        'capacity: $capacity, '
        'trainerName: $trainerName, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is GymClassModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class UpcomingClasseModel extends UpcomingClasseEntity {
  const UpcomingClasseModel({super.bookingId, super.status, super.gymClass});

  factory UpcomingClasseModel.fromJson(Map<String, dynamic> json) {
    return UpcomingClasseModel(
      bookingId: json['bookingId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      gymClass: json['gymClass'] != null
          ? GymClassModel.fromJson(json['gymClass'])
          : const GymClassModel(),
    );
  }

  factory UpcomingClasseModel.fromEntity(UpcomingClasseEntity entity) {
    return UpcomingClasseModel(
      bookingId: entity.bookingId,
      status: entity.status,
      gymClass: entity.gymClass,
    );
  }

  UpcomingClasseModel copyWith({
    String? bookingId,
    String? status,
    GymClassModel? gymClass,
  }) => UpcomingClasseModel(
    bookingId: bookingId ?? this.bookingId,
    status: status ?? this.status,
    gymClass: gymClass ?? this.gymClass,
  );

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'status': status,
    'gymClass': GymClassModel.fromEntity(gymClass).toJson(),
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'UpcomingClasseModel('
        'bookingId: $bookingId, '
        'status: $status, '
        'gymClass: $gymClass, '
        ')';
  }

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class FeeStatusModel extends FeeStatusEntity {
  const FeeStatusModel({
    super.status,
    super.amount,
    super.dueDate,
    super.paidDate,
    super.planName,
  });

  factory FeeStatusModel.fromJson(Map<String, dynamic> json) {
    return FeeStatusModel(
      status: json['status'] as String? ?? '',
      amount: json['amount'] as num? ?? 0,
      dueDate: json['dueDate'] as String? ?? '',
      paidDate: json['paidDate'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
    );
  }

  factory FeeStatusModel.fromEntity(FeeStatusEntity entity) {
    return FeeStatusModel(
      status: entity.status,
      amount: entity.amount,
      dueDate: entity.dueDate,
      paidDate: entity.paidDate,
      planName: entity.planName,
    );
  }

  FeeStatusModel copyWith({
    String? status,
    num? amount,
    String? dueDate,
    String? paidDate,
    String? planName,
  }) => FeeStatusModel(
    status: status ?? this.status,
    amount: amount ?? this.amount,
    dueDate: dueDate ?? this.dueDate,
    paidDate: paidDate ?? this.paidDate,
    planName: planName ?? this.planName,
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'amount': amount,
    'dueDate': dueDate,
    'paidDate': paidDate,
    'planName': planName,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'FeeStatusModel('
        'status: $status, '
        'amount: $amount, '
        'dueDate: $dueDate, '
        'paidDate: $paidDate, '
        'planName: $planName, '
        ')';
  }

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class MemberHomeModel extends MemberHomeEntity {
  const MemberHomeModel({
    super.profile,
    super.membership,
    super.todaysWorkout,
    super.quickStats,
    super.announcements,
    super.shopPreview,
    super.upcomingClasses,
    super.feeStatus,
  });

  factory MemberHomeModel.fromJson(Map<String, dynamic> json) {
    return MemberHomeModel(
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'])
          : const ProfileModel(),
      membership: json['membership'] != null
          ? MembershipModel.fromJson(json['membership'])
          : const MembershipModel(),
      todaysWorkout: json['todaysWorkout'] != null
          ? TodaysWorkoutModel.fromJson(json['todaysWorkout'])
          : const TodaysWorkoutModel(),
      quickStats: json['quickStats'] != null
          ? QuickStatsModel.fromJson(json['quickStats'])
          : const QuickStatsModel(),
      announcements:
          (json['announcements'] as List?)
              ?.map((e) => AnnouncementModel.fromJson(e))
              .toList() ??
          const [],
      shopPreview:
          (json['shopPreview'] as List?)
              ?.map((e) => ShopPrevieModel.fromJson(e))
              .toList() ??
          const [],
      upcomingClasses:
          (json['upcomingClasses'] as List?)
              ?.map((e) => UpcomingClasseModel.fromJson(e))
              .toList() ??
          const [],
      feeStatus: json['feeStatus'] != null
          ? FeeStatusModel.fromJson(json['feeStatus'])
          : const FeeStatusModel(),
    );
  }

  factory MemberHomeModel.fromEntity(MemberHomeEntity entity) {
    return MemberHomeModel(
      profile: entity.profile,
      membership: entity.membership,
      todaysWorkout: entity.todaysWorkout,
      quickStats: entity.quickStats,
      announcements: entity.announcements,
      shopPreview: entity.shopPreview,
      upcomingClasses: entity.upcomingClasses,
      feeStatus: entity.feeStatus,
    );
  }

  MemberHomeModel copyWith({
    ProfileModel? profile,
    MembershipModel? membership,
    TodaysWorkoutModel? todaysWorkout,
    QuickStatsModel? quickStats,
    List<AnnouncementModel>? announcements,
    List<ShopPrevieModel>? shopPreview,
    List<UpcomingClasseModel>? upcomingClasses,
    FeeStatusModel? feeStatus,
  }) => MemberHomeModel(
    profile: profile ?? this.profile,
    membership: membership ?? this.membership,
    todaysWorkout: todaysWorkout ?? this.todaysWorkout,
    quickStats: quickStats ?? this.quickStats,
    announcements: announcements ?? this.announcements,
    shopPreview: shopPreview ?? this.shopPreview,
    upcomingClasses: upcomingClasses ?? this.upcomingClasses,
    feeStatus: feeStatus ?? this.feeStatus,
  );

  Map<String, dynamic> toJson() => {
    'profile': ProfileModel.fromEntity(profile).toJson(),
    'membership': MembershipModel.fromEntity(membership).toJson(),
    'todaysWorkout': TodaysWorkoutModel.fromEntity(todaysWorkout).toJson(),
    'quickStats': QuickStatsModel.fromEntity(quickStats).toJson(),
    'announcements': announcements
        .map((e) => AnnouncementModel.fromEntity(e).toJson())
        .toList(),
    'shopPreview': shopPreview
        .map((e) => ShopPrevieModel.fromEntity(e).toJson())
        .toList(),
    'upcomingClasses': upcomingClasses
        .map((e) => UpcomingClasseModel.fromEntity(e).toJson())
        .toList(),
    'feeStatus': FeeStatusModel.fromEntity(feeStatus).toJson(),
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MemberHomeModel('
        'profile: $profile, '
        'membership: $membership, '
        'todaysWorkout: $todaysWorkout, '
        'quickStats: $quickStats, '
        'announcements: $announcements, '
        'shopPreview: $shopPreview, '
        'upcomingClasses: $upcomingClasses, '
        'feeStatus: $feeStatus, '
        ')';
  }

  // Helper function to remove empty values
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is bool) return !value;
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}
