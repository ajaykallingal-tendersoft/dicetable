import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_search_request.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_search_response.dart';
import 'package:dicetable/src/resources/api_providers/customer/cafe_data_provider.dart';
import 'package:dicetable/src/utils/extension/state_model_extension.dart';
import 'package:equatable/equatable.dart';

part 'customer_home_event.dart';
part 'customer_home_state.dart';

class CustomerHomeBloc extends Bloc<CustomerHomeEvent, CustomerHomeState> {
  final CafeDataProvider cafeDataProvider;
  CustomerHomeBloc({required this.cafeDataProvider}) : super(CustomerHomeInitial()) {
    on<SearchCafesEvent>(_onSearchCafes);
    on<FilterCafesEvent>(_onFilterCafes);
    on<ResetSearchEvent>(_onResetSearch);
  }
  Future<void> _onSearchCafes(
      SearchCafesEvent event,
      Emitter<CustomerHomeState> emit,
      ) async {
    emit(CafeSearchLoading());

    final result = await cafeDataProvider.cafeSearch(event.request);

    if (result == null) {
      emit(const CafeSearchError('No response received from server'));
      return;
    }

    if (result.isSuccess && result.data != null) {
      final cafeLocations = _extractCafeLocations(result.data!);
      emit(CafeSearchSuccess(
        response: result.data!,
        cafeLocations: cafeLocations,
      ));
    } else if (result.isError) {
      emit(CafeSearchError(result.error ?? 'Unknown error occurred'));
    } else {
      emit(const CafeSearchError('Failed to search cafes'));
    }
  }

  Future<void> _onFilterCafes(
      FilterCafesEvent event,
      Emitter<CustomerHomeState> emit,
      ) async {
    emit(CafeSearchLoading());

    final result = await cafeDataProvider.cafeSearch(event.filterRequest);

    if (result == null) {
      emit(const CafeSearchError('No response received from server'));
      return;
    }

    if (result.isSuccess && result.data != null) {
      final cafeLocations = _extractCafeLocations(result.data!);
      emit(CafeSearchSuccess(
        response: result.data!,
        cafeLocations: cafeLocations,
      ));
    } else if (result.isError) {
      emit(CafeSearchError(result.error ?? 'Unknown error occurred'));
    } else {
      emit(const CafeSearchError('Failed to filter cafes'));
    }
  }

  void _onResetSearch(
      ResetSearchEvent event,
      Emitter<CustomerHomeState> emit,
      ) {
    emit(CafeSearchInitial());
  }
  List<CafeLocation> _extractCafeLocations(SearchRequestResponse response) {
    if (response.cafes == null) return [];

    return response.cafes!
        .where((cafe) =>
    cafe.latitude != null &&
        cafe.longitude != null &&
        cafe.id != null &&
        cafe.name != null)
        .map((cafe) => CafeLocation(
      id: cafe.id!,
      name: cafe.name!,
      latitude: double.tryParse(cafe.latitude!) ?? 0.0,
      longitude: double.tryParse(cafe.longitude!) ?? 0.0,
      photo: cafe.photo,
      description: cafe.venueDescription,
    ))
        .toList();
  }

}
