import 'member_manager_entities.dart';

class AddMemberResult {
  final MemberListEntity member;
  final String name;
  final String phone;
  final String? planName;
  final String? planPrice;
  final DateTime? startDate;
  final DateTime? endDate;

  const AddMemberResult({
    required this.member,
    required this.name,
    required this.phone,
    this.planName,
    this.planPrice,
    this.startDate,
    this.endDate,
  });
}