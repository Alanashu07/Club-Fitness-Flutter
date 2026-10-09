import 'package:club_fitness/di.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemberDetailProvider extends StatelessWidget {
  final String memberId;
  const MemberDetailProvider({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MemberDetailBloc(sl())..add(GetMemberDetailsEvent(memberId)),
      child: MemberDetailScreen(memberId: memberId),
    );
  }
}