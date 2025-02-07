import 'package:equatable/equatable.dart';

abstract class BlocState extends Equatable {
  // final List<City> cities;
  const BlocState();

  @override
  List<Object?> get props => [];
}

class Initial extends BlocState {}

class Loading extends BlocState {}

class Loaded extends BlocState {
  final dynamic data;

  const Loaded({required this.data});
}

class Error extends BlocState {
  final String? message;
  const Error(this.message);
}
