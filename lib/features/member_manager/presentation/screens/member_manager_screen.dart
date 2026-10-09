import 'package:club_fitness/di.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminMembersScreen extends StatelessWidget {
  const AdminMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MembersListingBloc(sl())..add(const GetMembersListingEvent()),
      child: const AdminMembersView(),
    );
  }
}