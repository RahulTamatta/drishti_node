import 'package:equatable/equatable.dart';

abstract class BlocEvent extends Equatable {
  const BlocEvent();

  @override
  List<Object> get props => [];
}

class AddProfile extends BlocEvent {
  final dynamic add;
  final dynamic header;

  const AddProfile({required this.add, required this.header});
}

class UpdateProfile extends BlocEvent {
  final dynamic add;
  final dynamic header;

  final dynamic id;

  const UpdateProfile(
      {required this.add, required this.header, required this.id});
}

class NotifyMe extends BlocEvent {
  final dynamic id;
  final dynamic header;

  const NotifyMe({required this.id, required this.header});
}

class NearUser extends BlocEvent {
  final dynamic add;

  const NearUser({required this.add});
}

class NearEvent extends BlocEvent {
  final dynamic add;

  const NearEvent({required this.add});
}

class CreateAddress extends BlocEvent {
  final dynamic add;

  const CreateAddress({required this.add});
}

class UpdateUserLocation extends BlocEvent {
  final dynamic add;
  final dynamic header;
  const UpdateUserLocation({required this.add, required this.header});
}

class DeleteAddress extends BlocEvent {
  final dynamic id;

  const DeleteAddress({required this.id});
}

class EditAddress extends BlocEvent {
  final dynamic id, add;

  const EditAddress({required this.id, required this.add});
}

class GetAddress extends BlocEvent {
  final dynamic id;
  const GetAddress({required this.id});
}

class NotificationById extends BlocEvent {
  final dynamic id;
  final dynamic token;
  const NotificationById({required this.token, required this.id});
}

class GetAndSearch extends BlocEvent {
  final dynamic userName;
  const GetAndSearch({required this.userName});
}

class GetAndSearchTeacher extends BlocEvent {
  final dynamic userName;
  const GetAndSearchTeacher({required this.userName});
}

class GetApi extends BlocEvent {
  final dynamic add;
  final dynamic header;
  final dynamic type;
  final dynamic path;
  const GetApi(
      {required this.add,
      required this.path,
      required this.type,
      required this.header});
}
