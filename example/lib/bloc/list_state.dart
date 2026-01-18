import 'package:equatable/equatable.dart';
import '../utils/models.dart';

abstract class ListState extends Equatable {
  const ListState();

  @override
  List<Object?> get props => [];
}

class ListInitial extends ListState {}

class ListLoading extends ListState {}

class ListSuccess extends ListState {
  final List<ListData> data;

  const ListSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class ListFailure extends ListState {
  final String title;
  final String message;

  const ListFailure({required this.title, required this.message});

  @override
  List<Object?> get props => [title, message];
}
