import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/resources/api_providers/venue_owner/notification_data_provider.dart';
import 'package:dicetable/src/ui/cafe_owner/notification/notification_item.dart';
import 'package:dicetable/src/utils/data/object_factory.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {

  final NotificationDataProvider notificationDataProvider;

  NotificationBloc({required this.notificationDataProvider}) : super(const NotificationInitial()) {

    on<FetchNotifications>((event, emit) async {

      emit(const NotificationLoading());

      final StateModel? stateModel = ObjectFactory().prefs.getUserDecisionName() == "PUBLIC_USER"
          ? await NotificationDataProvider().getCustomerNotificationDataById()
          : await NotificationDataProvider().getCafeNotificationDataById();

      if (stateModel is SuccessState) {

        final response = stateModel.value as NotificationItems;
        emit(NotificationLoaded(notificationItems: response));

      } else if (stateModel is ErrorState) {

        emit(NotificationError(errorMessage: stateModel.msg));

      }
    });

    on<ReadNotification>((event, emit) async {
      emit(const NotificationLoading());
      final StateModel? stateModel = await notificationDataProvider.markNotificationAsRead(event.notificationReadRequest);
      if (stateModel is SuccessState) {
        final response = stateModel.value as NotificationReadResponse;
        if (response.status) {
          emit(NotificationRead(notificationReadResponse: response));
        } else {
          emit(NotificationError(errorMessage: response.message ?? 'Failed to update notification'));
        }
      } else if (stateModel is ErrorState) {
        emit(NotificationError(errorMessage: stateModel.msg));
      }
    });

  }

}
