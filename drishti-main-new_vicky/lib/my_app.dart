import 'package:srisridrishti/screens/bottom_navigation/bottom_navigation_screen.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:srisridrishti/screens/auth/screens/phone_number_screen.dart';
import 'package:srisridrishti/screens/boarding/screens/splash_screen.dart';
import 'package:srisridrishti/themes/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Map<String, dynamic>> _checkLoginAndOnboardingStatus() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Show SplashScreen for 2 seconds
    final accessToken = await SharedPreferencesHelper.getAccessToken();
    final isOnboardingComplete =
        await SharedPreferencesHelper.isOnboardingComplete();
    return {
      'accessToken': accessToken,
      'isOnboardingComplete': isOnboardingComplete,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (_, child) => GetMaterialApp(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<Map<String, dynamic>>(
          future: _checkLoginAndOnboardingStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen(); // Display SplashScreen while waiting
            } else {
              if (snapshot.hasData) {
                final accessToken = snapshot.data?['accessToken'];
                final isOnboardingComplete =
                    snapshot.data?['isOnboardingComplete'];

                if (accessToken != null) {
                  if (isOnboardingComplete) {
                    // return const BottomNavigationScreen(); // Navigate to authenticated screen
                    return const BottomNavigationScreen();
                  } else {
                    return const BottomNavigationScreen(); // Navigate to profile details screen
                  }
                } else {
                  // Change this before uploading
                  return PhoneNumberScreen(); // Navigate to login or authentication screen
                }
              } else {
                return PhoneNumberScreen(); // Fallback in case of an error
              }
            }
          },
        ),
      ),
    );
  }
}
