import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/cafe_owner/subscription/initial_subscription_plan_response.dart';
import 'package:dicetable/src/model/cafe_owner/subscription/subscription_start_request.dart';
import 'package:dicetable/src/model/cafe_owner/subscription/subscription_start_request_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/resources/api_providers/venue_owner/subscription_data_provider.dart';
import 'package:dicetable/src/utils/extension/state_model_extension.dart';
import 'package:equatable/equatable.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionDataProvider subscriptionDataProvider;
  SubscriptionBloc({required this.subscriptionDataProvider}) : super(SubscriptionInitial()) {
    on<StartSubscriptionEvent>((event, emit) async {
      emit(StartSubscriptionLoading());

      final result = await subscriptionDataProvider.subscriptionStart(event.subscriptionStartRequest);

      if (result!.isError) {
        final error = result.error;

        if (error is SubscriptionStartResponse) {
          final firstError =
              error.errors?.values.first.first ?? "Signup failed.";
          emit(StartSubscriptionError(errorMessage: firstError));
        } else if (error is String) {
          emit(StartSubscriptionError(errorMessage: error));
        } else {
          emit(StartSubscriptionError(errorMessage: "Something went wrong."));
        }
      } else if (result.isSuccess) {
        final response = result.data as SubscriptionStartResponse;

        if (response.status == true) {
          emit(StartSubscriptionLoaded(subscriptionStartResponse: response));
        } else {
          emit(
            StartSubscriptionError(
              errorMessage:
              response.errors?.values.first.first ?? "Signup failed",
            ),
          );
        }
      }
    });
    on<FetchInitialSubscription> (_onFetchInitialSubscription);
  }

  Future<void> _onFetchInitialSubscription(
      FetchInitialSubscription event,
      Emitter<SubscriptionState> emit,
      ) async {
    emit(InitialSubscriptionLoading());

    final StateModel? stateModel = await subscriptionDataProvider.getInitialSubscription();

    if (stateModel is SuccessState) {
      final response = stateModel.value as InitialSubscriptionPlanResponse;

      emit(InitialSubscriptionLoaded(initialSubscriptionPlanResponse: response));

    } else if (stateModel is ErrorState) {
      emit(InitialSubscriptionError(errorMessage: stateModel.msg));
    }
  }



}
