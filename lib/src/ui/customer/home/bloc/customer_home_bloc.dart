import 'package:bloc/bloc.dart';
import 'package:dicetable/src/model/customer/cafe/cafe_search_response.dart';
import 'package:equatable/equatable.dart';

part 'customer_home_event.dart';
part 'customer_home_state.dart';

class CustomerHomeBloc extends Bloc<CustomerHomeEvent, CustomerHomeState> {
  CustomerHomeBloc() : super(CustomerHomeInitial()) {
    on<CustomerHomeEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
