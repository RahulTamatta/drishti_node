import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailedScreen extends StatelessWidget {
  const DetailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              // Implement add images functionality
            },
            icon: const Icon(Icons.add, color: Colors.blue),
            label: const Text(
              'Add Images',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sudarshan Kriya',
                style: GoogleFonts.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
              Text(
                'Attended on : 12/6/2022',
                style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttendee('Bhupendra', 'assets/images/bhupendra.jpg'),
                  _buildAttendee('Sagar', 'assets/images/sagar.jpg'),
                  _buildAttendee('Kundan', 'assets/images/kundan.jpg'),
                ],
              ),
              SizedBox(height: 16.sp),
              _buildImageCard('assets/images/yoga1.jpg'),
              SizedBox(height: 16.sp),
              _buildImageCard('assets/images/yoga2.jpg'),
              SizedBox(height: 16.sp),
              _buildImageCard('assets/images/yoga3.jpg'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendee(String name, String imagePath) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30.sp,
          backgroundImage: AssetImage(imagePath),
        ),
        SizedBox(height: 8.sp),
        Text(
          name,
          style: GoogleFonts.manrope(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(String imagePath) {
    return Container(
      height: 200.sp,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.sp),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
              child: Text(
                'The point of using Lorem Ipsum is that it has a more-or-l',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
