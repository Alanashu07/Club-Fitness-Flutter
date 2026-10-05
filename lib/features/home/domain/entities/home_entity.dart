import 'home_entities.dart';

class HomeEntity {
  final AdminHomeEntity? adminHome;
  final MemberHomeEntity? memberHome;
  final TrainerHomeEntity? trainerHome;
  const HomeEntity({this.adminHome, this.memberHome, this.trainerHome});

  HomeEntity copyWith({
    AdminHomeEntity? adminHome,
    MemberHomeEntity? memberHome,
    TrainerHomeEntity? trainerHome,
  }) => HomeEntity(
      adminHome: adminHome ?? this.adminHome,
      memberHome: memberHome ?? this.memberHome,
      trainerHome: trainerHome ?? this.trainerHome);
}
