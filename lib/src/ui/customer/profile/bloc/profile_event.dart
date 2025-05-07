part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
}
class ToggleEditMode extends ProfileEvent {
  @override

  List<Object?> get props => [];
}


class UpdateProfileField extends ProfileEvent {
  final String field;
  final String value;

  const UpdateProfileField({required this.field, required this.value});

  @override

  List<Object?> get props => [field,value];
}