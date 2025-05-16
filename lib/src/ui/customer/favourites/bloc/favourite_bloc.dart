import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/customer/favourite/get_favourite_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/resources/api_providers/customer/favourite_data_provider.dart';
import 'package:dicetable/src/ui/customer/cafe_list/cafe_model.dart';
import 'package:equatable/equatable.dart';

part 'favourite_event.dart';

part 'favourite_state.dart';

class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  final FavouriteDataProvider favouriteDataProvider;

  FavouriteBloc({required this.favouriteDataProvider})
    : super(FavouriteInitial()) {
    on<GetFavEvent>(_onGetFav);
    on<ToggleFavStatusEvent>(_onToggleFavStatus);
  }

  Future<void> _onGetFav(
    GetFavEvent event,
    Emitter<FavouriteState> emit,
  ) async {
    emit(FavouriteLoading());

    final StateModel? stateModel = await favouriteDataProvider.getFavourite();

    if (stateModel is SuccessState) {
      final response = stateModel.value as GetFavouriteResponse;
      final cafes = response.data ?? [];

      final updatedCafes =
      cafes.map((cafe) => cafe.copyWith(isFavorite: true)).toList();

      emit(FavouriteLoaded(cafes: updatedCafes));

      emit(FavouriteLoaded(cafes: updatedCafes));
    } else if (stateModel is ErrorState) {
      emit(FavouriteError(errorMessage: stateModel.msg));
    }
  }

  void _onToggleFavStatus(
    ToggleFavStatusEvent event,
    Emitter<FavouriteState> emit,
  ) {
    if (state is FavouriteLoaded) {
      final currentState = state as FavouriteLoaded;
      final updatedList = List<Datum>.from(currentState.cafes);

      final current = updatedList[event.index];
      updatedList[event.index] = current.copyWith(
        isFavorite: !current.isFavorite,
      );

      emit(FavouriteLoaded(cafes: updatedList));
    }
  }
}
