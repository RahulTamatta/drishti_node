import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/bloc_latest/repository/api_repository.dart';
import 'package:srisridrishti/bloc_latest/repository/server_error.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_event.dart';

class ApiBloc extends Bloc<BlocEvent, BlocState> {
  ApiBloc() : super(Initial()) {
    ApiRepository apiRepository = ApiRepository();

    on<AddProfile>((event, emit) async {
      try {
        emit(Loading());
        final mList = await apiRepository.addProfile(event.add, event.header);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<UpdateProfile>((event, emit) async {
      try {
        emit(Loading());
        final mList = await apiRepository.updateProfile(
            event.add, event.header, event.id);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<NotifyMe>((event, emit) async {
      try {
        emit(Loading());
        final mList = await apiRepository.notifyMe(event.id, event.header);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<NearUser>((event, emit) async {
      try {
        emit(Loading());
        final mList = await apiRepository.nearUser(event.add);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<NearEvent>((event, emit) async {
      try {
        emit(Loading());
        final mList = await apiRepository.nearByEvent(event.add);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<CreateAddress>((event, emit) async {
      try {
        emit(Loading());
        final mList = await apiRepository.createAddress(event.add);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<UpdateUserLocation>((event, emit) async {
      try {
        emit(Loading());
        final mList =
            await apiRepository.updateUserLocation(event.add, event.header);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<DeleteAddress>((event, emit) async {
      try {
        emit(Loading());
        final mList = await apiRepository.deleteAddress(event.id);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<EditAddress>((event, emit) async {
      try {
        emit(Loading());
        final mList = await apiRepository.editAddress(event.id, event.add);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<GetAddress>((event, emit) async {
      try {
        emit(Loading());
        final mList = await apiRepository.getAddress(event.id);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<NotificationById>((event, emit) async {
      try {
        emit(Loading());
        final mList =
            await apiRepository.getNotificationById(event.id, event.token);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<GetAndSearch>((event, emit) async {
      try {
        emit(Loading());
        final mList = await apiRepository.getAndSearchUser(event.userName);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<GetAndSearchTeacher>((event, emit) async {
      try {
        emit(Loading());
        final mList = await apiRepository.getSearchTeacher(event.userName);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });

    on<GetApi>((event, emit) async {
      try {
        emit(Loading());
        final mList = await apiRepository.getApi(
            event.add, event.header, event.path, event.type);

        if (mList.data == null) {
          ServerError error = mList.getException;
          emit(Error(error.getErrorMessage()));
        } else {
          emit(Loaded(data: mList.data!));
        }
      } on NetworkError {
        emit(const Error("Failed to fetch data. is your device online?"));
      }
    });
  }
}
