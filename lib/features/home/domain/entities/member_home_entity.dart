class ProfileEntity {
  final String id;
  final String name;
  final String profileImageUrl;

  const ProfileEntity({
    this.id = '',
    this.name = '',
    this.profileImageUrl = '',
  });

  @override
  String toString() {
    return 'ProfileEntity('
      'id: $id, '
      'name: $name, '
      'profileImageUrl: $profileImageUrl, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is ProfileEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class PlanEntity {
  final String id;
  final String name;
  final num durationDays;
  final num price;

  const PlanEntity({
    this.id = '',
    this.name = '',
    this.durationDays = 0,
    this.price = 0,
  });

  @override
  String toString() {
    return 'PlanEntity('
      'id: $id, '
      'name: $name, '
      'durationDays: $durationDays, '
      'price: $price, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is PlanEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class TrainerEntity {
  final String id;
  final String name;

  const TrainerEntity({
    this.id = '',
    this.name = '',
  });

  @override
  String toString() {
    return 'TrainerEntity('
      'id: $id, '
      'name: $name, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is TrainerEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class MembershipEntity {
  final PlanEntity plan;
  final String status;
  final String start;
  final String end;
  final num daysRemaining;
  final TrainerEntity trainer;

  const MembershipEntity({
    this.plan = const PlanEntity(),
    this.status = '',
    this.start = '',
    this.end = '',
    this.daysRemaining = 0,
    this.trainer = const TrainerEntity(),
  });

  @override
  String toString() {
    return 'MembershipEntity('
      'plan: $plan, '
      'status: $status, '
      'start: $start, '
      'end: $end, '
      'daysRemaining: $daysRemaining, '
      'trainer: $trainer, '
    ')';
  }
}

class ExerciseEntity {
  final String id;
  final String name;
  final num sets;
  final num reps;
  final num restSeconds;
  final bool completed;

  const ExerciseEntity({
    this.id = '',
    this.name = '',
    this.sets = 0,
    this.reps = 0,
    this.restSeconds = 0,
    this.completed = false,
  });

  @override
  String toString() {
    return 'ExerciseEntity('
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
    return identical(this, other) || (other is ExerciseEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class TodaysWorkoutEntity {
  final String planName;
  final List<ExerciseEntity> exercises;
  final num doneCount;
  final num totalCount;

  const TodaysWorkoutEntity({
    this.planName = '',
    this.exercises = const [],
    this.doneCount = 0,
    this.totalCount = 0,
  });

  @override
  String toString() {
    return 'TodaysWorkoutEntity('
      'planName: $planName, '
      'exercises: $exercises, '
      'doneCount: $doneCount, '
      'totalCount: $totalCount, '
    ')';
  }
}

class QuickStatsEntity {
  final num dayStreak;
  final num workoutsCompleted;
  final num activeOrders;

  const QuickStatsEntity({
    this.dayStreak = 0,
    this.workoutsCompleted = 0,
    this.activeOrders = 0,
  });

  @override
  String toString() {
    return 'QuickStatsEntity('
      'dayStreak: $dayStreak, '
      'workoutsCompleted: $workoutsCompleted, '
      'activeOrders: $activeOrders, '
    ')';
  }
}

class AnnouncementEntity {
  final String id;
  final String title;
  final String body;
  final String audienceType;
  final List<String> audienceUserIds;
  final bool isDraft;
  final String createdAt;

  const AnnouncementEntity({
    this.id = '',
    this.title = '',
    this.body = '',
    this.audienceType = '',
    this.audienceUserIds = const [],
    this.isDraft = false,
    this.createdAt = '',
  });

  @override
  String toString() {
    return 'AnnouncementEntity('
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
    return identical(this, other) || (other is AnnouncementEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class ShopPrevieEntity {
  final String id;
  final String name;
  final num price;
  final num stockCount;
  final String imageUrl;
  final bool isFeatured;
  final bool isActive;
  final String createdAt;

  const ShopPrevieEntity({
    this.id = '',
    this.name = '',
    this.price = 0,
    this.stockCount = 0,
    this.imageUrl = '',
    this.isFeatured = false,
    this.isActive = false,
    this.createdAt = '',
  });

  @override
  String toString() {
    return 'ShopPrevieEntity('
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
    return identical(this, other) || (other is ShopPrevieEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class GymClassEntity {
  final String id;
  final String name;
  final String dayOfWeek;
  final String startTime;
  final String room;
  final num capacity;
  final String trainerName;

  const GymClassEntity({
    this.id = '',
    this.name = '',
    this.dayOfWeek = '',
    this.startTime = '',
    this.room = '',
    this.capacity = 0,
    this.trainerName = '',
  });

  @override
  String toString() {
    return 'GymClassEntity('
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
    return identical(this, other) || (other is GymClassEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class UpcomingClasseEntity {
  final String bookingId;
  final String status;
  final GymClassEntity gymClass;

  const UpcomingClasseEntity({
    this.bookingId = '',
    this.status = '',
    this.gymClass = const GymClassEntity(),
  });

  @override
  String toString() {
    return 'UpcomingClasseEntity('
      'bookingId: $bookingId, '
      'status: $status, '
      'gymClass: $gymClass, '
    ')';
  }
}

class FeeStatusEntity {
  final String status;
  final num amount;
  final String dueDate;
  final String paidDate;
  final String planName;

  const FeeStatusEntity({
    this.status = '',
    this.amount = 0,
    this.dueDate = '',
    this.paidDate = '',
    this.planName = '',
  });

  @override
  String toString() {
    return 'FeeStatusEntity('
      'status: $status, '
      'amount: $amount, '
      'dueDate: $dueDate, '
      'paidDate: $paidDate, '
      'planName: $planName, '
    ')';
  }
}

class MemberHomeEntity {
  final ProfileEntity profile;
  final MembershipEntity membership;
  final TodaysWorkoutEntity todaysWorkout;
  final QuickStatsEntity quickStats;
  final List<AnnouncementEntity> announcements;
  final List<ShopPrevieEntity> shopPreview;
  final List<UpcomingClasseEntity> upcomingClasses;
  final FeeStatusEntity feeStatus;

  const MemberHomeEntity({
    this.profile = const ProfileEntity(),
    this.membership = const MembershipEntity(),
    this.todaysWorkout = const TodaysWorkoutEntity(),
    this.quickStats = const QuickStatsEntity(),
    this.announcements = const [],
    this.shopPreview = const [],
    this.upcomingClasses = const [],
    this.feeStatus = const FeeStatusEntity(),
  });

  @override
  String toString() {
    return 'MemberHomeEntity('
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
}

