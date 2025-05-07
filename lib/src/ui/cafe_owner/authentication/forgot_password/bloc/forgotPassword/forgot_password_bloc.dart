import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/forgot_password_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/forgot_password_request_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:equatable/equatable.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthDataProvider authDataProvider;
  ForgotPasswordBloc({required this.authDataProvider}) : super(ForgotPasswordInitial()) {
    on<GetForgotPasswordEvent>((event, emit) async{
      emit(ForgotPasswordLoading());
      final StateModel? stateModel =  await authDataProvider.forgotPassword(event.forgotPasswordRequest);
      if(stateModel is SuccessState) {
        emit(ForgotPasswordLoaded(forgotPasswordRequestResponse: stateModel.value));
      }else if(stateModel is ErrorState) {
        emit(ForgotPasswordError(errorMessage: stateModel.msg));
      }
    });
  }
}
