import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/offers_entities.dart';
import '../../../domain/usecase/offers_usecases.dart';

part 'offers_event.dart';
part 'offers_state.dart';

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  final GetOffers _getOffers;
  final CreateOffer _createOffer;
  final UpdateOffer _updateOffer;
  final DeleteOffer _deleteOffer;
  OffersBloc(
    GetOffers getOffers,
    CreateOffer createOffer,
    UpdateOffer updateOffer,
    DeleteOffer deleteOffer,
  ) : _getOffers = getOffers,
      _createOffer = createOffer,
      _updateOffer = updateOffer,
      _deleteOffer = deleteOffer,
      super(const OffersInitial(offers: [], filters: OfferFilters())) {
    on<OffersEvent>((event, emit) {});
    on<GetOffersEvent>(_onGetOffers);
    on<CreateOfferEvent>(_onCreateOffer);
    on<UpdateOfferEvent>(_onUpdateOffer);
    on<DeleteOfferEvent>(_onDeleteOffer);
  }

  Future<void> _onGetOffers(
    GetOffersEvent event,
    Emitter<OffersState> emit,
  ) async {
    emit(OffersLoading(offers: state.offers, filters: event.filters));
    final result = await _getOffers(event.filters);
    result.fold(
      (l) => emit(OffersLoaded(offers: l, filters: event.filters)),
      (r) => emit(
        OffersError(offers: state.offers, filters: event.filters, failure: r),
      ),
    );
  }

  Future<void> _onCreateOffer(
    CreateOfferEvent event,
    Emitter<OffersState> emit,
  ) async {
    emit(
      OfferActionLoading(
        offers: state.offers,
        action: OfferAction.create,
        filters: state.filters,
      ),
    );
    final result = await _createOffer(event.offer);
    result.fold(
      (l) {
        final offers = [l, ...state.offers];
        emit(OfferCreated(offers: offers, filters: state.filters, offer: l));
      },
      (r) => emit(
        OffersError(failure: r, offers: state.offers, filters: state.filters),
      ),
    );
  }

  Future<void> _onUpdateOffer(
    UpdateOfferEvent event,
    Emitter<OffersState> emit,
  ) async {
    final result = await _updateOffer(event.offer);
    result.fold(
      (l) {
        final offers = state.offers.map((e) {
          if (e.id == l.id) return l;
          return e;
        });
        emit(
          OffersUpdated(
            offers: offers.toList(),
            filters: state.filters,
            offer: l,
          ),
        );
      },
      (r) => emit(
        OffersError(failure: r, offers: state.offers, filters: state.filters),
      ),
    );
  }

  Future<void> _onDeleteOffer(
    DeleteOfferEvent event,
    Emitter<OffersState> emit,
  ) async {
    final result = await _deleteOffer(event.id);
    result.fold(
      (l) {
        final offers = state.offers.where((e) => e.id != event.id).toList();
        emit(
          OfferDeleted(
            offers: offers,
            filters: state.filters,
            offer: event.id,
            message: l,
          ),
        );
      },
      (r) => emit(
        OffersError(failure: r, offers: state.offers, filters: state.filters),
      ),
    );
  }
}
