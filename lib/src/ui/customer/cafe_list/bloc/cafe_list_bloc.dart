import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/customer/cafe/add_favourite_request.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_list_response.dart';
import 'package:dicetable/src/model/customer/cafe/favourite_list_response.dart';
import 'package:dicetable/src/model/customer/cafe/remove_favourite_request.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/resources/api_providers/customer/cafe_data_provider.dart';
import 'package:equatable/equatable.dart';

part 'cafe_list_event.dart';
part 'cafe_list_state.dart';

class CafeListBloc extends Bloc<CafeListEvent, CafeListState> {
  CafeDataProvider cafeDataProvider;

  CafeListBloc({required this.cafeDataProvider}) : super(CafeListInitial()) {
    on<GetCafeListEvent>(_onGetCafeList);
    on<GetFavListEvent>(_onGetFavList);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onGetCafeList(
      GetCafeListEvent event,
      Emitter<CafeListState> emit,
      ) async {
    emit(CafeListLoading());
    try {
      final StateModel? stateModel = await cafeDataProvider.getCafeList();

      if (stateModel is SuccessState) {
        final response = stateModel.value as CafeListResponse;
        emit(CafeListLoaded(cafeListResponse: response));
      } else if (stateModel is ErrorState) {
        emit(CafeListError(errorMessage: stateModel.msg));
      }
    } catch (e, stackTrace) {
      print('CafeListBloc Error: $e');
      print('StackTrace: $stackTrace');
      emit(CafeListError(errorMessage: e.toString()));
    }
  }

  Future<void> _onGetFavList(
      GetFavListEvent event,
      Emitter<CafeListState> emit,
      ) async {
    emit(FavListLoading());
    try {
      final StateModel? stateModel = await cafeDataProvider.getFavourite();

      if (stateModel is SuccessState) {
        // final response = stateModel.value as FavouriteListResponse;
        emit(FavListLoaded(favListResponse: stateModel.value));
      } else if (stateModel is ErrorState) {
        emit(FavListError(errorMessage: stateModel.msg));
      }
    } catch (e, stackTrace) {
      print('CafeListBloc Error: $e');
      print('StackTrace: $stackTrace');
      emit(FavListError(errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteEvent event,
      Emitter<CafeListState> emit,
      ) async {
    final currentState = state;
    if (currentState is! CafeListLoaded) return;

    final cafe = currentState.cafeListResponse.cafes![event.cafeIndex];
    final cafeId = cafe.id!;
    final isFavorite = cafe.favourites!;

    // Show loading state for this specific cafe
    emit(FavoriteToggleLoading(
      cafeListResponse: currentState.cafeListResponse,
      toggledCafeIndex: event.cafeIndex,
    ));

    try {
      StateModel? result;

      if (isFavorite) {
        // Remove from favorites
        result = await cafeDataProvider.removeFavourite(RemoveFavouriteRequest(cafeId: cafeId));
      } else {
        // Add to favorites
        result = await cafeDataProvider.addFavourite(AddFavouriteRequest(cafeId: cafeId));
      }

      if (result is SuccessState) {
        // Update the cafe's favorite status in the current list
        final updatedCafes = List<Cafe>.from(currentState.cafeListResponse.cafes!);
        updatedCafes[event.cafeIndex] = updatedCafes[event.cafeIndex].copyWith(
          favourites: !isFavorite,
        );

        final updatedResponse = currentState.cafeListResponse.copyWith(
          cafes: updatedCafes,
        );

        emit(CafeListLoaded(cafeListResponse: updatedResponse));
      } else if (result is ErrorState) {
        // Revert to previous state on error
        emit(CafeListLoaded(cafeListResponse: currentState.cafeListResponse));

        // You might want to show a snackbar or toast here for the error
        // This would need to be handled in the UI layer
      }
    } catch (e, stackTrace) {
      print('Toggle Favorite Error: $e');
      print('StackTrace: $stackTrace');

      // Revert to previous state on error
      emit(CafeListLoaded(cafeListResponse: currentState.cafeListResponse));
    }
  }
}