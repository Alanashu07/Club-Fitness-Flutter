import 'package:club_fitness/core/utils/utils.dart';
import 'package:equatable/equatable.dart';

class OfferFilters extends Equatable {
  final String search;
  final String? planId;
  final bool? active; // null = all
  final String? appliesTo; // null = all
  final bool validNow;

  const OfferFilters({
    this.search = '',
    this.planId,
    this.active,
    this.appliesTo,
    this.validNow = false,
  });

  bool get hasAny =>
      search.isNotEmpty ||
      planId != null ||
      active != null ||
      appliesTo != null ||
      validNow;

  /// Number of filters applied (excluding the search text).
  int get count =>
      (planId?.orNull() != null ? 1 : 0) +
      (active != null ? 1 : 0) +
      (appliesTo?.orNull() != null ? 1 : 0) +
      (validNow ? 1 : 0);

  Map<String, dynamic> toQuery() => {
    if (search.trim().isNotEmpty) 'search': search.trim(),
    if (planId?.orNull() != null) 'planId': planId,
    if (active != null) 'active': active.toString(),
    if (appliesTo?.orNull() != null) 'appliesTo': appliesTo,
    if (validNow) 'validNow': 'true',
  };

  OfferFilters copyWith({
    String? search,
    String? planId,
    bool? active,
    bool forceActive = false,
    String? appliesTo,
    bool? validNow,
  }) => OfferFilters(
    search: search ?? this.search,
    planId: planId ?? this.planId,
    active: active ?? (forceActive ? null : this.active),
    appliesTo: appliesTo ?? this.appliesTo,
    validNow: validNow ?? this.validNow,
  );

  @override
  List<Object?> get props => [search, planId, active, appliesTo, validNow];
}
