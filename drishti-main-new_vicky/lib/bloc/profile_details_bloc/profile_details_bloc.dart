import 'package:bloc/bloc.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_event.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_state.dart';
import 'package:srisridrishti/handler/responses/profile_details_response.dart';

import '../../repos/profile_repo/profile_repository.dart';

class ProfileDetailsBloc
    extends Bloc<ProfileDetailsEvent, ProfileDetailsState> {
  final ProfileRepository _profileRepository;
  ProfileDetailsBloc(this._profileRepository) : super(ProfileDetailsInitial()) {
    on<GetProfileDetails>(_getProfileDetails);
  }

  _getProfileDetails(
      GetProfileDetails event, Emitter<ProfileDetailsState> emit) async {
    try {
      emit(ProfileDetailsLoading());

      final ProfileDetailsResponse profileResponse =
          await _profileRepository.getProfileDetails();

      if (profileResponse.success) {
        return emit(
            ProfileDetailsLoadedSuccessfully(profileResponse: profileResponse));
      } else {
        return emit(
            FailedToFetchProfileDetails(profileResponse: profileResponse));
      }
    } catch (error) {
      return emit(
        FailedToFetchProfileDetails(
          profileResponse: ProfileDetailsResponse(
              success: false, data: null, message: error.toString()),
        ),
      );
    }
  }
}
