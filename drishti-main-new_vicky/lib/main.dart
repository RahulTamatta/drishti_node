import 'package:srisridrishti/bloc/auth_bloc/authentication_bloc.dart';
import 'package:srisridrishti/bloc/create_event_bloc/create_event_bloc.dart';
import 'package:srisridrishti/bloc/profile_bloc/profile_bloc.dart';
import 'package:srisridrishti/bloc/profile_details_bloc/profile_details_bloc.dart';
import 'package:srisridrishti/handler/responses/onboard_response.dart';
import 'package:srisridrishti/handler/responses/profile_details_response.dart';
import 'package:srisridrishti/models/create_event_model.dart';
import 'package:srisridrishti/models/search_user.dart';
import 'package:srisridrishti/models/user_details_model.dart';
import 'package:srisridrishti/providers/bottom_content_provider.dart';
import 'package:srisridrishti/providers/course_list_provder.dart';
import 'package:srisridrishti/providers/create_event_provider.dart';
import 'package:srisridrishti/providers/home_provider.dart';
import 'package:srisridrishti/providers/location_provider.dart';
import 'package:srisridrishti/providers/select_course_provider.dart';
import 'package:srisridrishti/providers/teacher_provider.dart';
import 'package:srisridrishti/repos/auth_repo/auth_repository_imp.dart';
import 'package:srisridrishti/repos/events/all_event_repo_imp.dart';
import 'package:srisridrishti/repos/profile_repo/profile_repository.dart';
import 'package:srisridrishti/screens/profile/screens/profile_details_screen.dart';
import 'package:srisridrishti/services/firebase_global_service.dart';
import 'package:srisridrishti/services/profile_services/profile_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'bloc/all_event_bloc/all_event_bloc.dart';
import 'bloc/app_bloc_observer.dart';
import 'bloc/user_location_bloc/user_location_bloc.dart';
import 'my_app.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl({required ProfileService profileService})
      : _profileService = profileService;

  @override
  Future<OnboardResponse> addProfile(
      {required Map<String, dynamic> profileData}) async {
    final onboardResponse = await _profileService.addProfileDetails(
      username: profileData['userName'] as String,
      fullName: profileData['name'] as String,
      email: profileData['email'] as String,
      phoneNumber: profileData['mobileNo'] as String,
      teacherId: profileData['teacherId'] as String? ?? '',
      isArtOfLivingTeacher:
          profileData['role'] == 'teacher' ? YesNoOption.yes : YesNoOption.no,
    );

    if (onboardResponse == null) {
      // Either throw an exception or return a default error response
      throw Exception("Failed to add profile details: null response returned.");
    }

    return onboardResponse;
  }

  @override
  Future<ProfileDetailsResponse> getProfileDetails() async {
    return await _profileService.getProfileDetails();
  }

  @override
  Future<ProfileDetailsResponse> updateProfile(
      {required Map<String, dynamic> profileData, id}) async {
    return await _profileService
        .updateProfileDetails(profileData as UserDetailsModel);
  }

  @override
  Future<ProfileDetailsResponse> deleteProfile() async {
    return await _profileService.deleteProfile();
  }
}

// Main function setup
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseGlobalService.initializeFirebase(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDDmtKuERLBt-t-j-TYUDGs6VYc-PHBw9o',
      appId: '1:707972016934:android:ec46a46a230125064c2fe7',
      messagingSenderId: '707972016934',
      projectId: 'srisridrishti-c1673',
      storageBucket: 'srisridrishti-c1673.appspot.com',
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Bloc.observer = AppBlocObserver();

  final profileService =
      ProfileService(); // Create an instance of ProfileService

  runApp(MultiBlocProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => CourseSelectionProvider()),
      ChangeNotifierProvider(create: (context) => LocationProvider()),
      ChangeNotifierProvider(create: (context) => AddressProvider()),
      ChangeNotifierProvider(
          create: (context) => CreateEventProvider(CreateEventModel())),
      ChangeNotifierProvider(create: (context) => CourseListProvider()),
      ChangeNotifierProvider(create: (context) => BottomSheetContentProvider()),
      ChangeNotifierProvider(create: (context) => HomeProvider()),
      ChangeNotifierProvider(create: (context) => TeacherProvider(TData())),
      BlocProvider(create: (context) => UserLocationBloc()),
      BlocProvider(
          create: (context) => ProfileDetailsBloc(
              ProfileRepositoryImpl(profileService: profileService))),
      BlocProvider(
          create: (context) => ProfileBloc(
              ProfileRepositoryImpl(profileService: profileService))),
      BlocProvider(
          create: (context) => CreateEventBloc(AllEventsRepositoryImpl())),
      BlocProvider(
          create: (context) => AuthenticationBloc(AuthRepositoryImp())),
      BlocProvider(
          create: (context) => AllEventBloc(AllEventsRepositoryImpl())),
    ],
    child: const MyApp(),
  ));
}
