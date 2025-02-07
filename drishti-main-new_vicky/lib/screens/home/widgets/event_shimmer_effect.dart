import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget eventShimmerEffect() {
  return ListView.builder(
      itemCount: 3,
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 20),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            textShimmer(),
            const SizedBox(height: 7),
            SizedBox(
              height: 230,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[50]!,
                      child: Container(
                        width: 280.0,
                        height: 90.0,
                        margin: const EdgeInsets.only(right: 10),
                        color: Colors.white,
                      ),
                    );
                  }),
            ),
            const SizedBox(height: 30),
          ],
        );
      });
}

Widget textShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[50]!,
    child: Container(
      width: 90.0,
      height: 20.0,
      color: Colors.white,
    ),
  );
}
