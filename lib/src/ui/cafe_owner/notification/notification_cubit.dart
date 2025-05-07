import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<int> {
  NotificationCubit() : super(0);
  void increment() => emit(state + 1);

  void clear() => emit(0);

  void setCount(int count) => emit(count);
}
