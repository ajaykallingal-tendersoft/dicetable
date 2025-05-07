import 'package:bloc/bloc.dart';
import 'package:dicetable/src/ui/customer/profile/model/customer_profile_model.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc()
      : super(ProfileState(
    profile: CustomerProfileModel(
      firstName: 'Sun Cafe',
      email: 'SunCafe0123@gmail.com',
      password: 'XXXXXXX',
      phone: '091123456789',
      country: 'New Zealand',
      region: 'Northland Region',
    ),
  )) {
    on<ToggleEditMode>((event, emit) {
      emit(state.copyWith(isEditMode: !state.isEditMode));
    });

    on<UpdateProfileField>((event, emit) {
      final updated = _updateField(state.profile, event.field, event.value);
      emit(state.copyWith(profile: updated));
    });
  }

  CustomerProfileModel _updateField(CustomerProfileModel profile, String field, String value) {
    switch (field) {
      case 'name':
        return profile.copyWith(firstName: value);
      case 'email':
        return profile.copyWith(email: value);
      case 'password':
        return profile.copyWith(password: value);
      case 'phone':
        return profile.copyWith(phone: value);
      case 'country':
        return profile.copyWith(country: value);
      case 'region':
        return profile.copyWith(region: value);
      default:
        return profile;
    }
  }
}

