import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'bloc/all_event_bloc/all_event_bloc.dart';
import 'bloc/app_bloc_observer.dart';
import 'bloc/user_location_bloc/user_location_bloc.dart';
import 'my_app.dart';

late ApiService apiService;

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl({required ProfileService profileService})
      : _profileService = profileService;

  @override
  Future<OnboardResponse> addProfile(
      {required Map<String, dynamic> profileData}) async {
    print('DEBUG: Adding profile with data: $profileData');
    try {
      final onboardResponse = await _profileService.addProfileDetails(
        userName: profileData['userName']
            as String, // Changed from username to userName
        fullName: profileData['name'] as String,
        email: profileData['email'] as String,
        phoneNumber: profileData['mobileNo'] as String,
        teacherId: profileData['teacherId'] as String? ?? '',
        isArtOfLivingTeacher:
            profileData['role'] == 'teacher' ? YesNoOption.yes : YesNoOption.no,
      );
      print('DEBUG: Add profile response: $onboardResponse');
      if (onboardResponse == null) {
        throw Exception('Failed to add profile: Response was null');
      }
      return onboardResponse;
    } catch (e) {
      print('DEBUG: Error in addProfile: $e');
      throw Exception("Failed to add profile details: $e");
    }
  }

  @override
  Future<ProfileDetailsResponse> getProfileDetails() async {
    print('DEBUG: Fetching profile details');
    try {
      final response = await _profileService.getProfileDetails();
      print('DEBUG: Profile details response: $response');
      if (response == null) {
        return ProfileDetailsResponse(
          success: false,
          message: 'Failed to fetch profile details',
          data: null,
        );
      }
      return response;
    } catch (e) {
      print('DEBUG: Error in getProfileDetails: $e');
      return ProfileDetailsResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        data: null,
      );
    }
  }

  @override
  Future<ProfileDetailsResponse> updateProfile(
      {required Map<String, dynamic> profileData, id}) async {
    print('DEBUG: Updating profile with data: $profileData, id: $id');
    try {
      // Convert profileData map to UserDetailsModel using jsonToUserDetails
      final UserDetailsModel userModel = UserDetailsModel.jsonToUserDetails({
        ...profileData,
        '_id':
            id ?? profileData['id'], // Use _id as that's what the model expects
      });

      final response = await _profileService.updateProfile(userModel);
      print('DEBUG: Update profile response: $response');
      return response;
    } catch (e) {
      print('DEBUG: Error in updateProfile: $e');
      rethrow;
    }
  }

  @override
  Future<ProfileDetailsResponse> deleteProfile() async {
    return await _profileService.deleteProfile();
  }
}

// Main function setup
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  apiService = ApiService(prefs);
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

<<<<<<< HEAD
  final profileService = ProfileService();
  final profileRepository =
      ProfileRepositoryImpl(profileService: profileService);
  final authRepository = AuthRepositoryImp();
  final eventsRepository = AllEventsRepositoryImpl();
=======
  final profileService =
      ProfileService(); // Create an instance of ProfileService
>>>>>>> parent of 283b956a (latest update .create course is remaining)

  runApp(MultiBlocProvider(
    providers: [
<<<<<<< HEAD
      // ChangeNotifierProviders
      ChangeNotifierProvider(create: (_) => CourseSelectionProvider()),
      ChangeNotifierProvider(create: (_) => LocationProvider()),
      ChangeNotifierProvider(create: (_) => AddressProvider()),
      ChangeNotifierProvider(
          create: (_) => CreateEventProvider(CreateEventModel(
                mode: null,
                aol: [],
                title: [],
                recurring: false,
                durationFrom: null,
                durationTo: null,
                timeOffset: null,
                meetingLink: null,
                phoneNumber: [],
                address: [],
                description: null,
                registrationLink: null,
                coordinates: [],
                teachers: [],
                date: EventDateTime(from: null, to: null),
              ))),
      ChangeNotifierProvider(create: (_) => CourseListProvider()),
      ChangeNotifierProvider(create: (_) => BottomSheetContentProvider()),
      ChangeNotifierProvider(create: (_) => HomeProvider()),
      ChangeNotifierProvider(create: (_) => TeacherProvider(TData())),

      // BlocProviders
      BlocProvider(create: (_) => UserLocationBloc()),
      BlocProvider(create: (_) => ProfileDetailsBloc(profileRepository)),
      BlocProvider(create: (_) => ProfileBloc(profileRepository)),
      BlocProvider(create: (_) => CreateEventBloc(eventsRepository)),
      BlocProvider(create: (_) => AuthenticationBloc(authRepository)),
      BlocProvider(create: (_) => AllEventBloc(eventsRepository)),
=======
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
>>>>>>> parent of 283b956a (latest update .create course is remaining)
    ],
    child: const MyApp(),
  ));
}
