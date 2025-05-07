import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/password_reset_request.dart';
import 'package:dicetable/src/model/cafe_owner/auth/forgot_password/password_reset_request_response.dart';
import 'package:dicetable/src/model/state_model.dart';
import 'package:dicetable/src/resources/api_providers/auth/auth_data_provider.dart';
import 'package:equatable/equatable.dart';

part 'password_reset_event.dart';
part 'password_reset_state.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final AuthDataProvider authDataProvider;
  PasswordResetBloc({required this.authDataProvider}) : super(PasswordResetInitial()) {
    on<GetPasswordResetEvent>((event, emit) async{
     emit(PasswordResetLoading());
     final StateModel? stateModel =  await authDataProvider.passwordReset(event.passwordResetRequest);
     if(stateModel is SuccessState) {
       emit(PasswordResetLoaded(passwordResetRequestResponse: stateModel.value));
     }else if(stateModel is ErrorState) {
       emit(PasswordResetError(errorMessage: stateModel.msg));
     }
    });
  }
}
