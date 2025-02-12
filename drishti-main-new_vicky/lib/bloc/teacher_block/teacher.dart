// import 'package:srisridrishti/handler/responses/all_events_response.dart';
// import 'package:srisridrishti/services/events_services/events_services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:srisridrishti/models/teacher_events_model.dart';
// import 'package:srisridrishti/services/event_services.dart';

// // Events
// abstract class TeacherEventEvent extends Equatable {
//   const TeacherEventEvent();

//   @override
//   List<Object> get props => [];
// }

// class FetchTeacherEvents extends TeacherEventEvent {}

// // States
// abstract class TeacherEventState extends Equatable {
//   const TeacherEventState();
  
//   @override
//   List<Object> get props => [];
// }

// class TeacherEventInitial extends TeacherEventState {}

// class TeacherEventLoadInProgress extends TeacherEventState {}

// class TeacherEventLoadSuccess extends TeacherEventState {
//   final TeacherEventsModel events;

//   const TeacherEventLoadSuccess(this.events);

//   @override
//   List<Object> get props => [events];
// }

// class TeacherEventLoadFailure extends TeacherEventState {
//   final String error;

//   const TeacherEventLoadFailure(this.error);

//   @override
//   List<Object> get props => [error];
// }

// // Bloc
// class TeacherEventBloc extends Bloc<TeacherEventEvent, TeacherEventState> {
//   final EventServices _eventServices;

//   TeacherEventBloc(this._eventServices) : super(TeacherEventInitial()) {
//     on<FetchTeacherEvents>(_onFetchTeacherEvents);
//   }

//   Future<void> _onFetchTeacherEvents(
//     FetchTeacherEvents event,
//     Emitter<TeacherEventState> emit,
//   ) async {
//     emit(TeacherEventLoadInProgress());
//     try {
//       final EventResponse? eventResponse = await _eventServices.getAllEvents();
//       if (eventResponse != null && eventResponse.success) {
//         final TeacherEventsModel teacherEvents = TeacherEventsModel(
//           createdCourses: eventResponse.data?.createdCourses ?? [],
//           attendedCourses: eventResponse.data?.attendedCourses ?? [],
//         );
//         emit(TeacherEventLoadSuccess(teacherEvents));
//       } else {
//         emit(TeacherEventLoadFailure(eventResponse?.message ?? 'Failed to fetch events'));
//       }
//     } catch (e) {
//       emit(TeacherEventLoadFailure(e.toString()));
//     }
//   }
// }