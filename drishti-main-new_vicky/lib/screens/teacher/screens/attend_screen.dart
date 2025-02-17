import 'package:srisridrishti/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:srisridrishti/screens/teacher/screens/course_attend_detaills.dart';
import 'package:get/get.dart';

class CourseAttendDetailScreen extends StatefulWidget {
  const CourseAttendDetailScreen({super.key});

  @override
  State<CourseAttendDetailScreen> createState() =>
      CourseAttendDetailScreenState();
}

class CourseAttendDetailScreenState extends State<CourseAttendDetailScreen> {
  final String courseTitle = "Sudarshan Kriya";
  final String date = "12/6/2022";
  final List<Map<String, String>> attendees = [
    {
      'name': 'Bhupendra',
      'image':
          'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg'
    }, // Replace with actual imhttps://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg'},
    {
      'name': 'Kundan',
      'image':
          'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg'
    },
  ];
  final List<String> images = [
    'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg', // Replace with actual image URLs
    'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg',
    'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primaryColor),
            ),
            child: TextButton.icon(
              onPressed: () {
                Get.to(const CourseFormScreen());
              },
              icon: Icon(Icons.add, color: AppColors.primaryColor),
              label: Text(
                "Add Images",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course title and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseTitle,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                    Text(
                      "Attended on : $date",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                // Add Image Button
              ],
            ),
            const SizedBox(height: 20),

            // Attendees' avatars
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: attendees.map((attendee) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(attendee['image']!),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          attendee['name']!,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Uploaded images
            Column(
              children: images.map((imageUrl) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Text(
                            "The point of using Lorem Ipsum is that it has a more-or-less...",
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
