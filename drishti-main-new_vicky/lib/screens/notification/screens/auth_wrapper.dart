// New file: lib/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;
  final Widget onUnauthorized;

  const AuthWrapper({
    required this.child,
    required this.onUnauthorized,
    Key? key,
  }) : super(key: key);

  Future<bool> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('UserID');
    final token = prefs.getString('accessToken');
    return userID != null && token != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          return child;
        }

        return onUnauthorized;
      },
    );
  }
}
