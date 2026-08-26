import 'package:club_fitness/core/entities/pagination_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/usecases/usecase.dart';
import '../repository/workout_manager_repo.dart';
import '../entities/workout_manager_entities.dart';

class GetAllPlans implements UseCase<ResponseEntity<PlanListingEntity>, GetAllPlansParams> {
  final WorkoutManagerRepo repo;

  const GetAllPlans(this.repo);

  @override
  Future<Either<ResponseEntity<PlanListingEntity>, Failure>> call(GetAllPlansParams params) async {
    return await repo.getAllPlans(
      search: params.search,
      type: params.type,
      isTemplate: params.isTemplate,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetAllPlansParams {
  final String? search;
  final String? type;
  final bool? isTemplate;
  final num? page;
  final num? limit;

  const GetAllPlansParams({
    required this.search,
    required this.type,
    required this.isTemplate,
    required this.page,
    required this.limit,
  });
}
