import 'package:club_fitness/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/offers_entities.dart';
import '../bloc/offers_bloc/offers_bloc.dart';
import 'offers_view.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OffersBloc(sl(), sl(), sl(), sl())..add(const GetOffersEvent(filters: OfferFilters())),
      child: const OffersView(),
    );
  }
}
