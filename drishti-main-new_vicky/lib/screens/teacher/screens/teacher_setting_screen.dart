import 'package:srisridrishti/screens/auth/screens/phone_number_screen.dart';
import 'package:srisridrishti/screens/profile/screens/profileScreen.dart';
import 'package:srisridrishti/screens/teacher/screens/media_links.dart';
import 'package:srisridrishti/screens/teacher/screens/teacher_location_access.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/user_details_model.dart';
import '../../../utils/shared_preference_helper.dart';

import 'admin/screens/admin_panel_screen.dart';

class TeacherSettingScreen extends StatelessWidget {
  final UserDetailsModel? userDetails;

  const TeacherSettingScreen({super.key, required this.userDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
        ),
        centerTitle: false,
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildListTile(
            context,
            icon: Icons.person,
            title: 'Personal Details',
            description: 'Teacher ID, Mobile No, Email',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.admin_panel_settings_outlined,
            title: 'Admin Panel',
            description: '',
            onTap: () {
              if (userDetails?.role == "admin") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminPanelScreen()),
                );
              } else {
                showToast(
                    text: "Don't have Admin Access!",
                    color: Colors.grey,
                    context: context);
              }
            },
          ),
          _buildListTile(
            context,
            icon: Icons.person_add,
            title: 'Add Social Media',
            description: '',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MediaLinksScreen()),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.add_location_alt_outlined,
            title: 'Location ',
            description: '',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TeacherLocationAccess()),
              );
            },
          ),
          // Adding Logout Button here
          _buildListTile(
            context,
            icon: Icons.logout,
            title: 'Logout',
            description: '',
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  // Logout logic
  Future<void> _logout(BuildContext context) async {
    // Clear saved access token from shared preferences
    await SharedPreferencesHelper.clearAccessToken();

    // Optionally, show a toast or message indicating logout success
    showToast(
        text: "Logged out successfully", color: Colors.green, context: context);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => PhoneNumberScreen()),
      (route) => false,
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          textStyle: TextStyle(
            color: Colors.black,
            fontSize: 15.sp,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      subtitle: Text(
        description,
        style: GoogleFonts.manrope(
          textStyle: TextStyle(
              color: Colors.black54,
              fontSize: 13.sp,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w500),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_outlined,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
