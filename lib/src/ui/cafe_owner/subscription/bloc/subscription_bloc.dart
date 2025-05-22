import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/cafe_owner/subscription/initial_subscription_plan_response.dart';
import 'package:dicetable/src/model/cafe_owner/subscription/subscription_overview_response.dart';
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

      final StateModel? stateModel = await subscriptionDataProvider.subscriptionStart(event.subscriptionStartRequest);

      if (stateModel is SuccessState) {
        final response = stateModel.value as SubscriptionStartResponse;

        emit(StartSubscriptionLoaded(subscriptionStartResponse: response));

      } else if (stateModel is ErrorState) {
        emit(StartSubscriptionError(errorMessage: stateModel.msg));
      }

    });
    on<FetchInitialSubscription> (_onFetchInitialSubscription);
    on<FetchSubscriptionOverview> (_onFetchSubscriptionOverview);
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

  Future<void> _onFetchSubscriptionOverview(
      FetchSubscriptionOverview event,
      Emitter<SubscriptionState> emit,
      ) async {
    emit(SubscriptionOverviewLoading());

    final StateModel? stateModel = await subscriptionDataProvider.getSubscriptionOverview();

    if (stateModel is SuccessState) {
      final response = stateModel.value as SubscriptionOverviewResponse;

      emit(SubscriptionOverviewLoaded(subscriptionOverviewResponse: response));

    } else if (stateModel is ErrorState) {
      emit(SubscriptionOverviewError(errorMessage: stateModel.msg));
    }
  }



}
