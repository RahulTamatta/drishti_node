import 'package:bloc/bloc.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_event.dart';
import 'package:srisridrishti/handler/responses/onboard_response.dart';
import 'package:srisridrishti/models/user_details_model.dart';
import 'package:meta/meta.dart';

import '../../repos/profile_repo/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  ProfileBloc(this._profileRepository) : super(ProfileInitial()) {
    on<AddProfileDetails>(_addProfileDetail);
  }

  _addProfileDetail(AddProfileDetails event, Emitter<ProfileState> emit) async {
    emit(ProfileDetailsAddingWait());
    try {
      final OnboardResponse orderRes =
          await _profileRepository.addProfile(profileData: event.profileData);
      if (orderRes.success) {
        return emit(ProfileDetailsAddedSuccessfully(profileRes: orderRes));
      } else {
        return emit(ProfileDetailsAddedFailed(profileRes: orderRes));
      }
    } catch (error) {
      emit(ProfileDetailsAddedFailed(
          profileRes:
              OnboardResponse(success: false, message: error.toString())));
    }
  }
}
