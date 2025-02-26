import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:srisridrishti/models/all_events_model.dart';
import 'package:srisridrishti/models/teacher_details_model.dart';
import 'package:srisridrishti/themes/theme.dart';

// ...existing imports...
class CourseDetailsScreen extends StatefulWidget {
  final Event? event;
  final String userID;

  const CourseDetailsScreen({
    Key? key,
    required this.event,
    required this.userID,
  }) : super(key: key);

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  bool isRegistered = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    print('DEBUG: CourseDetailsScreen initialized with event: ${widget.event}');
    checkRegistrationStatus();
  }

  Future<void> checkRegistrationStatus() async {
    print('DEBUG: Checking registration status for user: ${widget.userID}');
    setState(() {
      isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final isRegistered = isEventRegistered();
      print(
          'DEBUG: Registration status check complete. isRegistered: $isRegistered');

      setState(() {
        this.isRegistered = isRegistered;
        isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error checking registration status: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.event == null) {
      print('DEBUG: Event is null in CourseDetailsScreen');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Course Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Course details are not available'),
        ),
      );
    }

    // Debug print for key event details
    print('DEBUG: Building CourseDetailsScreen with:'
        '\nTitle: ${widget.event?.title}'
        '\nDescription: ${widget.event?.description}'
        '\nTeachers count: ${widget.event?.teachersDetails?.length}'
        '\nEvent date: ${widget.event?.dateFrom}');

    // Safe getters for commonly used values
    final String title = widget.event?.title?.firstOrNull ?? 'Untitled Course';
    final String description =
        widget.event?.description ?? 'No description available';
    final List<String> address = widget.event?.address ?? [];
    final List<TeacherDetails> teachers =
        (widget.event?.teachersDetails ?? []).cast<TeacherDetails>();
    final DateTime? eventDate = widget.event?.dateFrom;
    final String formattedDate = eventDate != null
        ? DateFormat('MMM dd, yyyy').format(eventDate)
        : 'Date not specified';

    // Rest of your existing build method using these safe values
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.manrope(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Image (if available)
                      if (widget.event?.image != null &&
                          widget.event!.image!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.event!.image!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(
                                  child:
                                      Icon(Icons.image_not_supported, size: 50),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Event Title
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Event Date
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Event Time
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            getEventTime(),
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Event Description
                      Text(
                        'Description',
                        style: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Location
                      if (address.isNotEmpty && address != 'No Location') ...[
                        Text(
                          'Location',
                          style: GoogleFonts.manrope(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address.first,
                                style: GoogleFonts.manrope(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Price (if available)
                      if (widget.event?.price != null) ...[
                        Text(
                          'Price',
                          style: GoogleFonts.manrope(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.event?.price ?? 'Free'}',
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Teachers
                      if (teachers.isNotEmpty) ...[
                        Text(
                          'Teachers',
                          style: GoogleFonts.manrope(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: teachers.length,
                          itemBuilder: (context, index) {
                            final teacher = teachers[index];
                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage: NetworkImage(
                                        teacher.profileImage ??
                                            'https://via.placeholder.com/150',
                                      ),
                                      onBackgroundImageError: (_, __) {
                                        // Handle image loading errors
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            teacher.name ?? 'Unknown Teacher',
                                            style: GoogleFonts.manrope(
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (teacher.bio != null &&
                                              teacher!.bio!.isNotEmpty)
                                            Text(
                                              teacher.bio!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.manrope(
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],

                      // Capacity information
                      if (widget.event?.capacity != null) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.people,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Capacity: ${widget.event?.capacity}',
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Register button
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRegistered
                                ? Colors.grey
                                : AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isRegistered
                              ? null
                              : () {
                                  // Registration logic
                                  _registerForEvent();
                                },
                          child: Text(
                            isRegistered
                                ? 'Already Registered'
                                : 'Register for Event',
                            style: GoogleFonts.manrope(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _registerForEvent() async {
    print('DEBUG: Starting event registration for user: ${widget.userID}');
    setState(() {
      isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      print('DEBUG: Registration successful');

      setState(() {
        isRegistered = true;
        isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered for event!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Registration failed with error: $e');
      // Handle registration error
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add helper methods for safe data access
  String getEventTime() {
    final from = widget.event?.timeFrom;
    final to = widget.event?.timeTo;
    print('DEBUG: Getting event time - from: $from, to: $to');
    if (from == null) return 'Time not specified';
    if (to == null) return from;
    return '$from - $to';
  }

  bool isEventRegistered() {
    final result = widget.event?.notifyTo?.contains(widget.userID) ?? false;
    print(
        'DEBUG: Checking if user ${widget.userID} is registered. Result: $result');
    return result;
  }
}

class Event {
  final List<String>? title;
  final List<TeachersDetails>? teachers;
  final String? description;
  final List<String>? address;
  final List<TeacherDetails>? teachersDetails;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? timeFrom;
  final String? timeTo;
  final String? image;
  final String? price;
  final int? capacity;
  final String? id;
  final List<String>? notifyTo;
  // Add safe access methods
  bool get hasValidTeachers => teachers != null && teachers!.isNotEmpty;
  Event(
    this.teachers, {
    this.title,
    this.description,
    this.address,
    this.teachersDetails,
    this.dateFrom,
    this.dateTo,
    this.timeFrom,
    this.timeTo,
    this.image,
    this.price,
    this.capacity,
    this.id,
    this.notifyTo,
  });
}

// Teacher details model
class TeacherDetails {
  final String? name;
  final String? profileImage;
  final String? bio;
  final String? id;

  TeacherDetails({
    this.name,
    this.profileImage,
    this.bio,
    this.id,
  });
}
