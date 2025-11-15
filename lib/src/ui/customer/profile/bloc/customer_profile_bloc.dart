import 'package:bloc/bloc.dart';
import 'package:soloseaters/src/constants/app_colors.dart';
import 'package:soloseaters/src/model/customer/profile/customer_get_profile_response.dart';
import 'package:soloseaters/src/model/customer/profile/customer_profile_update_request.dart';
import 'package:soloseaters/src/model/customer/profile/customer_update_profile_response.dart';
import 'package:soloseaters/src/model/delete_profile_response.dart';
import 'package:soloseaters/src/model/state_model.dart';
import 'package:soloseaters/src/resources/api_providers/customer/profile_data_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

part 'customer_profile_event.dart';
part 'customer_profile_state.dart';

class CustomerProfileBloc extends Bloc<CustomerProfileEvent, CustomerProfileState> {
  final CustomerProfileDataProvider customerProfileDataProvider;

  CustomerProfileBloc({required this.customerProfileDataProvider})
      : super( CustomerProfileState()) {
    on<GetCustomerProfileEvent>(_onGetCustomerProfile);
    on<ToggleEditModeEvent>(_onToggleEditMode);
    on<UpdateProfileFieldEvent>(_onUpdateProfileField);
    on<FetchLocationEvent>(_onFetchLocation);
    on<SaveProfileEvent>(_onSaveProfile);
    on<CustomerProfileDeleteEvent>(_onProfileDelete);
    
  }

  Future<void> _onGetCustomerProfile(
      GetCustomerProfileEvent event,
      Emitter<CustomerProfileState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final StateModel? stateModel = await customerProfileDataProvider.getCustomerProfile();
      if (stateModel is SuccessState<CustomerGetProfileResponse>) {
        emit(state.copyWith(
          isLoading: false,
          profile: stateModel.value,
          isEditMode: false,
        ));
      } else if (stateModel is ErrorState) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: stateModel.msg,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load profile data',
        ));
      }
    } catch (e, stackTrace) {
      print('Profile Fetch Error: $e');
      print('StackTrace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading profile: $e',
      ));
    }
  }

  void _onToggleEditMode(
      ToggleEditModeEvent event,
      Emitter<CustomerProfileState> emit,
      ) {
    emit(state.copyWith(isEditMode: !state.isEditMode));
  }

  void _onUpdateProfileField(
      UpdateProfileFieldEvent event,
      Emitter<CustomerProfileState> emit,
      ) {
    final updatedData = state.profile.data?.copyWithField(event.field, event.value) ??  CustomerProfileData();
    emit(state.copyWith(profile: state.profile.copyWith(data: updatedData)));
  }

  Future<void> _onFetchLocation(
      FetchLocationEvent event,
      Emitter<CustomerProfileState> emit,
      ) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(state.copyWith(errorMessage: 'Location services are disabled'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(state.copyWith(errorMessage: 'Location permission denied'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(state.copyWith(errorMessage: 'Location permission permanently denied'));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      emit(state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        errorMessage: null,
      ));
    } catch (e, stackTrace) {
      print('Location Fetch Error: $e');
      print('StackTrace: $stackTrace');
      emit(state.copyWith(errorMessage: 'Error fetching location: $e'));
    }
  }

  Future<void> _onSaveProfile(
      SaveProfileEvent event,
      Emitter<CustomerProfileState> emit,
      ) async {
    if (state.profile.data == null) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'No profile data to save',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      if (state.latitude == null || state.longitude == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Location data unavailable',
        ));
        return;
      }

      final updateRequest = CustomerUpdateProfileRequest(
        id: state.profile.data!.id,
        name: state.profile.data!.name,
        email: state.profile.data!.email,
        phone: state.profile.data!.phone,
        country: state.profile.data!.country,
        region: state.profile.data!.state,
        latitude: state.latitude,
        longitude: state.longitude,
      );

      final StateModel? stateModel = await customerProfileDataProvider.updateCustomerProfile(updateRequest);
      if (stateModel is SuccessState<CustomerUpdateProfileResponse>) {
        final getStateModel = await customerProfileDataProvider.getCustomerProfile();
        if (getStateModel is SuccessState<CustomerGetProfileResponse>) {
          emit(state.copyWith(
            isLoading: false,
            isEditMode: false,
            profile: getStateModel.value,
            errorMessage: null,
          ));
          Fluttertoast.showToast(
            backgroundColor: AppColors.primaryWhiteColor,
            textColor: AppColors.appGreenColor,
            gravity: ToastGravity.BOTTOM,
            msg: "Profile updated successfully!",
          );

        } else {
          emit(state.copyWith(
            isLoading: false,
            isEditMode: false,
            errorMessage: 'Profile updated, but failed to fetch updated data',
          ));
        }
      } else if (stateModel is ErrorState) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: stateModel.msg,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update profile',
        ));
      }
    } catch (e, stackTrace) {
      print('Profile Update Error: $e');
      print('StackTrace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error updating profile: $e',
      ));
    }
  }

  Future<void> _onProfileDelete(
      CustomerProfileDeleteEvent event,
      Emitter<CustomerProfileState> emit,
      ) async {
    emit(CustomerProfileDeleteLoading());

    final StateModel? stateModel = await customerProfileDataProvider.customerProfileDelete();

    if (stateModel is SuccessState) {
      final response = stateModel.value as DeleteProfileResponse;

      emit(CustomerProfileDeleteSuccess( deleteProfileResponse: response));

    } else if (stateModel is ErrorState) {
      emit(CustomerProfileDeleteError(errorMessage: stateModel.msg));
    }
  }

}