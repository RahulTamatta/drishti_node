import 'package:srisridrishti/screens/profile/screens/profile_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileShimmerEffect extends StatelessWidget {
  const ProfileShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: .50, horizontal: 20),
      child: Column(
        children: [
          ProfileDetailsScreenState().profileIconWidget(),
          const SizedBox(height: 60),
          const ShimmerWidget.rectangular(height: 50),
          const SizedBox(height: 20),
          const ShimmerWidget.rectangular(height: 50),
          const SizedBox(height: 20),
          const ShimmerWidget.rectangular(height: 50),
          const SizedBox(height: 20),
          const ShimmerWidget.rectangular(height: 50),
          const SizedBox(height: 20),
          const ShimmerWidget.rectangular(height: 50),
        ],
      ),
    );
  }
}

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerWidget.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
  });

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
        ),
      );
}
