part of 'cafe_list_bloc.dart';

// @immutable
// sealed class CafeListState {}
//
// final class CafeListInitial extends CafeListState {}
class CafeState{
  final List<CafeModel> cafes;
  CafeState(this.cafes);
}