// part of 'paid_profile_bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soloseaters/src/model/customer/profile/customer_paid_profile_request.dart';

abstract class PaidProfileEvent extends Equatable {
  const PaidProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetPaidProfileEvent extends PaidProfileEvent {
  const GetPaidProfileEvent();
}

class UpdatePaidProfileEvent extends PaidProfileEvent {
  final PaidProfileUpdateRequest request;

  const UpdatePaidProfileEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

class AddBusinessImagesEvent extends PaidProfileEvent {
  final List<XFile> images;

  const AddBusinessImagesEvent(this.images);

  @override
  List<Object?> get props => [images];
}

class AddHobbyImagesEvent extends PaidProfileEvent {
  final List<XFile> images;

  const AddHobbyImagesEvent(this.images);

  @override
  List<Object?> get props => [images];
}

class RemoveBusinessImageEvent extends PaidProfileEvent {
  final int index;

  const RemoveBusinessImageEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class RemoveHobbyImageEvent extends PaidProfileEvent {
  final int index;

  const RemoveHobbyImageEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class ToggleVenueNotification extends PaidProfileEvent {
  final int venueId;  // Changed from String to int
  final bool isEnabled;

  const ToggleVenueNotification({
    required this.venueId,
    required this.isEnabled,
  });

  @override
  List<Object?> get props => [venueId, isEnabled];
}

class TogglePreferenceEvent extends PaidProfileEvent {
  final int preferenceId;  // Changed from String to int
  final bool isEnabled;

  const TogglePreferenceEvent({
    required this.preferenceId,
    required this.isEnabled,
  });

  @override
  List<Object?> get props => [preferenceId, isEnabled];
}

class UpdateTextFieldEvent extends PaidProfileEvent {
  const UpdateTextFieldEvent();
}

class ResetUpdateStatusEvent extends PaidProfileEvent {
  const ResetUpdateStatusEvent();
}

class UpdateProfileImageEvent extends PaidProfileEvent {
  final XFile image;

  const UpdateProfileImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}