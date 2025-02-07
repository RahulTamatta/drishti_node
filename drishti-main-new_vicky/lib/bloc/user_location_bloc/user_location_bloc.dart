import 'package:srisridrishti/providers/location_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/location_model.dart';
import '../../services/location_services/user_location_service.dart';

part 'user_location_event.dart';
part 'user_location_state.dart';

class UserLocationBloc extends Bloc<UserLocationEvent, UserLocationState> {
  UserLocationBloc() : super(UserLocationInitial()) {
    on<GetUserLocation>((event, emit) async {
      emit(const LocationLoadingState());
      try {
        LocationFetchResult result = await LocationService().fetchLocation();
        if (result.locationData != null) {
          event.context.read<LocationProvider>().updatePosition(
              lat: result.locationData?.position?.latitude ?? 0.0,
              long: result.locationData?.position?.longitude ?? 0.0);

          return emit(UserLocationLoadedSuccessfully(
              locationData: result.locationData!));
        } else {
          return emit(FailedToGetLocation());
        }
      } catch (error) {
        return emit(FailedToGetLocation());
      }
    });
  }
}
