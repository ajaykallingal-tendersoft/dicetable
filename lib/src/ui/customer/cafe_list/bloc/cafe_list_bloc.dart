import 'package:bloc/bloc.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/customer/cafe/add_favourite_request.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_request.dart';
import 'package:soloseaters/src/model/customer/cafe/cafe_list_response.dart';
import 'package:soloseaters/src/model/customer/cafe/favourite_list_response.dart';
import 'package:soloseaters/src/model/customer/cafe/get_filter_options_response.dart';
import 'package:soloseaters/src/model/customer/cafe/remove_favourite_request.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/resources/api_providers/customer/cafe_data_provider.dart';
import 'package:soloseaters/src/ui/customer/home/bloc/customer_home_bloc.dart';
import 'package:soloseaters/src/utils/data/object_factory.dart';
import 'package:soloseaters/src/utils/extension/state_model_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

part 'cafe_list_event.dart';

part 'cafe_list_state.dart';

class CafeListBloc extends Bloc<CafeListEvent, CafeListState> {
  CafeDataProvider cafeDataProvider;
  late Set<String> _selectedTableTypes = {};
  late Set<String> _selectedVenueTypes = {};
  late TimeOfDay _openTime = const TimeOfDay(hour: 0, minute: 0);
  late TimeOfDay _closeTime = const TimeOfDay(hour: 0, minute: 0);
  GetFilterOptionsResponse? _cachedFilterOptions; // Cache for filter options

  Set<String> get selectedTableTypes => Set.from(_selectedTableTypes);

  Set<String> get selectedVenueTypes => Set.from(_selectedVenueTypes);

  TimeOfDay get openTime => _openTime;

  TimeOfDay get closeTime => _closeTime;

  CafeListBloc({required this.cafeDataProvider}) : super(CafeListInitial()) {
    on<GetCafeListEvent>(_onGetCafeList);
    on<GetFavListEvent>(_onGetFavList);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<FilterOptionsEvent>(_onGetFilterOptions);
    on<FiltersUpdateEvent>(_onUpdateFilters);
    on<FiltersClearEvent>(_onClearFilters);
    on<RefreshCafeDetailsEvent>(_onRefreshCafeDetails);
    
  }

  Future<void> _onGetCafeList(
    GetCafeListEvent event,
    Emitter<CafeListState> emit,
  ) async {
    emit(CafeListLoading());
    try {
      final StateModel? stateModel = await cafeDataProvider.getCafeList(
        event.cafeListRequest,
      );

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

    if (currentState is CafeListLoaded) {
      final isGuest = ObjectFactory().prefs.isGuestUser() == true;

      if (isGuest) {
        Fluttertoast.showToast(
          msg: "Please login to proceed.",
          backgroundColor: AppColors.appRedColor,
          textColor: AppColors.primaryWhiteColor,
          gravity: ToastGravity.BOTTOM,
        );

        Future.delayed(Duration.zero, () {
          event.context.go('/customer_login');
          ObjectFactory().prefs.setIsGuestUser(false);
        });

        return;
      }
      final cafe = currentState.cafeListResponse.cafes![event.cafeIndex];
      final cafeId = cafe.id!;
      final isFavorite = cafe.favourites!;
      // final isGuest = ObjectFactory().prefs.isGuestUser() == true;
      final deviceToken =
          isGuest ? ObjectFactory().prefs.getDeviceID() ?? '' : '';

      emit(
        FavoriteToggleLoading(
          cafeListResponse: currentState.cafeListResponse,
          toggledCafeIndex: event.cafeIndex,
        ),
      );

      try {
        StateModel? result;

        if (isFavorite) {
          result = await cafeDataProvider.removeFavourite(
            RemoveFavouriteRequest(cafeId: cafeId),
          );
        } else {
          result = await cafeDataProvider.addFavourite(
            AddFavouriteRequest(cafeId: cafeId, deviceToken: deviceToken),
          );
        }

        if (result is SuccessState) {
          final updatedCafes = List<Cafe>.from(
            currentState.cafeListResponse.cafes!,
          );
          updatedCafes[event.cafeIndex] = updatedCafes[event.cafeIndex]
              .copyWith(favourites: !isFavorite);

          final updatedResponse = currentState.cafeListResponse.copyWith(
            cafes: updatedCafes,
          );

          emit(CafeListLoaded(cafeListResponse: updatedResponse));
        } else if (result is ErrorState) {
          final errorMessage = result.error ?? "";
          if (errorMessage.toLowerCase().contains("signup") ||
              errorMessage.contains("Unauthorized") ||
              errorMessage.contains("status code of 401") ||
              errorMessage.contains("Unknown error")) {
            emit(CafeListError(errorMessage: "Exception caught for UnAuthorized access. Please login again!"));
          } else {
            emit(
              CafeListLoaded(cafeListResponse: currentState.cafeListResponse),
            );
          }
        }
      } catch (e, stackTrace) {
        print('Toggle Favorite Error: $e');
        print('StackTrace: $stackTrace');
        emit(CafeListLoaded(cafeListResponse: currentState.cafeListResponse));
      }
    } else if (currentState is FavListLoaded) {
      final cafe = currentState.favListResponse.cafes![event.cafeIndex];
      final cafeId = cafe.id!;
      final isFavorite = cafe.favourites!;

      // Convert FavWorkingHour to WorkingHour
      List<WorkingHour>? convertWorkingHours(
        List<FavWorkingHour>? favWorkingHours,
      ) {
        if (favWorkingHours == null) return null;
        return favWorkingHours
            .map(
              (favHour) => WorkingHour(
                day: favHour.day,
                opening: favHour.opening,
                closing: favHour.closing,
              ),
            )
            .toList();
      }

      emit(
        FavoriteToggleLoading(
          cafeListResponse: CafeListResponse(
            cafes:
                currentState.favListResponse.cafes!
                    .asMap()
                    .entries
                    .map(
                      (entry) => Cafe(
                        id: entry.value.id,
                        name: entry.value.name,
                        photo: entry.value.photo,
                        venueDescription: entry.value.venueDescription,
                        tableTypes: entry.value.tableTypes,
                        workingHours: convertWorkingHours(
                          entry.value.workingHours,
                        ),
                        favourites: entry.value.favourites,
                        bookingStatus: entry.value.bookingStatus,
                      ),
                    )
                    .toList(),
          ),
          toggledCafeIndex: event.cafeIndex,
        ),
      );

      try {
        StateModel? result;

        if (isFavorite) {
          result = await cafeDataProvider.removeFavourite(
            RemoveFavouriteRequest(cafeId: cafeId),
          );
        } else {
          result = await cafeDataProvider.addFavourite(
            AddFavouriteRequest(cafeId: cafeId),
          );
        }

        if (result is SuccessState) {
          final updatedCafes = List<FavCafe>.from(
            currentState.favListResponse.cafes!,
          );
          updatedCafes[event.cafeIndex] = updatedCafes[event.cafeIndex]
              .copyWith(favourites: !isFavorite);

          // Filter out cafes that are no longer favorites
          final filteredCafes =
              updatedCafes.where((cafe) => cafe.favourites == true).toList();

          final updatedResponse = currentState.favListResponse.copyWith(
            cafes: filteredCafes,
          );

          emit(FavListLoaded(favListResponse: updatedResponse));
        } else if (result is ErrorState) {
          emit(FavListLoaded(favListResponse: currentState.favListResponse));
        }
      } catch (e, stackTrace) {
        print('Toggle Favorite Error: $e');
        print('StackTrace: $stackTrace');
        emit(FavListLoaded(favListResponse: currentState.favListResponse));
      }
    }
  }


  Future<void> _onGetFilterOptions(
    FilterOptionsEvent event,
    Emitter<CafeListState> emit,
  ) async {
    if (_cachedFilterOptions != null &&
        _cachedFilterOptions!.diceTables!.isNotEmpty &&
        _cachedFilterOptions!.venueTypes!.isNotEmpty) {
      emit(FilterLoaded(getFilterOptionsResponse: _cachedFilterOptions!));
      return;
    }

    emit(FilterLoading());
    try {
      final StateModel? stateModel = await cafeDataProvider.getFilterOptions();

      if (stateModel is SuccessState) {
        _cachedFilterOptions = stateModel.value;
        emit(FilterLoaded(getFilterOptionsResponse: stateModel.value));
      } else if (stateModel is ErrorState) {
        emit(FilterError(stateModel.msg));
      }
    } catch (e, stackTrace) {
      print('Filter Options Error: $e');
      print('StackTrace: $stackTrace');
      emit(FilterError(e.toString()));
    }
  }

Future<void> _onRefreshCafeDetails(
  RefreshCafeDetailsEvent event,
  Emitter<CafeListState> emit,
) async {
  final currentState = state;

  try {
    final StateModel? stateModel = await cafeDataProvider.getCafeList(
      event.cafeListRequest,
    );

    if (stateModel is SuccessState) {
      final response = stateModel.value as CafeListResponse;
      final int? targetCafeId = int.tryParse(event.cafeId.toString());

      if (targetCafeId != null) {
        // Find the specific updated cafe in the new response
        Cafe? updatedCafe;
        try {
          updatedCafe = response.cafes?.firstWhere((c) => c.id == targetCafeId);
        } on StateError {
          // firstWhere throws StateError if no element is found; treat that as not found.
          updatedCafe = null;
        }

        // If the previous state was a loaded list, update that list
        if (currentState is CafeListLoaded && updatedCafe != null) {
          final existingCafes =
              List<Cafe>.from(currentState.cafeListResponse.cafes!);
          final index = existingCafes.indexWhere((c) => c.id == targetCafeId);

          if (index != -1) {
            existingCafes[index] = updatedCafe;

            // Emit the CafeListLoaded state with the updated list.
            // This is the key change to keep the list screen updated.
            emit(CafeListLoaded(
              cafeListResponse:
                  currentState.cafeListResponse.copyWith(cafes: existingCafes),
            ));
          }
        }

        // Emit the single detail state for the details screen to update attendees
        if (updatedCafe != null) {
          emit(SingleCafeDetailsLoaded(cafe: updatedCafe));
        }
      }
    } else if (stateModel is ErrorState) {
      emit(SingleCafeDetailsError(errorMessage: stateModel.msg));
    }
  } catch (e, stackTrace) {
    print('RefreshCafeDetails Error: $e');
    emit(SingleCafeDetailsError(errorMessage: e.toString()));
  }
}

  void _onUpdateFilters(FiltersUpdateEvent event, Emitter<CafeListState> emit) {
    _selectedTableTypes = Set.from(event.selectedTableTypes);
    _selectedVenueTypes = Set.from(event.selectedVenueTypes);
    _openTime = event.openTime;
    _closeTime = event.closeTime;

    emit(
      UpdateFilter(
        selectedTableTypes: _selectedTableTypes,
        selectedVenueTypes: _selectedVenueTypes,
        openTime: _openTime,
        closeTime: _closeTime,
      ),
    );
  }

  void _onClearFilters(FiltersClearEvent event, Emitter<CafeListState> emit) {
    _selectedTableTypes.clear();
    _selectedVenueTypes.clear();
    _openTime = const TimeOfDay(hour: 00, minute: 0);
    _closeTime = const TimeOfDay(hour: 00, minute: 0);

    emit(FilterClear());

    if (_cachedFilterOptions != null &&
        _cachedFilterOptions!.diceTables!.isNotEmpty &&
        _cachedFilterOptions!.venueTypes!.isNotEmpty) {
      emit(FilterLoaded(getFilterOptionsResponse: _cachedFilterOptions!));
    } else {
      add(FilterOptionsEvent());
    }
  }
}
