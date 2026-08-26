import 'home_entities.dart';

class HomeEntity {
  final AdminHomeEntity? adminHome;
  final MemberHomeEntity? memberHome;
  final TrainerHomeEntity? trainerHome;
  const HomeEntity({this.adminHome, this.memberHome, this.trainerHome});
}
