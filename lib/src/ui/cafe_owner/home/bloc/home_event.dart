// part of 'home_bloc.dart';
//
// sealed class HomeEvent extends Equatable {
//   const HomeEvent();
// }
//
// class GetHomeDataEvent extends HomeEvent {
//   @override
//   List<Object?> get props => throw [];
// }
//
// class ToggleCardExpandedEvent extends HomeEvent {
//   final int index;
//   ToggleCardExpandedEvent(this.index);
// }
// class UpdateSelectedDayEvent extends HomeEvent {
//   final int index;
//   final AvailableDay selectedDay;
//   UpdateSelectedDayEvent({required this.index, required this.selectedDay});
// }
// class UpdatePromoAndAvailabilityTextEvent extends HomeEvent {
//   final int index;
//   final String promoText;
//   final String availabilityText;
//   UpdatePromoAndAvailabilityTextEvent({required this.index, required this.promoText, required this.availabilityText});
// }
//
// class SaveCardEvent extends HomeEvent {
//   final int index;
//   SaveCardEvent({required this.index});
// }
//
// // class ToggleCheckEvent extends HomeEvent {
// //   final int index;
// //   const ToggleCheckEvent(this.index);
// //
// //   @override
// //   // TODO: implement props
// //   List<Object?> get props => throw UnimplementedError();
// // }
// //
// // class ToggleExpandEvent extends HomeEvent {
// //   final int index;
// //   const ToggleExpandEvent(this.index);
// //
// //   @override
// //   List<Object?> get props => [];
// // }
// //
// // class UpdateAvailabilityTextEvent extends HomeEvent {
// //   final int index;
// //   final String newText;
// //   const UpdateAvailabilityTextEvent(this.index, this.newText);
// //
// //   @override
// //
// //   List<Object?> get props => [];
// // }
// //
// // class UpdatePromoTextEvent extends HomeEvent {
// //   final int index;
// //   final String newText;
// //   const UpdatePromoTextEvent(this.index, this.newText);
// //
// //   @override
// //   List<Object?> get props => [];
// // }
// //
// // class UpdateSelectedDayEvent extends HomeEvent {
// //   final int index;
// //   final AvailableDay selectedDay;
// //   const UpdateSelectedDayEvent(this.index, this.selectedDay);
// //
// //   @override
// //   List<Object?> get props => [];
// // }