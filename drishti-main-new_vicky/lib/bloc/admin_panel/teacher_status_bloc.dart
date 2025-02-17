// teacher_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:srisridrishti/models/teacher_details_model.dart';
import 'package:srisridrishti/services/admin_panel/teacher_status.dart';

// Events
abstract class TeacherEvent {}

class FetchTeachersRequest extends TeacherEvent {}

class ApproveTeacher extends TeacherEvent {
  final String teacherId;
  ApproveTeacher(this.teacherId);
}

class SuspendTeacher extends TeacherEvent {
  final String teacherId;
  SuspendTeacher(this.teacherId);
}

// States
abstract class TeacherState {}

class TeacherInitial extends TeacherState {}

class TeacherLoading extends TeacherState {}

class TeacherLoaded extends TeacherState {
  final List<TeachersDetails> teachers;
  TeacherLoaded(this.teachers);
}

class TeacherError extends TeacherState {
  final String message;
  TeacherError(this.message);
}

class TeacherActionSuccess extends TeacherState {}

// Bloc
class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final ApiService _apiService;

  TeacherBloc(this._apiService) : super(TeacherInitial()) {
    on<FetchTeachersRequest>(_onFetchTeachersRequest);
    on<ApproveTeacher>(_onApproveTeacher);
    on<SuspendTeacher>(_onSuspendTeacher);
  }

  Future<void> _onFetchTeachersRequest(
    FetchTeachersRequest event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      final teachers = await _apiService.getTeachersRequest();
      emit(TeacherLoaded(teachers));
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }

  Future<void> _onApproveTeacher(
    ApproveTeacher event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      final success = await _apiService.approveTeacher(event.teacherId);
      if (success) {
        emit(TeacherActionSuccess());
        add(FetchTeachersRequest());
      } else {
        emit(TeacherError('Failed to approve teacher'));
      }
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }

  Future<void> _onSuspendTeacher(
    SuspendTeacher event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      final success = await _apiService.suspendTeacher(event.teacherId);
      if (success) {
        emit(TeacherActionSuccess());
        add(FetchTeachersRequest());
      } else {
        emit(TeacherError('Failed to suspend teacher'));
      }
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }
}
